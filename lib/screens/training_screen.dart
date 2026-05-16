import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';

// ══════════════════════════════════════════════════════════════════
// TRAINING LIST SCREEN
// ══════════════════════════════════════════════════════════════════
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});
  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  List<Course> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getCourses();
    if (!mounted) return;
    setState(() {
      _courses = data;
      _loading = false;
    });
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
            // Header
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.trainingTag,
                        style: AppTheme.mono(11,
                            color: AppTheme.amber, w: FontWeight.w700)),
                    Text(s.trainingTitle,
                        style: AppTheme.display(28, w: FontWeight.w800)),
                  ]),
            )),
            // Banner
            SliverToBoxAdapter(child: _banner(s)),
            // Lista
            SliverToBoxAdapter(child: _buildList(s)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]),
        ),
      ),
    );
  }

  Widget _banner(s) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1200), Color(0xFF0E1118)]),
          border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
        ),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(s.trainingBannerTitle,
                    style: AppTheme.display(18, w: FontWeight.w900),
                    maxLines: 3),
                const SizedBox(height: 8),
                Text(s.trainingBannerSub,
                    style: AppTheme.body(13, color: AppTheme.white60)),
              ])),
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: AppTheme.amberGlow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.amber.withOpacity(0.3))),
              child: const Icon(Icons.school_outlined,
                  color: AppTheme.amber, size: 28)),
        ]),
      ).animate().fadeIn(duration: 500.ms);

  Widget _buildList(s) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
            children: List.generate(
                3,
                (_) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const ShimmerBox(
                        w: double.infinity, h: 200, radius: 20)))),
      );
    }
    if (_courses.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border)),
        child: Column(children: [
          const Icon(Icons.menu_book_outlined,
              color: AppTheme.white30, size: 40),
          const SizedBox(height: 12),
          Text(s.trainingNoneTitle,
              style: AppTheme.body(14, color: AppTheme.white60)),
          const SizedBox(height: 6),
          Text(s.trainingNoneSub,
              style: AppTheme.mono(11, color: AppTheme.white30)),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        const SectionHeader(label: 'CURSOS DISPONIBLES'),
        const SizedBox(height: 16),
        ...(_courses.asMap().entries.map((e) => _CourseCard(
              course: e.value,
              index: e.key,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<LangProvider>(),
                      child: CourseDetailScreen(course: e.value),
                    ),
                  )),
            ))),
      ]),
    );
  }
}

// ── Course Card ───────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final int index;
  const _CourseCard(
      {required this.course, required this.onTap, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          if (course.imageUrl != null && course.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: NetImage(course.imageUrl!, w: double.infinity, h: 160),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Badges
              Row(children: [
                if (course.level != null)
                  Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppTheme.amberGlow,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(course.level!.toUpperCase(),
                          style: AppTheme.mono(9,
                              w: FontWeight.w700, color: AppTheme.amber))),
                if (course.duration != null)
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.schedule_outlined,
                            size: 11, color: AppTheme.white60),
                        const SizedBox(width: 4),
                        Text(course.duration!,
                            style: AppTheme.mono(9, color: AppTheme.white60)),
                      ])),
              ]),
              const SizedBox(height: 10),
              // Title
              Text(
                  s.isEs && course.titleEs != null
                      ? course.titleEs!
                      : course.title,
                  style: AppTheme.display(17, w: FontWeight.w800)),
              const SizedBox(height: 6),
              // Description
              Text(
                  s.isEs && course.descriptionEs != null
                      ? course.descriptionEs!
                      : course.description,
                  style: AppTheme.body(13, color: AppTheme.white60),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              // Price + CTA
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                if (course.price != null)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.isEs ? 'Precio' : 'Price',
                            style: AppTheme.mono(9, color: AppTheme.white30)),
                        Text('\$${course.price!.toStringAsFixed(0)}',
                            style: AppTheme.mono(22,
                                w: FontWeight.w800, color: AppTheme.red)),
                      ])
                else
                  Text(s.isEs ? 'Consultar precio' : 'Contact for price',
                      style: AppTheme.body(13, color: AppTheme.white60)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppTheme.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                            color: AppTheme.redGlow,
                            blurRadius: 12,
                            offset: Offset(0, 4))
                      ]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(s.isEs ? 'Ver más' : 'Details',
                        style: AppTheme.mono(12, w: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: Colors.white),
                  ]),
                ),
              ]),
            ]),
          ),
        ]),
      )
          .animate(delay: Duration(milliseconds: 80 * index))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, end: 0),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// COURSE DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════
