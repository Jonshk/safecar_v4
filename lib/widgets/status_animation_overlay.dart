// lib/widgets/status_animation_overlay.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

/// Overlay genérico de pantalla completa para celebrar un cambio de
/// estado con una animación Lottie + texto. Reemplaza al antiguo
/// CarLaunchOverlay (que solo servía para "en camino") — ahora
/// cualquier estado puede tener su propia animación pasando un
/// [lottieAsset] distinto.
///
/// Uso:
///   StatusAnimationOverlay(
///     lottieAsset: 'assets/lottie/confirmed.json',
///     label: 'CONFIRMADO',
///     sublabel: 'Un técnico fue asignado a tu servicio',
///     onComplete: () { ... },
///   )
class StatusAnimationOverlay extends StatefulWidget {
  final String lottieAsset;
  final String label;
  final String? sublabel;
  final VoidCallback onComplete;
  final Color accentColor;

  const StatusAnimationOverlay({
    super.key,
    required this.lottieAsset,
    required this.label,
    required this.onComplete,
    this.sublabel,
    this.accentColor = AppTheme.red,
  });

  @override
  State<StatusAnimationOverlay> createState() => _StatusAnimationOverlayState();
}

class _StatusAnimationOverlayState extends State<StatusAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _fallbackTriggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);

    // Salvavidas: si el Lottie no carga, no se queda atorado el
    // cliente viendo una pantalla vacía para siempre.
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
            widget.lottieAsset,
            controller: _ctrl,
            onLoaded: _onLoaded,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.label,
                          style: AppTheme.display(24,
                              w: FontWeight.w900, color: widget.accentColor)),
                      if (widget.sublabel != null) ...[
                        const SizedBox(height: 6),
                        Text(widget.sublabel!,
                            style: AppTheme.body(13, color: AppTheme.white60),
                            textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
