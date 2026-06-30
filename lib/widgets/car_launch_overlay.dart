// lib/widgets/car_launch_overlay.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

/// Overlay de pantalla completa con la animación Lottie del carro
/// acelerando + humo de escape, mostrada cuando el estado de la grúa
/// pasa a "in_progress" mientras el cliente tiene la pantalla abierta.
/// Al terminar la animación, llama [onComplete] para revelar el mapa.
class CarLaunchOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final String label;
  const CarLaunchOverlay({super.key, required this.onComplete, this.label = 'EN CAMINO'});

  @override
  State<CarLaunchOverlay> createState() => _CarLaunchOverlayState();
}

class _CarLaunchOverlayState extends State<CarLaunchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _fallbackTriggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);

    // Salvavidas: si por lo que sea el Lottie no carga/falla, no
    // dejamos al cliente atorado viendo una pantalla en blanco para
    // siempre — pasa al mapa solo después de 3s igual.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_fallbackTriggered) {
        _fallbackTriggered = true;
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onLoaded(LottieComposition composition) {
    _ctrl
      ..duration = composition.duration
      ..forward().whenComplete(() {
        if (mounted && !_fallbackTriggered) {
          _fallbackTriggered = true;
          widget.onComplete();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/car_launch.json',
            controller: _ctrl,
            onLoaded: _onLoaded,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              // Si el archivo no está puesto aún, no truena la app —
              // solo muestra el texto y pasa al mapa por el fallback.
              return const SizedBox.shrink();
            },
          ),
          Positioned(
            bottom: 80,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final opacity = _ctrl.value < 0.15
                    ? _ctrl.value / 0.15
                    : (_ctrl.value > 0.8 ? (1 - _ctrl.value) / 0.2 : 1.0);
                return Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Text(widget.label,
                      style: AppTheme.display(24, w: FontWeight.w900, color: AppTheme.red)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}