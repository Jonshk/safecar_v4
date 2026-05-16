import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';

// ── Review Model ──────────────────────────────────────────────────
class Review {
  final int id;
  final String customerName;
  final int rating;
  final String comment;
  final String? serviceType;
  final String createdAt;

  Review(
      {required this.id,
      required this.customerName,
      required this.rating,
      required this.comment,
      this.serviceType,
      required this.createdAt});

  factory Review.fromJson(Map<String, dynamic> j) => Review(
      id: j['id'],
      customerName: j['customer_name'],
      rating: j['rating'],
      comment: j['comment'],
      serviceType: j['service_type'],
      createdAt: j['created_at']);
}

// ══════════════════════════════════════════════════════════════════
// REVIEWS SCREEN
// ══════════════════════════════════════════════════════════════════
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> _reviews = [];
  Map<String, dynamic>? _stats;
  bool _loading = true;
  bool _showForm = false;

  static const _placeId = 'ChIJV1Orpo4uDogRuNsHRYoybSA';
  static const _googleReviewUrl =
      'https://search.google.com/local/writereview?placeid=$_placeId';
  static const _googleViewUrl =
      'https://search.google.com/local/reviews?placeid=$_placeId';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final base = AppTheme.apiBase;
      final results = await Future.wait([
        http.get(Uri.parse('$base/reviews/?limit=20')),
        http.get(Uri.parse('$base/reviews/stats')),
      ]);
      if (!mounted) return;
      setState(() {
        if (results[0].statusCode == 200) {
          final List data = jsonDecode(results[0].body);
          _reviews = data.map((e) => Review.fromJson(e)).toList();
        }
        if (results[1].statusCode == 200) {
          _stats = jsonDecode(results[1].body);
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppTheme.red,
          backgroundColor: AppTheme.bgCard,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildHeader(s)),
            SliverToBoxAdapter(child: _buildGoogleCTA(s)),
            if (_stats != null) SliverToBoxAdapter(child: _buildStats(s)),
            SliverToBoxAdapter(child: _buildOwnReviewsCTA(s)),
            if (_showForm)
              SliverToBoxAdapter(child: _ReviewForm(onSubmitted: () {
                setState(() => _showForm = false);
                _load();
              })),
            if (_loading)
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    children: List.generate(
                        3,
                        (_) => Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: const ShimmerBox(
                                w: double.infinity, h: 120, radius: 16)))),
              ))
            else if (_reviews.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty(s))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _ReviewCard(review: _reviews[i], index: i),
                  childCount: _reviews.length,
                )),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(s) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.isEs ? 'RESEÑAS' : 'REVIEWS',
              style:
                  AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
          Text(
              s.isEs
                  ? 'Lo que dicen nuestros clientes'
                  : 'What our customers say',
              style: AppTheme.display(24, w: FontWeight.w800)),
        ]),
      );

  // ── Google CTA ────────────────────────────────────────────────
  Widget _buildGoogleCTA(s) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(children: [
          // Ver reseñas de Google
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(_googleViewUrl),
                mode: LaunchMode.externalApplication),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text('G',
                            style: TextStyle(
                                color: const Color(0xFF4285F4),
                                fontSize: 26,
                                fontWeight: FontWeight.w900)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          s.isEs
                              ? 'Ver reseñas en Google'
                              : 'View Google Reviews',
                          style: AppTheme.display(15, w: FontWeight.w700)),
                      Row(
                          children: List.generate(
                              5,
                              (i) => const Icon(Icons.star_rounded,
                                  color: Color(0xFFFBBC04), size: 16))),
                    ])),
                const Icon(Icons.open_in_new_rounded,
                    color: AppTheme.white30, size: 18),
              ]),
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 10),
          // Dejar reseña en Google
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(_googleReviewUrl),
                mode: LaunchMode.externalApplication),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A3A8F), Color(0xFF1557D4)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF4285F4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(children: [
                const Icon(Icons.star_outline_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          s.isEs
                              ? '¡Déjanos tu reseña en Google!'
                              : 'Leave us a Google Review!',
                          style: AppTheme.display(15, w: FontWeight.w800)),
                      Text(
                          s.isEs
                              ? 'Tu opinión nos ayuda mucho'
                              : 'Your feedback helps us grow',
                          style: AppTheme.body(12,
                              color: Colors.white.withOpacity(0.7))),
                    ])),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 16),
              ]),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
        ]),
      );

  // ── Stats ─────────────────────────────────────────────────────
  Widget _buildStats(s) {
    final avg = _stats!['avg_rating'] ?? 0.0;
    final total = _stats!['total'] ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border)),
        child: Row(children: [
          // Average
          Column(children: [
            Text(avg.toStringAsFixed(1),
                style:
                    AppTheme.mono(42, w: FontWeight.w900, color: AppTheme.red)),
            Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                        i < avg.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 18))),
            const SizedBox(height: 4),
            Text('$total ${s.isEs ? "reseñas" : "reviews"}',
                style: AppTheme.mono(10, color: AppTheme.white60)),
          ]),
          const SizedBox(width: 20),
          // Bars
          Expanded(
              child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
            final count = _stats!['${_starKey(star)}_star'] ?? 0;
            final pct = total > 0 ? count / total : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Text('$star',
                    style: AppTheme.mono(10, color: AppTheme.white60)),
                const SizedBox(width: 6),
                const Icon(Icons.star_rounded,
                    size: 10, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Expanded(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                    minHeight: 6,
                  ),
                )),
                const SizedBox(width: 6),
                Text('$count',
                    style: AppTheme.mono(10, color: AppTheme.white60)),
              ]),
            );
          }).toList())),
        ]),
      ),
    ).animate(delay: 150.ms).fadeIn();
  }

  String _starKey(int star) =>
      ['one', 'two', 'three', 'four', 'five'][star - 1];

  Widget _buildOwnReviewsCTA(s) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SectionHeader(
                label: s.isEs ? 'RESEÑAS DE CLIENTES' : 'CUSTOMER REVIEWS'),
            GestureDetector(
              onTap: () => setState(() => _showForm = !_showForm),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: AppTheme.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppTheme.redGlow, blurRadius: 10)
                    ]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_outlined,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(s.isEs ? 'Escribir' : 'Write',
                      style: AppTheme.mono(11, w: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ]),
      );

  Widget _buildEmpty(s) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border)),
        child: Column(children: [
          const Icon(Icons.reviews_outlined, color: AppTheme.white30, size: 44),
          const SizedBox(height: 12),
          Text(
              s.isEs
                  ? 'Sé el primero en dejar una reseña'
                  : 'Be the first to leave a review',
              style: AppTheme.body(14, color: AppTheme.white60),
              textAlign: TextAlign.center),
        ]),
      );
}

