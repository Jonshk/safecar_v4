import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  List<Part> _parts = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _selectedCat;
  int _skip = 0;
  static const _limit = 12;

  @override
  void initState() { super.initState(); _load(); _scroll.addListener(_onScroll); }

  @override
  void dispose() { _search.dispose(); _scroll.dispose(); super.dispose(); }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 && !_loadingMore) _loadMore();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) setState(() { _parts = []; _skip = 0; _loading = true; });
    final data = await ApiService.getParts(
      category: _selectedCat, search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      skip: 0, limit: _limit);
    if (!mounted) return;
    setState(() { _parts = data; _skip = data.length; _loading = false; });
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final data = await ApiService.getParts(
      category: _selectedCat, search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      skip: _skip, limit: _limit);
    if (!mounted) return;
    setState(() { _parts.addAll(data); _skip += data.length; _loadingMore = false; });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    final cats = [s.shopAll, s.catEngine, s.catBody, s.catElectrical, s.catSuspension, s.catFluids, 'Brakes', 'Other'];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.shopTitle, style: AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
              Text(s.shopSubtitle, style: AppTheme.display(24, w: FontWeight.w800)),
            ]),
            const Spacer(),
            const CartIconBadge(),
          ])),
        // Search
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border)),
            child: Row(children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded, color: AppTheme.white30, size: 20),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: _search,
                style: AppTheme.body(14),
                decoration: InputDecoration(hintText: s.shopSearch,
                  hintStyle: AppTheme.body(14, color: AppTheme.white30),
                  border: InputBorder.none, isDense: true),
                onSubmitted: (_) => _load(reset: true),
              )),
              if (_search.text.isNotEmpty)
                GestureDetector(onTap: () { _search.clear(); _load(reset: true); },
                  child: const Padding(padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.close_rounded, color: AppTheme.white30, size: 18))),
            ]),
          )),
        // Categories
        SizedBox(height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final cat = cats[i];
              final sel = (_selectedCat == cat) || (_selectedCat == null && cat == s.shopAll);
              return GestureDetector(
                onTap: () { setState(() => _selectedCat = cat == s.shopAll ? null : cat); _load(reset: true); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.red : AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.red : AppTheme.border)),
                  child: Text(cat, style: AppTheme.mono(11, w: FontWeight.w600,
                    color: sel ? AppTheme.white : AppTheme.white60)),
                ),
              );
            },
          )),
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
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.80),
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerBox(w: double.infinity, h: 220, radius: 20));
    }
    if (_parts.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off_rounded, color: AppTheme.white30, size: 48),
        const SizedBox(height: 14),
        Text(s.shopNoPartsTitle, style: AppTheme.display(16, w: FontWeight.w600, color: AppTheme.white60)),
        const SizedBox(height: 6),
        Text(s.shopNoPartsSub, style: AppTheme.body(13, color: AppTheme.white30)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true), color: AppTheme.red, backgroundColor: AppTheme.bgCard,
      child: GridView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.80),
        itemCount: _parts.length + (_loadingMore ? 2 : 0),
        itemBuilder: (ctx, i) {
          if (i >= _parts.length) return const ShimmerBox(w: double.infinity, h: 220, radius: 20);
          return PartCard(part: _parts[i], index: i,
            onTap: () => Navigator.pushNamed(ctx, '/part', arguments: _parts[i]));
        }),
    );
  }
}