class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    final course = widget.course;
    final title =
        s.isEs && course.titleEs != null ? course.titleEs! : course.title;
    final desc = s.isEs && course.descriptionEs != null
        ? course.descriptionEs!
        : course.description;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        CustomScrollView(slivers: [
          // Hero image
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.bgCard,
            leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppTheme.bg.withOpacity(0.8),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16))),
            flexibleSpace: FlexibleSpaceBar(
              background: course.imageUrl != null && course.imageUrl!.isNotEmpty
                  ? NetImage(course.imageUrl!, w: double.infinity)
                  : Container(
                      color: AppTheme.bgCard,
                      child: const Icon(Icons.school_outlined,
                          color: AppTheme.white30, size: 64)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        if (course.level != null)
                          _badge(course.level!.toUpperCase(), AppTheme.amber,
                              AppTheme.amberGlow),
                        if (course.duration != null)
                          _badge(course.duration!, AppTheme.white60,
                              AppTheme.surface),
                        if (course.category != null)
                          _badge(course.category!.toUpperCase(),
                              AppTheme.white60, AppTheme.surface),
                      ]).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 16),
                      // Title
                      Text(title,
                              style: AppTheme.display(26, w: FontWeight.w900))
                          .animate()
                          .fadeIn(delay: 150.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 20),
                      // Price
                      if (course.price != null) ...[
                        Text(s.isEs ? 'INVERSIÓN' : 'INVESTMENT',
                            style: AppTheme.mono(10,
                                color: AppTheme.white30, w: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('\$${course.price!.toStringAsFixed(0)} USD',
                                style: AppTheme.mono(36,
                                    w: FontWeight.w800, color: AppTheme.red))
                            .animate()
                            .fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
                      ],
                      // Info cards row
                      Row(children: [
                        if (course.duration != null)
                          Expanded(
                              child: _infoCard(
                                  Icons.schedule_outlined,
                                  s.isEs ? 'Duración' : 'Duration',
                                  course.duration!)),
                        if (course.level != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                              child: _infoCard(
                                  Icons.workspace_premium_outlined,
                                  s.isEs ? 'Modalidad' : 'Mode',
                                  course.level!)),
                        ],
                      ]),
                      const SizedBox(height: 24),
                      // Description
                      Text(s.isEs ? 'DESCRIPCIÓN' : 'DESCRIPTION',
                          style: AppTheme.mono(10,
                              color: AppTheme.white30, w: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(desc,
                              style: AppTheme.body(15, color: AppTheme.white80))
                          .animate(delay: 250.ms)
                          .fadeIn(),
                      const SizedBox(height: 28),
                      // Lo que incluye
                      _whatIncluded(s),
                      const SizedBox(height: 28),
                      // Contacto directo
                      _contactSection(s),
                    ]),
              ),
            ),
          ),
        ]),
        // Bottom CTA
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: const BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppTheme.border))),
            child: Row(children: [
              // WhatsApp
              GestureDetector(
                onTap: () {
                  final msg = Uri.encodeComponent(s.isEs
                      ? 'Hola! Me interesa el curso: $title${course.price != null ? " (\$${course.price!.toStringAsFixed(0)})" : ""}. ¿Pueden darme más información?'
                      : 'Hi! I am interested in the course: $title${course.price != null ? " (\$${course.price!.toStringAsFixed(0)})" : ""}. Can you give me more info?');
                  launchUrl(Uri.parse('https://wa.me/18723545706?text=$msg'),
                      mode: LaunchMode.externalApplication);
                },
                child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF075E54), Color(0xFF25D366)]),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.chat_outlined,
                        color: Colors.white, size: 24)),
              ),
              const SizedBox(width: 12),
              // Inscribirse
              Expanded(
                  child: RedButton(
                label: s.isEs ? 'INSCRIBIRME AHORA' : 'ENROLL NOW',
                icon: Icons.school_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(providers: [
                        ChangeNotifierProvider.value(
                            value: context.read<LangProvider>()),
                      ], child: EnrollScreen(course: widget.course)),
                    )),
              )),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _badge(String text, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style: AppTheme.mono(10, color: color, w: FontWeight.w700)),
      );

  Widget _infoCard(IconData icon, String label, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppTheme.red, size: 20),
          const SizedBox(height: 8),
          Text(label, style: AppTheme.mono(9, color: AppTheme.white30)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.display(13, w: FontWeight.w700)),
        ]),
      );

  Widget _whatIncluded(s) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.isEs ? 'QUÉ INCLUYE' : 'WHAT IS INCLUDED',
              style:
                  AppTheme.mono(11, color: AppTheme.amber, w: FontWeight.w700)),
          const SizedBox(height: 14),
          ...[
            s.isEs ? 'Material didáctico completo' : 'Complete study materials',
            s.isEs
                ? 'Certificado de finalización'
                : 'Certificate of completion',
            s.isEs
                ? 'Acceso a instructores expertos'
                : 'Access to expert instructors',
            s.isEs
                ? 'Práctica con equipos reales'
                : 'Practice with real equipment',
            s.isEs ? 'Soporte post-curso' : 'Post-course support',
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          color: AppTheme.amberGlow, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          size: 12, color: AppTheme.amber)),
                  const SizedBox(width: 10),
                  Text(item, style: AppTheme.body(14)),
                ]),
              )),
        ]),
      );

  Widget _contactSection(s) => Row(children: [
        Expanded(
            child: GestureDetector(
          onTap: () => launchUrl(Uri.parse('tel:+18723611607'),
              mode: LaunchMode.externalApplication),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border)),
            child: Column(children: [
              const Icon(Icons.phone_outlined, color: AppTheme.red, size: 22),
              const SizedBox(height: 6),
              Text(s.isEs ? 'Llamar' : 'Call',
                  style: AppTheme.mono(11, w: FontWeight.w700)),
              Text('+1 (872) 361-1607',
                  style: AppTheme.mono(9, color: AppTheme.white60)),
            ]),
          ),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: GestureDetector(
          onTap: () => launchUrl(
              Uri.parse('mailto:safecarautomotive@gmail.com'),
              mode: LaunchMode.externalApplication),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border)),
            child: Column(children: [
              const Icon(Icons.email_outlined, color: AppTheme.red, size: 22),
              const SizedBox(height: 6),
              Text(s.isEs ? 'Email' : 'Email',
                  style: AppTheme.mono(11, w: FontWeight.w700)),
              Text('safecarautomotive@',
                  style: AppTheme.mono(9, color: AppTheme.white60)),
            ]),
          ),
        )),
      ]);
}