// ── Review Card ───────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  final int index;
  const _ReviewCard({required this.review, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppTheme.redGlow, shape: BoxShape.circle),
              child: Center(
                  child: Text(review.customerName[0].toUpperCase(),
                      style: AppTheme.display(18,
                          w: FontWeight.w800, color: AppTheme.red)))),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(review.customerName,
                    style: AppTheme.display(14, w: FontWeight.w700)),
                if (review.serviceType != null)
                  Text(review.serviceType!,
                      style: AppTheme.mono(9, color: AppTheme.white30)),
              ])),
          // Stars
          Row(
              children: List.generate(
                  5,
                  (i) => Icon(
                      i < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 16))),
        ]),
        const SizedBox(height: 12),
        Text(review.comment, style: AppTheme.body(14, color: AppTheme.white80)),
      ]),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn()
        .slideY(begin: 0.05, end: 0);
  }
}

// ── Review Form ───────────────────────────────────────────────────
class _ReviewForm extends StatefulWidget {
  final VoidCallback onSubmitted;
  const _ReviewForm({required this.onSubmitted});
  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _name = TextEditingController();
  final _comment = TextEditingController();
  int _rating = 5;
  String _service = 'parts';
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = context.read<LangProvider>().s;
    if (_name.text.trim().isEmpty || _comment.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(s.isEs ? 'Completa todos los campos' : 'Fill all fields'),
          backgroundColor: AppTheme.redDim,
          behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await http.post(
        Uri.parse('${AppTheme.apiBase}/reviews/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_name': _name.text.trim(),
          'rating': _rating,
          'comment': _comment.text.trim(),
          'service_type': _service,
        }),
      );
      if (!mounted) return;
      if (r.statusCode == 201) {
        setState(() {
          _loading = false;
          _sent = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        widget.onSubmitted();
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    if (_sent) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF00C47A11),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: const Color(0xFF00C47A).withOpacity(0.3))),
        child: Column(children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Color(0xFF00C47A), size: 40),
          const SizedBox(height: 10),
          Text(s.isEs ? '¡Gracias por tu reseña!' : 'Thanks for your review!',
              style: AppTheme.display(16,
                  w: FontWeight.w800, color: const Color(0xFF00C47A))),
          Text(
              s.isEs
                  ? 'Será publicada tras revisión.'
                  : 'Will be published after review.',
              style: AppTheme.body(13, color: AppTheme.white60)),
        ]),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
    }

    final services = s.isEs
        ? {
            'parts': 'Refacciones',
            'training': 'Capacitación',
            'repair': 'Reparación'
          }
        : {'parts': 'Parts', 'training': 'Training', 'repair': 'Repair'};

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.red.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.isEs ? 'TU RESEÑA' : 'YOUR REVIEW',
            style: AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
        const SizedBox(height: 16),
        // Stars selector
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                5,
                (i) => GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                            i < _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 36),
                      ),
                    ))),
        const SizedBox(height: 16),
        // Service type
        Row(
            children: services.entries
                .map((e) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _service = e.key),
                        child: Container(
                          margin:
                              EdgeInsets.only(right: e.key != 'repair' ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                              color: _service == e.key
                                  ? AppTheme.redGlow
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _service == e.key
                                      ? AppTheme.red
                                      : AppTheme.border)),
                          child: Center(
                              child: Text(e.value,
                                  style: AppTheme.mono(10,
                                      w: FontWeight.w600,
                                      color: _service == e.key
                                          ? AppTheme.red
                                          : AppTheme.white60))),
                        ),
                      ),
                    ))
                .toList()),
        const SizedBox(height: 14),
        _field(_name, s.isEs ? 'Tu nombre' : 'Your name',
            Icons.person_outline_rounded),
        const SizedBox(height: 10),
        _field(
            _comment,
            s.isEs
                ? 'Cuéntanos tu experiencia...'
                : 'Tell us about your experience...',
            Icons.comment_outlined,
            maxLines: 4),
        const SizedBox(height: 16),
        RedButton(
            label: s.isEs ? 'PUBLICAR RESEÑA' : 'SUBMIT REVIEW',
            icon: Icons.send_outlined,
            onTap: _submit,
            loading: _loading),
      ]),
    ).animate().fadeIn().slideY(begin: -0.05, end: 0);
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
          {int maxLines = 1}) =>
      Container(
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border)),
        child: TextField(
            controller: c,
            maxLines: maxLines,
            style: AppTheme.body(14),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTheme.body(14, color: AppTheme.white30),
                prefixIcon: maxLines == 1
                    ? Icon(icon, color: AppTheme.white30, size: 20)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14))),
      );
}
