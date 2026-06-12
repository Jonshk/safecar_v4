import 'dart:math';
import 'package:flutter/material.dart';
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
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _pixovaCtrl;

  late Animation<double> _fade;
  late Animation<double> _progress;

  String _status = '';

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _progress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOutCubic),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pixovaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _run();
  }

  Future<void> _run() async {
    final lang = context.read<LangProvider>();
    _setStatus(lang.s.splashConnecting);

    final pingFuture = ApiService.health();

    await _fadeCtrl.forward();
    _progressCtrl.forward();

    await Future.wait([
      pingFuture.then(
        (ok) => _setStatus(ok ? lang.s.splashOnline : lang.s.splashOffline),
      ),
      Future.delayed(const Duration(milliseconds: 3000)),
    ]);

    await Future.delayed(const Duration(milliseconds: 650));

    if (mounted) widget.onDone();
  }

  void _setStatus(String s) {
    if (mounted) setState(() => _status = s);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    _pixovaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _status.contains('✓') ||
        _status.toLowerCase().contains('línea') ||
        _status.toLowerCase().contains('online');

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_safe_car.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.03),
              ),
            ),

            // STATUS
            Positioned(
              bottom: 144,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  final glow = 0.35 + (_pulseCtrl.value * 0.45);
                  return Column(
                    children: [
                      Text(
                        isOnline
                            ? 'SERVIDOR EN LÍNEA  ✓'
                            : _status.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 5,
                          fontWeight: FontWeight.w900,
                          color: isOnline
                              ? const Color(0xFF00F0A8)
                              : const Color(0xFFFF3344),
                          shadows: [
                            Shadow(
                              blurRadius: 18,
                              color: (isOnline
                                      ? const Color(0xFF00F0A8)
                                      : const Color(0xFFFF3344))
                                  .withOpacity(glow),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // BARRA DE PROGRESO
            Positioned(
              bottom: 100,
              left: 76,
              right: 76,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: _progress.value,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF1F35),
                                Color(0xFFFF3B45),
                                Color(0xFFFF1F35),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF1F35).withOpacity(0.8),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).size.width *
                                0.55 *
                                _progress.value -
                            20,
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.75),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // POWERED BY PIXOVA
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _pixovaCtrl,
                builder: (_, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _PixovaGrid(progress: _pixovaCtrl.value),
                    const SizedBox(width: 7),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'POWERED BY',
                          style: TextStyle(
                            fontSize: 7,
                            letterSpacing: 2,
                            color: Colors.white.withOpacity(0.3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'pix',
                                style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              TextSpan(
                                text: 'ova',
                                style: TextStyle(
                                  color: Color(0xFF0D9488),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pixova Grid animado ──────────────────────────────────────────
class _PixovaGrid extends StatelessWidget {
  final double progress;
  const _PixovaGrid({required this.progress});

  static const _colors = [
    Color(0xFF7C3AED),
    Color(0xFF0D9488),
    Color(0xFF2DD4BF),
    Color(0xFFA78BFA),
  ];

  Color _cellColor(int index) {
    final offset = (progress + index * 0.06) % 1.0;
    final colorIndex = (offset * _colors.length).floor() % _colors.length;
    final nextIndex = (colorIndex + 1) % _colors.length;
    final t = (offset * _colors.length) - colorIndex.toDouble();
    return Color.lerp(_colors[colorIndex], _colors[nextIndex], t)!;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 34,
        height: 34,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: 16,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              color: _cellColor(i),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      );
}