// ══════════════════════════════════════════════════════════════════
// ENROLL SCREEN
// ══════════════════════════════════════════════════════════════════
class EnrollScreen extends StatefulWidget {
  final Course course;
  const EnrollScreen({super.key, required this.course});
  @override
  State<EnrollScreen> createState() => _EnrollState();
}

class _EnrollState extends State<EnrollScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _method = 'zelle';
  bool _loading = false;
  bool _success = false;
  String _ref = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _enroll() async {
    final s = context.read<LangProvider>().s;
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(s.isEs ? 'Completa todos los campos' : 'Fill all fields'),
          backgroundColor: AppTheme.redDim,
          behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await ApiService.enrollCourse(
        moduleId: widget.course.id,
        studentName: _name.text.trim(),
        studentEmail: _email.text.trim(),
        studentPhone: _phone.text.trim(),
        paymentMethod: _method,
      );
      if (!mounted) return;
      if (r != null) {
        setState(() {
          _loading = false;
          _success = true;
          _ref = r['reference'] ?? '';
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(s.isEs ? 'Error al inscribirse' : 'Enrollment error'),
            backgroundColor: AppTheme.redDim,
            behavior: SnackBarBehavior.floating));
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    final title = s.isEs && widget.course.titleEs != null
        ? widget.course.titleEs!
        : widget.course.title;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18)),
        title: Text(s.isEs ? 'INSCRIPCIÓN' : 'ENROLLMENT',
            style: AppTheme.mono(13, w: FontWeight.w700)),
      ),
      body: _success ? _buildSuccess(s, title) : _buildForm(s, title),
    );
  }

  Widget _buildForm(s, String title) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Resumen del curso
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.amber.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.school_outlined,
                  color: AppTheme.amber, size: 28),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: AppTheme.display(15, w: FontWeight.w700),
                        maxLines: 2),
                    if (widget.course.price != null)
                      Text('\$${widget.course.price!.toStringAsFixed(0)} USD',
                          style: AppTheme.mono(16,
                              w: FontWeight.w800, color: AppTheme.red)),
                  ])),
            ]),
          ),
          const SizedBox(height: 24),
          Text(s.isEs ? 'TUS DATOS' : 'YOUR INFO',
              style:
                  AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
          const SizedBox(height: 12),
          _field(_name, s.checkoutName, Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _field(_email, s.checkoutEmail, Icons.email_outlined,
              type: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _field(_phone, s.checkoutPhone, Icons.phone_outlined,
              type: TextInputType.phone),
          const SizedBox(height: 24),
          Text(s.isEs ? 'MÉTODO DE PAGO' : 'PAYMENT METHOD',
              style:
                  AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
          const SizedBox(height: 12),
          _payOpt('zelle', 'Zelle', Icons.phone_android_outlined,
              '+1 (872) 361-1607'),
          const SizedBox(height: 8),
          _payOpt(
              'bank_transfer',
              s.isEs ? 'Transferencia Bancaria' : 'Bank Transfer',
              Icons.account_balance_outlined,
              'Citi Bank'),
          const SizedBox(height: 8),
          _payOpt('card', s.isEs ? 'Tarjeta' : 'Card',
              Icons.credit_card_outlined, 'Visa · Mastercard · Amex'),
          const SizedBox(height: 28),
          RedButton(
              label: s.isEs ? 'CONFIRMAR INSCRIPCIÓN' : 'CONFIRM ENROLLMENT',
              icon: Icons.check_circle_outline_rounded,
              onTap: _enroll,
              loading: _loading),
          const SizedBox(height: 30),
        ]),
      );

  Widget _buildSuccess(s, String title) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 30),
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
                color: Color(0xff00c47a22), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF00C47A), size: 50),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(s.isEs ? '¡Inscripción Exitosa!' : 'Enrollment Confirmed!',
              style: AppTheme.display(24, w: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(title,
              style: AppTheme.body(15, color: AppTheme.white60),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('REF: $_ref',
              style:
                  AppTheme.mono(13, color: AppTheme.red, w: FontWeight.w700)),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border)),
            child: Text(
                s.isEs
                    ? 'Hemos recibido tu inscripción. Te contactaremos a la brevedad con las instrucciones de pago y horarios. Guarda tu referencia.'
                    : 'We received your enrollment. We will contact you shortly with payment instructions and schedule. Keep your reference.',
                style: AppTheme.body(14, color: AppTheme.white80),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              final msg = Uri.encodeComponent(s.isEs
                  ? 'Hola! Me inscribí al curso: $title. Referencia: $_ref. Metodo: $_method'
                  : 'Hi! I enrolled in: $title. Reference: $_ref. Method: $_method');
              launchUrl(Uri.parse('https://wa.me/18723545706?text=$msg'),
                  mode: LaunchMode.externalApplication);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF075E54), Color(0xFF128C7E)]),
                  borderRadius: BorderRadius.circular(14)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.chat_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(s.isEs ? 'Confirmar por WhatsApp' : 'Confirm via WhatsApp',
                    style: AppTheme.display(14, w: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      );

  Widget _payOpt(String value, String label, IconData icon, String sub) {
    final sel = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: sel ? AppTheme.redGlow : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: sel ? AppTheme.red : AppTheme.border,
                width: sel ? 1.5 : 1)),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: sel ? AppTheme.red : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon,
                  color: sel ? Colors.white : AppTheme.white60, size: 20)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label, style: AppTheme.display(13, w: FontWeight.w700)),
                Text(sub, style: AppTheme.body(11, color: AppTheme.white60)),
              ])),
          if (sel)
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.red, size: 20),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
          {TextInputType type = TextInputType.text}) =>
      Container(
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border)),
        child: TextField(
            controller: c,
            keyboardType: type,
            style: AppTheme.body(14),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTheme.body(14, color: AppTheme.white30),
                prefixIcon: Icon(icon, color: AppTheme.white30, size: 20),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
      );
}
