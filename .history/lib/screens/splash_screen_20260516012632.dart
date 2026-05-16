import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _scanCtrl;

  late Animation<double> _bgOpacity;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoY;
  late Animation<double> _progressVal;

  String _status = '';

  @override
  void initState() {
    super.initState();

    // Fondo fade in
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _bgOpacity = Tween(begin: 0.0, end: 1.0).animate(_fadeCtrl);

    // Logo entra desde abajo
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoOpacity = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_logoCtrl);
    _logoY = Tween(begin: 30.0, end: 0.0)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_logoCtrl);

    // Progress
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _progressVal = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_progressCtrl);

    // Scan line
    _scanCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();

    _run();
  }

  Future<void> _run() async {
    final lang = context.read<LangProvider>();
    _setStatus(lang.s.splashConnecting);
    final pingFuture = ApiService.health();

    // Fondo aparece
    await Future.wait([
      _fadeCtrl.forward(),
      Future.delayed(const Duration(milliseconds: 800))
    ]);
    // Logo entra
    await Future.wait([
      _logoCtrl.forward(),
      Future.delayed(const Duration(milliseconds: 900))
    ]);
    // Progress arranca
    _progressCtrl.forward();

    await Future.wait([
      pingFuture.then(
          (ok) => _setStatus(ok ? lang.s.splashOnline : lang.s.splashOffline)),
      Future.delayed(const Duration(milliseconds: 2600)),
    ]);

    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) widget.onDone();
  }

  void _setStatus(String s) {
    if (mounted) setState(() => _status = s);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _logoCtrl.dispose();
    _progressCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF060810),
      body: Stack(children: [
        // ── Foto del carro de fondo ──────────────────────────
        AnimatedBuilder(
          animation: _fadeCtrl,
          builder: (_, __) => Opacity(
            opacity: _bgOpacity.value,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/splash_safe_car.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),

        // ── Overlay oscuro para legibilidad ──────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC060810),
                  Color(0x33060810),
                  Color(0x55060810),
                  Color(0xEE060810),
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // ── Scan line ────────────────────────────────────────
        AnimatedBuilder(
          animation: _scanCtrl,
          builder: (_, __) => Positioned(
            top: _scanCtrl.value * size.height,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  const Color(0xFFE8323C).withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),

        // ── Corner brackets ──────────────────────────────────
        ..._brackets(size),

        // ── Logo centrado ─────────────────────────────────────
        Center(
          child: AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, __) => Opacity(
              opacity: _logoOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _logoY.value),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Logo oficial
                  Container(
                    width: size.width * 0.65,
                    padding: const EdgeInsets.all(16),
                    child: Image.asset('assets/images/icon.png',
                        fit: BoxFit.contain),
                  ),
                ]),
              ),
            ),
          ),
        ),

        // ── Progress + status abajo ───────────────────────────
        Positioned(
          bottom: 56,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, __) => Opacity(
              opacity: _logoOpacity.value,
              child: Column(children: [
                // Status
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _status,
                    key: ValueKey(_status),
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                      color: _status.contains('✓')
                          ? const Color(0xFF00C47A)
                          : const Color(0xFFE8323C),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progressVal.value,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFFE8323C)),
                        minHeight: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('CHICAGO, IL · EST. 2012',
                    style: TextStyle(
                        fontSize: 9,
                        color: Color(0x55FFFFFF),
                        letterSpacing: 4)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _brackets(Size size) {
    const color = Color(0x44E8323C);
    const t = 1.5;
    const l = 22.0;
    const m = 18.0;
    Widget h(double x, double y, double w) => Positioned(
        left: x, top: y, child: Container(width: w, height: t, color: color));
    Widget v(double x, double y, double h2) => Positioned(
        left: x, top: y, child: Container(width: t, height: h2, color: color));
    return [
      h(m, m, l),
      v(m, m, l),
      h(size.width - m - l, m, l),
      v(size.width - m - t, m, l),
      h(m, size.height - m - t, l),
      v(m, size.height - m - l, l),
      h(size.width - m - l, size.height - m - t, l),
      v(size.width - m - t, size.height - m - l, l),
    ];
  }
}
