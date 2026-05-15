import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.contactTag, style: AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
            Text(s.contactTitle, style: AppTheme.display(28, w: FontWeight.w800)),
            const SizedBox(height: 20),

            // ── WhatsApp CTA grande ────────────────────────────
            _whatsappCTA(context, s),
            const SizedBox(height: 16),

            // ── Redes sociales ─────────────────────────────────
            _socialRow(),
            const SizedBox(height: 24),

            // ── Info cards ─────────────────────────────────────
            _infoCard(context, Icons.phone_outlined, s.contactPhone,
              '+1 (872) 361-1607', s.contactPhoneSub,
              onTap: () => _launch('tel:+18723611607')),
            const SizedBox(height: 12),
            _infoCard(context, Icons.email_outlined, 'EMAIL',
              'safecarautomotive@gmail.com', s.contactEmailSub,
              onTap: () => _launch('mailto:safecarautomotive@gmail.com')),
            const SizedBox(height: 12),
            _infoCard(context, Icons.location_on_outlined, s.contactAddress,
              '1052 W 51st St', 'Chicago, IL 60609',
              onTap: () => _launch('https://maps.google.com/?q=1052+W+51st+St+Chicago+IL+60609')),
            const SizedBox(height: 24),

            // ── Horario ────────────────────────────────────────
            const SectionHeader(label: 'HORARIO'),
            const SizedBox(height: 14),
            _hoursCard(s),
            const SizedBox(height: 24),

            // ── Nosotros ───────────────────────────────────────
            SectionHeader(label: s.contactAbout),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(s.contactAboutText, style: AppTheme.body(14, color: AppTheme.white80)),
            ).animate().fadeIn(delay: 200.ms),
          ]),
        ),
      ),
    );
  }

  // ── WhatsApp CTA ──────────────────────────────────────────────
  Widget _whatsappCTA(BuildContext context, s) {
    return GestureDetector(
      onTap: () => _launch('https://wa.me/18723545706'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF075E54), Color(0xFF128C7E)],
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFF25D366).withOpacity(0.25),
              blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: _WhatsAppIcon(size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.isEs ? 'Chat por WhatsApp' : 'Chat on WhatsApp',
              style: AppTheme.display(16, w: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('+1 (872) 354-5706',
              style: AppTheme.mono(13, color: Colors.white.withOpacity(0.8))),
            Text(s.isEs ? 'Respuesta rápida · Lun-Vie' : 'Quick reply · Mon-Fri',
              style: AppTheme.body(11, color: Colors.white.withOpacity(0.6))),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }

  // ── Social row ────────────────────────────────────────────────
  Widget _socialRow() {
    final socials = [
      ('Facebook', 'https://www.facebook.com/safecartallerautomotriz', const Color(0xFF1877F2), _FbIcon()),
      ('Instagram', 'https://www.instagram.com/safecar.automotive', const Color(0xFFE1306C), _IgIcon()),
      ('TikTok', 'https://www.tiktok.com/@safeeducations', Colors.white, _TkIcon()),
      ('Google', 'https://www.google.com/search?q=Safe+Car+Chicago', const Color(0xFF4285F4), _GgIcon()),
    ];
    return Row(children: socials.asMap().entries.map((e) {
      final i = e.key; final s = e.value;
      return Expanded(
        child: GestureDetector(
          onTap: () => _launch(s.$2),
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(children: [
              s.$4,
              const SizedBox(height: 6),
              Text(s.$1, style: AppTheme.mono(9, color: AppTheme.white60, w: FontWeight.w600)),
            ]),
          ),
        ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn().slideY(begin: 0.1, end: 0),
      );
    }).toList());
  }

  Widget _infoCard(BuildContext context, IconData icon, String label,
      String value, String sub, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => Clipboard.setData(ClipboardData(text: value)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppTheme.redGlow, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.red, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTheme.mono(9, color: AppTheme.white30, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(value, style: AppTheme.display(14, w: FontWeight.w700)),
            Text(sub, style: AppTheme.body(12, color: AppTheme.white60)),
          ])),
          Icon(onTap != null ? Icons.open_in_new_rounded : Icons.copy_outlined,
            color: AppTheme.white30, size: 16),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _hoursCard(s) {
    final hours = [
      ('Mon - Fri', '7:30 AM – 5:30 PM'),
      ('Sat', s.contactClosed),
      ('Sun', s.contactClosed),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: hours.map((h) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(h.$1, style: AppTheme.body(14, color: AppTheme.white80)),
          Text(h.$2, style: h.$2 == s.contactClosed
            ? AppTheme.mono(12, color: AppTheme.red, w: FontWeight.w700)
            : AppTheme.mono(12, color: AppTheme.white80, w: FontWeight.w600)),
        ]),
      )).toList()),
    );
  }
}

// ── Social icons SVG ──────────────────────────────────────────────
class _WhatsAppIcon extends StatelessWidget {
  final double size; final Color color;
  const _WhatsAppIcon({this.size = 20, this.color = const Color(0xFF25D366)});
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(size, size), painter: _WAPainter(color));
}

class _WAPainter extends CustomPainter {
  final Color color;
  _WAPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final s = size.width / 24.0;
    path.addOval(Rect.fromCircle(center: Offset(12*s, 12*s), radius: 11*s));
    canvas.drawPath(path, p);
    final wp = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final wPath = Path();
    wPath.moveTo(17.472*s, 14.382*s);
    wPath.cubicTo(17.175*s,14.233*s, 15.714*s,13.515*s, 15.442*s,13.415*s);
    wPath.cubicTo(15.169*s,13.316*s, 14.971*s,13.267*s, 14.772*s,13.565*s);
    wPath.close();
    canvas.drawCircle(Offset(12*s, 12*s), 8*s, Paint()..color = color);
    final iconPaint = Paint()..color = Colors.white..strokeWidth = 1.2*s..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(8*s, 12*s), Offset(16*s, 12*s), iconPaint);
    canvas.drawLine(Offset(8*s, 9*s), Offset(16*s, 9*s), iconPaint);
    canvas.drawLine(Offset(8*s, 15*s), Offset(13*s, 15*s), iconPaint);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _FbIcon extends StatelessWidget {
  const _FbIcon();
  @override
  Widget build(BuildContext context) => const Icon(Icons.facebook_rounded, color: Color(0xFF1877F2), size: 24);
}

class _IgIcon extends StatelessWidget {
  const _IgIcon();
  @override
  Widget build(BuildContext context) => Container(
    width: 24, height: 24,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF), Color(0xFF515BD4)],
      ),
    ),
    child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
  );
}

class _TkIcon extends StatelessWidget {
  const _TkIcon();
  @override
  Widget build(BuildContext context) => Container(
    width: 24, height: 24,
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
    child: const Center(child: Text('♪', style: TextStyle(color: Colors.white, fontSize: 14))),
  );
}

class _GgIcon extends StatelessWidget {
  const _GgIcon();
  @override
  Widget build(BuildContext context) => Container(
    width: 24, height: 24,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
    child: const Center(
      child: Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 16, fontWeight: FontWeight.w900)),
    ),
  );
}
