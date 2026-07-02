// lib/screens/rate_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class RateServiceScreen extends StatefulWidget {
  final String? prefillName;
  const RateServiceScreen({super.key, this.prefillName});

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  int _rating = 0;
  late final TextEditingController _name;
  final _comment = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  static const _minCommentLength = 10;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.prefillName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _comment.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _rating > 0 &&
      _name.text.trim().isNotEmpty &&
      _comment.text.trim().length >= _minCommentLength;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    final ok = await ApiService.submitReview(
      customerName: _name.text.trim(),
      rating: _rating,
      comment: _comment.text.trim(),
      serviceType: 'tow',
    );

    setState(() => _submitting = false);
    if (ok) {
      setState(() => _submitted = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo enviar tu calificación. Intenta de nuevo.')),
        );
      }
    }
  }

  void _close() => Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Botón X arriba a la derecha
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Icon(Icons.close_rounded, color: AppTheme.white60, size: 18),
                ),
              ),
            ),

            // Contenido centrado
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: 60,
                ),
                child: _submitted ? _buildThanks(size) : _buildForm(size),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Size size) {
    final remaining = _minCommentLength - _comment.text.trim().length;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ícono grande
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.amber.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded, color: AppTheme.amber, size: 52),
        )
            .animate()
            .scale(duration: 450.ms, curve: Curves.elasticOut),

        const SizedBox(height: 20),

        Text('Servicio completado',
            style: AppTheme.display(26, w: FontWeight.w900),
            textAlign: TextAlign.center)
            .animate(delay: 100.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 8),

        Text('¿Cómo fue tu experiencia?',
            style: AppTheme.body(15, color: AppTheme.white60),
            textAlign: TextAlign.center)
            .animate(delay: 150.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 32),

        // Estrellas grandes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < _rating;
            return GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: AnimatedScale(
                scale: filled ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? AppTheme.amber : AppTheme.white30,
                    size: size.width * 0.12, // proporcional a la pantalla
                  ),
                ),
              ),
            );
          }),
        ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 28),

        // Campo nombre
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: _name,
            style: AppTheme.body(15),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Tu nombre',
              hintStyle: AppTheme.body(14, color: AppTheme.white30),
              prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.white30, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ).animate(delay: 250.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 12),

        // Campo comentario
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: _comment,
            maxLines: 4,
            style: AppTheme.body(15),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cuéntanos cómo fue el servicio (mín. 10 caracteres)',
              hintStyle: AppTheme.body(13, color: AppTheme.white30),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ).animate(delay: 280.ms).fadeIn(duration: 300.ms),

        if (remaining > 0 && _comment.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Faltan $remaining caracteres',
                style: AppTheme.body(11, color: AppTheme.white30)),
          ),
        ],

        const SizedBox(height: 24),

        // Botón enviar
        SizedBox(
          width: double.infinity,
          height: 56,
          child: GestureDetector(
            onTap: (!_canSubmit || _submitting) ? null : _submit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _canSubmit ? AppTheme.red : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _canSubmit
                    ? [BoxShadow(color: AppTheme.red.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]
                    : [],
              ),
              child: Center(
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text('ENVIAR CALIFICACIÓN',
                        style: AppTheme.mono(14, w: FontWeight.w800,
                            color: _canSubmit ? Colors.white : AppTheme.white30)),
              ),
            ),
          ),
        ).animate(delay: 320.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 12),

        // Botón cancelar
        TextButton(
          onPressed: _close,
          child: Text('Ahora no', style: AppTheme.body(13, color: AppTheme.white30)),
        ).animate(delay: 360.ms).fadeIn(duration: 300.ms),
      ],
    );
  }

  Widget _buildThanks(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.red.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.favorite_rounded, color: AppTheme.red, size: 56),
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text('¡Gracias por tu calificación!',
            style: AppTheme.display(24, w: FontWeight.w900),
            textAlign: TextAlign.center)
            .animate(delay: 200.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 10),

        Text('Nos ayuda a seguir mejorando.',
            style: AppTheme.body(14, color: AppTheme.white60),
            textAlign: TextAlign.center)
            .animate(delay: 300.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: GestureDetector(
            onTap: _close,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.red,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppTheme.red.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Center(
                child: Text('VOLVER AL INICIO',
                    style: AppTheme.mono(13, w: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ),
        ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
      ],
    );
  }
}