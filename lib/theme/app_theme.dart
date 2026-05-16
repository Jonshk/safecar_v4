import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Palette ────────────────────────────────────────────
  static const Color bg = Color(0xFF080A0F);
  static const Color bgCard = Color(0xFF0E1118);
  static const Color bgElevated = Color(0xFF141720);
  static const Color surface = Color(0xFF1A1E2A);
  static const Color border = Color(0xFF252A38);
  static const Color borderHot = Color(0xFF2E3448);

  static const Color red = Color(0xFFE8323C);
  static const Color redGlow = Color(0x33E8323C);
  static const Color redDim = Color(0xFF8B1D22);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberGlow = Color(0x33F59E0B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white05 = Color(0x0DFFFFFF);

  // ── API ─────────────────────────────────────────────────────
  static const String apiBase = 'https://safecar-backend.onrender.com';
  static const String stripeKey =
      'pk_live_51TNg9hJUWcw2TQhFw7mdxHFDOV6WsjsLgTQbFmHhybhiI4MtRxPpvYFWhpAO1VAFfal98asSYSU6cvTxP2WkCp9v00kl0jT7Qr';

  // ── Typography ───────────────────────────────────────────────
  static TextStyle display(double size,
          {FontWeight w = FontWeight.w800, Color color = white}) =>
      GoogleFonts.barlow(
          fontSize: size, fontWeight: w, color: color, letterSpacing: -0.5);

  static TextStyle mono(double size,
          {FontWeight w = FontWeight.w500, Color color = white}) =>
      GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: w, color: color);

  static TextStyle body(double size,
          {FontWeight w = FontWeight.w400, Color color = white80}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: color);

  // ── Theme Data ───────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: red,
          secondary: amber,
          surface: bgCard,
          onPrimary: white,
          onSurface: white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: display(18, w: FontWeight.w700),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgCard,
          selectedItemColor: red,
          unselectedItemColor: Color(0xFF4A5068),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: TextTheme(
          displayLarge: display(48),
          displayMedium: display(36),
          displaySmall: display(28),
          headlineMedium: display(22, w: FontWeight.w700),
          titleLarge: display(18, w: FontWeight.w600),
          bodyLarge: body(16),
          bodyMedium: body(14),
          labelSmall: mono(10, w: FontWeight.w600, color: white60),
        ),
        dividerColor: border,
        cardColor: bgCard,
      );
}
