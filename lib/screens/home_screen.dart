import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';
import 'booking_screen.dart';
import 'body_shop_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int, {String? category}) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Part> _featured = [];
  bool _loading = true;
  bool _serverOnline = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results =
        await Future.wait([ApiService.health(), ApiService.getParts(limit: 6)]);
    if (!mounted) return;
    setState(() {
      _serverOnline = results[0] as bool;
      _featured = results[1] as List<Part>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    final lang = context.watch<LangProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.red,
        backgroundColor: AppTheme.bgCard,
        child: CustomScrollView(slivers: [
          _hero(s, lang),
          SliverToBoxAdapter(child: _stats(s)),
          SliverToBoxAdapter(child: _categories(s)),
          SliverToBoxAdapter(child: _bodyShopSection(s)),
          SliverToBoxAdapter(child: _featuredHeader(s)),
          _featuredGrid(s),
          SliverToBoxAdapter(child: _banner(s)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
    );
  }

  Widget _hero(s, LangProvider lang) => SliverToBoxAdapter(
        child: Container(
          height: 360,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0608),
                  Color(0xFF0E1118),
                  Color(0xFF080A0F)
                ]),
            border: Border.all(color: AppTheme.border),
          ),
          child: Stack(children: [
            Positioned.fill(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: CustomPaint(painter: _GridPainter()))),
            Positioned(
                top: -60,
                right: -40,
                child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppTheme.redGlow))),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _serverOnline
                              ? const Color(0x2200C47A)
                              : AppTheme.redGlow,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: _serverOnline
                                  ? const Color(0xFF00C47A)
                                  : AppTheme.red),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _serverOnline
                                    ? const Color(0xFF00C47A)
                                    : AppTheme.red),
                          )
                              .animate(onPlay: (c) => c.repeat())
                              .then(delay: 800.ms)
                              .fadeOut(duration: 600.ms)
                              .then()
                              .fadeIn(duration: 600.ms),
                          const SizedBox(width: 7),
                          Text(_serverOnline ? s.homeLive : s.splashConnecting,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTheme.mono(10,
                                  w: FontWeight.w700,
                                  color: _serverOnline
                                      ? const Color(0xFF00C47A)
                                      : AppTheme.red)),
                        ]),
                      ).animate().fadeIn(delay: 100.ms),
                      const Spacer(),
                    ]),
                    const SizedBox(height: 20),
                    Text('SAFE CAR',
                            style: AppTheme.display(52, w: FontWeight.w900))
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                    Text('AUTOMOTIVE',
                            style: AppTheme.display(28,
                                w: FontWeight.w400, color: AppTheme.red))
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 12),
                    Text(s.homeTagline,
                            style: AppTheme.body(14, color: AppTheme.white60))
                        .animate()
                        .fadeIn(delay: 400.ms),
                    const Spacer(),
                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onNavigate(1),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                                color: AppTheme.red,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                      color: AppTheme.redGlow,
                                      blurRadius: 16,
                                      offset: Offset(0, 4))
                                ]),
                            child: Center(
                                child: Text(s.homeShopParts,
                                    style:
                                        AppTheme.mono(12, w: FontWeight.w700))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => widget.onNavigate(2),
                        child: Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border)),
                          child: const Icon(Icons.school_outlined,
                              color: AppTheme.white60, size: 20),
                        ),
                      ),
                    ]).animate().fadeIn(delay: 500.ms),
                  ]),
            ),
          ]),
        ),
      );

  Widget _stats(s) {
    final stats = [
      (s.homeStats1, '500+'),
      (s.homeStats2, '12+'),
      (s.homeStats3, '98%')
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
          children: stats.asMap().entries.map((e) {
        final i = e.key;
        final st = e.value;
        return Expanded(
            child: Container(
          margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border)),
          child: Column(children: [
            Text(st.$2,
                style:
                    AppTheme.mono(22, w: FontWeight.w800, color: AppTheme.red)),
            const SizedBox(height: 4),
            Text(st.$1,
                textAlign: TextAlign.center,
                style: AppTheme.body(10, color: AppTheme.white60)),
          ]),
        )
                .animate(delay: Duration(milliseconds: 100 * i))
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0));
      }).toList()),
    );
  }

  Widget _categories(s) {
    // FIX: cada categoría tiene su key en inglés (para el backend) + label traducido
    final cats = [
      ('Engine', Icons.settings_outlined, s.catEngine),
      ('Body', Icons.directions_car_outlined, s.catBody),
      ('Electrical', Icons.electric_bolt_outlined, s.catElectrical),
      ('Suspension', Icons.tire_repair_outlined, s.catSuspension),
      ('Fluids', Icons.opacity_outlined, s.catFluids),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
          child: SectionHeader(label: s.homeCategories)),
      SizedBox(
          height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final c = cats[i];
              return GestureDetector(
                // FIX: navega a tab 1 pasando la categoría en inglés
                onTap: () => widget.onNavigate(1, category: c.$1),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(c.$2, color: AppTheme.red, size: 24),
                        const SizedBox(height: 6),
                        Text(c.$3,
                            style: AppTheme.mono(10,
                                w: FontWeight.w600, color: AppTheme.white80)),
                      ]),
                )
                    .animate(delay: Duration(milliseconds: 60 * i))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.15, end: 0),
              );
            },
          )),
    ]);
  }

  Widget _featuredHeader(s) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
        child: SectionHeader(
            label: s.homeFeatured,
            action: s.seeAll,
            onAction: () => widget.onNavigate(1)),
      );

  Widget _featuredGrid(s) {
    if (_loading) {
      return SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.80),
            itemCount: 4,
            itemBuilder: (_, __) => const ShimmerBox(
                w: double.infinity, h: double.infinity, radius: 20)),
      ));
    }
    if (_featured.isEmpty) {
      return SliverToBoxAdapter(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border)),
        child: Column(children: [
          const Icon(Icons.inventory_2_outlined,
              color: AppTheme.white30, size: 40),
          const SizedBox(height: 12),
          Text(s.homeNoPartsTitle,
              style: AppTheme.body(14, color: AppTheme.white60)),
          const SizedBox(height: 6),
          Text(s.homeNoPartsSub,
              style: AppTheme.mono(11, color: AppTheme.white30)),
        ]),
      ));
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.80),
        delegate: SliverChildBuilderDelegate(
            (ctx, i) => PartCard(
                part: _featured[i],
                index: i,
                onTap: () =>
                    Navigator.pushNamed(ctx, '/part', arguments: _featured[i])),
            childCount: _featured.length),
      ),
    );
  }

  Widget _bodyShopSection(s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<LangProvider>(),
              child: const BodyShopScreen(),
            ),
          ),
        ),
        child: Container(
          height: 172,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0608), Color(0xFF0E1118), Color(0xFF080A0F)],
            ),
            border: Border.all(color: AppTheme.border),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(Icons.car_repair_rounded,
                    size: 130, color: Colors.white.withOpacity(0.06)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.redGlow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.red),
                      ),
                      child: Text(s.bodyShopSectionTitle.toUpperCase(),
                          style: AppTheme.mono(10,
                              w: FontWeight.w700, color: AppTheme.red)),
                    ),
                    const SizedBox(height: 8),
                    Text(s.bodyShopHeroTitle,
                        style: AppTheme.display(18, w: FontWeight.w900),
                        maxLines: 2),
                    const SizedBox(height: 5),
                    Text(s.bodyShopSectionSub,
                        style: AppTheme.body(11.5, color: AppTheme.white60),
                        maxLines: 2),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.isEs ? 'Ver servicios' : 'View services',
                            style: AppTheme.mono(11,
                                w: FontWeight.w700, color: AppTheme.red)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppTheme.red, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 150.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, end: 0);
  }

  Widget _banner(s) => GestureDetector(
        onTap: () => widget.onNavigate(3),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 28, 16, 0),
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
                colors: [Color(0xFF8B1D22), AppTheme.red, Color(0xFFFF5B63)]),
          ),
          child: Stack(children: [
            Positioned(
                right: -10,
                bottom: -10,
                child: Icon(Icons.build_circle_outlined,
                    size: 120, color: Colors.white.withOpacity(0.07))),
            Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.homeBannerTitle,
                          style: AppTheme.mono(11, w: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(s.homeBannerSub,
                          style: AppTheme.display(16, w: FontWeight.w700)),
                    ])),
          ]),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
      );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
