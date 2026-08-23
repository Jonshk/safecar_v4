import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';
import 'booking_screen.dart';

// ══════════════════════════════════════════════════════════════════
// BODY SHOP SCREEN — pantalla completa dedicada (estilo Training)
// ══════════════════════════════════════════════════════════════════
class BodyShopScreen extends StatelessWidget {
  const BodyShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: Text(s.bodyShopSectionTitle,
            style: AppTheme.mono(13, w: FontWeight.w700)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hero(s),
              const SizedBox(height: 8),
              _serviceBlock(
                context: context,
                s: s,
                serviceType: 'body_collision_repair',
                icon: Icons.car_crash_rounded,
                image:
                    'https://images.unsplash.com/photo-1767681092416-bccf9410bda4?auto=format&fit=crop&w=1200&q=80',
                title: s.bodyShopCollisionTitle,
                tagline: s.bodyShopCollisionTagline,
                body: s.bodyShopCollisionBody,
                bullets: s.bodyShopCollisionBullets,
              ),
              const SizedBox(height: 28),
              _serviceBlock(
                context: context,
                s: s,
                serviceType: 'body_paint_refinishing',
                icon: Icons.format_paint_rounded,
                image:
                    'https://images.unsplash.com/photo-1702146713858-8e7d1cc29fe8?auto=format&fit=crop&w=1200&q=80',
                title: s.bodyShopPaintTitle,
                tagline: s.bodyShopPaintTagline,
                body: s.bodyShopPaintBody,
                bullets: s.bodyShopPaintBullets,
              ),
              const SizedBox(height: 28),
              _estimateStrip(context, s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(s) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0608), Color(0xFF0E1118), Color(0xFF080A0F)],
            ),
            border: Border.all(color: AppTheme.border),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.car_repair_rounded,
                    size: 140, color: Colors.white.withOpacity(0.06)),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.bodyShopSectionTitle.toUpperCase(),
                        style: AppTheme.mono(11,
                            w: FontWeight.w700, color: AppTheme.red)),
                    const SizedBox(height: 8),
                    Text(s.bodyShopHeroTitle,
                        style: AppTheme.display(24, w: FontWeight.w900),
                        maxLines: 2),
                    const SizedBox(height: 10),
                    Text(s.bodyShopHeroSub,
                        style: AppTheme.body(13, color: AppTheme.white60),
                        maxLines: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms);

  Widget _serviceBlock({
    required BuildContext context,
    required s,
    required String serviceType,
    required IconData icon,
    required String image,
    required String title,
    required String tagline,
    required String body,
    required List<String> bullets,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NetImage(image, w: double.infinity, h: 170),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.bg.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.red.withOpacity(0.4)),
                    ),
                    child: Icon(icon, color: AppTheme.red, size: 20),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.display(18, w: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(tagline,
                      style: AppTheme.body(13,
                          color: AppTheme.red, w: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(body, style: AppTheme.body(13, color: AppTheme.white80)),
                  const SizedBox(height: 16),
                  ...bullets.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(Icons.check_circle_rounded,
                                  color: AppTheme.red, size: 15),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(b,
                                  style: AppTheme.body(12.5,
                                      color: AppTheme.white80)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 6),
                  RedButton(
                    label: s.bodyShopCta,
                    icon: Icons.calendar_month_rounded,
                    onTap: () {
                      BookingScreen.presetServiceType = serviceType;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: context.read<LangProvider>(),
                            child: const BookingScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _estimateStrip(BuildContext context, s) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF8B1D22), AppTheme.red, Color(0xFFFF5B63)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.bodyShopEstimateTitle,
                        style: AppTheme.display(15, w: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(s.bodyShopEstimateSub,
                        style: AppTheme.body(12,
                            color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  BookingScreen.presetServiceType = 'body_shop_estimate';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<LangProvider>(),
                        child: const BookingScreen(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(s.bodyShopEstimateCta,
                      style: AppTheme.mono(11,
                          w: FontWeight.w800, color: AppTheme.red)),
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0);
}
