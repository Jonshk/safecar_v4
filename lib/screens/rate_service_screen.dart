// lib/screens/rate_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Pantalla de calificación, mostrada después de que un servicio pasa
/// a "completed". El backend (reviews.py) exige: customer_name,
/// rating (1-5), y comment con al menos 10 caracteres — por eso el
/// botón de enviar solo se habilita cuando ambas condiciones se
/// cumplen.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar tu calificación. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Califica el servicio')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _submitted ? _buildThanks() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final remaining = _minCommentLength - _comment.text.trim().length;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.amber, size: 48)
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('Servicio completado', style: AppTheme.display(22, w: FontWeight.w800))
              .animate(delay: 150.ms)
              .fadeIn(),
          const SizedBox(height: 6),
          Text('¿Cómo fue tu experiencia?',
              style: AppTheme.body(14, color: AppTheme.white60),
              textAlign: TextAlign.center)
              .animate(delay: 200.ms)
              .fadeIn(),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: AnimatedScale(
                  scale: filled ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled ? AppTheme.amber : AppTheme.white30,
                      size: 44,
                    ),
                  ),
                ),
              );
            }),
          ).animate(delay: 250.ms).fadeIn(),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _name,
              style: AppTheme.body(14),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                hintStyle: AppTheme.body(13, color: AppTheme.white30),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ).animate(delay: 280.ms).fadeIn(),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _comment,
              maxLines: 3,
              style: AppTheme.body(14),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cuéntanos cómo fue el servicio (mín. 10 caracteres)',
                hintStyle: AppTheme.body(13, color: AppTheme.white30),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ).animate(delay: 310.ms).fadeIn(),
          if (remaining > 0 && _comment.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Faltan $remaining caracteres',
                  style: AppTheme.body(11, color: AppTheme.white30)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (!_canSubmit || _submitting) ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: _canSubmit ? AppTheme.red : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _submitting
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('ENVIAR CALIFICACIÓN',
                          style: AppTheme.mono(13, w: FontWeight.w800,
                              color: _canSubmit ? Colors.white : AppTheme.white30)),
                ),
              ),
            ),
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildThanks() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 80),
          Icon(Icons.favorite_rounded, color: AppTheme.red, size: 48)
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('¡Gracias por tu calificación!',
              style: AppTheme.display(20, w: FontWeight.w800),
              textAlign: TextAlign.center)
              .animate(delay: 200.ms)
              .fadeIn(),
          const SizedBox(height: 8),
          Text('Nos ayuda a seguir mejorando.',
              style: AppTheme.body(13, color: AppTheme.white60))
              .animate(delay: 300.ms)
              .fadeIn(),
        ],
      ),
    );
  }
}