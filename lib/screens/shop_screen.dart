import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';

// Categorías en inglés (lo que va al backend) → display EN/ES
const _catKeys = [
  'Brakes',
  'Electrical',
  'Engine',
  'Suspension',
  'Filters',
  'Cooling',
  'Glass',
  'Body',
  'Fluids',
  'Other',
];

const _catDisplay = {
  'en': {
    'Brakes': 'Brakes',
    'Electrical': 'Electrical',
    'Engine': 'Engine',
    'Suspension': 'Suspension',
    'Filters': 'Filters',
    'Cooling': 'Cooling',
    'Glass': 'Glass',
    'Body': 'Body',
    'Fluids': 'Fluids',
    'Other': 'Other',
  },
  'es': {
    'Brakes': 'Frenos',
    'Electrical': 'Eléctrico',
    'Engine': 'Motor',
    'Suspension': 'Suspensión',
    'Filters': 'Filtros',
    'Cooling': 'Refrigeración',
    'Glass': 'Vidrios',
    'Body': 'Carrocería',
    'Fluids': 'Fluidos',
    'Other': 'Otros',
  },
};

class ShopScreen extends StatefulWidget {
  // FIX: recibe categoría inicial desde home (en inglés, ej: 'Fluids')
  final String? initialCategory;
  const ShopScreen({super.key, this.initialCategory});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  List<Part> _parts = [];
  List<String> _availableCats = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _selectedCat; // siempre en inglés
  int _skip = 0;
  static const _limit = 12;

  @override
  void initState() {
    super.initState();
    // FIX: aplicar categoría inicial si viene del home
    _selectedCat = widget.initialCategory;
    _loadCategories();
    _load();
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ShopScreen old) {
    super.didUpdateWidget(old);
    // FIX: si cambia la categoría inicial (re-tap desde home), aplicarla
    if (widget.initialCategory != old.initialCategory) {
      _selectedCat = widget.initialCategory;
      _load(reset: true);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
        !_loadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadCategories() async {
    final cats = await ApiService.getCategories();
    if (!mounted) return;
    setState(() {
      _availableCats = _catKeys.where((k) => cats.contains(k)).toList();
      if (_availableCats.isEmpty) _availableCats = cats;
    });
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _parts = [];
        _skip = 0;
        _loading = true;
      });
    }
    final data = await ApiService.getParts(
      category: _selectedCat,
      search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      skip: 0,
      limit: _limit,
    );
    if (!mounted) return;
    setState(() {
      _parts = data;
      _skip = data.length;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final data = await ApiService.getParts(
      category: _selectedCat,
      search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      skip: _skip,
      limit: _limit,
    );
    if (!mounted) return;
    setState(() {
      _parts.addAll(data);
      _skip += data.length;
      _loadingMore = false;
    });
  }

  String _displayName(String catKey, bool isEs) {
    return (isEs ? _catDisplay['es'] : _catDisplay['en'])?[catKey] ?? catKey;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final s = lang.s;
    final isEs = lang.isEs;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
          child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.shopTitle,
                  style: AppTheme.mono(11,
                      color: AppTheme.red, w: FontWeight.w700)),
              Text(s.shopSubtitle,
                  style: AppTheme.display(24, w: FontWeight.w800)),
            ]),
            const Spacer(),
            const CartIconBadge(),
          ]),
        ),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded,
                  color: AppTheme.white30, size: 20),
              const SizedBox(width: 10),
              Expanded(
                  child: TextField(
                controller: _search,
                style: AppTheme.body(14),
                decoration: InputDecoration(
                  hintText: s.shopSearch,
                  hintStyle: AppTheme.body(14, color: AppTheme.white30),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _load(reset: true),
              )),
              if (_search.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _search.clear();
                    _load(reset: true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.close_rounded,
                        color: AppTheme.white30, size: 18),
                  ),
                ),
            ]),
          ),
        ),
        // Categories
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            children: [
              // "All" pill
              GestureDetector(
                onTap: () {
                  setState(() => _selectedCat = null);
                  _load(reset: true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        _selectedCat == null ? AppTheme.red : AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _selectedCat == null
                            ? AppTheme.red
                            : AppTheme.border),
                  ),
                  child: Text(
                    s.shopAll,
                    style: AppTheme.mono(11,
                        w: FontWeight.w600,
                        color: _selectedCat == null
                            ? AppTheme.white
                            : AppTheme.white60),
                  ),
                ),
              ),
              // Category pills — display name traducido, value en inglés
              ..._availableCats.map((catKey) {
                final sel = _selectedCat == catKey;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCat = catKey);
                    _load(reset: true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.red : AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppTheme.red : AppTheme.border),
                    ),
                    child: Text(
                      _displayName(catKey, isEs),
                      style: AppTheme.mono(11,
                          w: FontWeight.w600,
                          color: sel ? AppTheme.white : AppTheme.white60),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // Grid
        Expanded(child: _buildGrid(s)),
      ])),
    );
  }

  Widget _buildGrid(s) {
    if (_loading) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.80),
        itemCount: 6,
        itemBuilder: (_, __) =>
            const ShimmerBox(w: double.infinity, h: 220, radius: 20),
      );
    }
    if (_parts.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off_rounded, color: AppTheme.white30, size: 48),
        const SizedBox(height: 14),
        Text(s.shopNoPartsTitle,
            style: AppTheme.display(16,
                w: FontWeight.w600, color: AppTheme.white60)),
        const SizedBox(height: 6),
        Text(s.shopNoPartsSub,
            style: AppTheme.body(13, color: AppTheme.white30)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppTheme.red,
      backgroundColor: AppTheme.bgCard,
      child: GridView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.80),
        itemCount: _parts.length + (_loadingMore ? 2 : 0),
        itemBuilder: (ctx, i) {
          if (i >= _parts.length)
            return const ShimmerBox(w: double.infinity, h: 220, radius: 20);
          return PartCard(
            part: _parts[i],
            index: i,
            onTap: () =>
                Navigator.pushNamed(ctx, '/part', arguments: _parts[i]),
          );
        },
      ),
    );
  }
}
