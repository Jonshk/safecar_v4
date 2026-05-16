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
            // IMAGEN COMPLETA DEL SPLASH
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_safe_car.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Capa oscura muy suave para integrar el status dinámico
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.03),
              ),
            ),

            // STATUS DINÁMICO ENCIMA
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

            // BARRA DE PROGRESO ANIMADA
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
          ],
        ),
      ),
    );
  }
}
