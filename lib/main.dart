import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/app_theme.dart';
import 'services/cart_provider.dart';
import 'services/lang_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/training_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/part_detail_screen.dart';
import 'models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bgCard,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LangProvider()),
      ],
      child: const SafeCarApp(),
    ),
  );
}

class SafeCarApp extends StatelessWidget {
  const SafeCarApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Car Automotive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AppEntry(),
      onGenerateRoute: (settings) {
        if (settings.name == '/part') {
          final part = settings.arguments as Part;
          return MaterialPageRoute(
            builder: (_) => PartDetailScreen(part: part),
          );
        }
        return null;
      },
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();
  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _ready = false;
  void _onSplashDone() => setState(() => _ready = true);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: _ready
          ? const MainShell(key: ValueKey('main'))
          : SplashScreen(key: const ValueKey('splash'), onDone: _onSplashDone),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  void _navigate(int i) => setState(() => _idx = i);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final lang = context.watch<LangProvider>();
    final s = lang.s;

    final screens = [
      HomeScreen(onNavigate: _navigate),
      const ShopScreen(),
      const TrainingScreen(),
      const CartScreen(),
      const ContactScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(index: _idx, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: s.navHome, index: 0, current: _idx, onTap: _navigate),
                _NavItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: s.navShop, index: 1, current: _idx, onTap: _navigate),
                _NavItem(icon: Icons.school_outlined, activeIcon: Icons.school_rounded, label: s.navTraining, index: 2, current: _idx, onTap: _navigate),
                _CartNavItem(current: _idx, onTap: _navigate, count: cart.count, label: s.navCart),
                _NavItem(icon: Icons.phone_outlined, activeIcon: Icons.phone_rounded, label: s.navContact, index: 4, current: _idx, onTap: _navigate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final Function(int) onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.redGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(active ? activeIcon : icon, color: active ? AppTheme.red : AppTheme.white30, size: 22),
          const SizedBox(height: 3),
          Text(label, style: AppTheme.mono(9, w: FontWeight.w600, color: active ? AppTheme.red : AppTheme.white30)),
        ]),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final int current, count;
  final Function(int) onTap;
  final String label;
  const _CartNavItem({required this.current, required this.onTap, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final active = current == 3;
    return GestureDetector(
      onTap: () => onTap(3),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.redGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(active ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
              color: active ? AppTheme.red : AppTheme.white30, size: 22),
            if (count > 0)
              Positioned(top: -4, right: -4,
                child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(color: AppTheme.red, shape: BoxShape.circle),
                  child: Center(child: Text('$count', style: AppTheme.mono(8, w: FontWeight.w800))),
                ).animate().scale(duration: 200.ms, curve: Curves.elasticOut)),
          ]),
          const SizedBox(height: 3),
          Text(label, style: AppTheme.mono(9, w: FontWeight.w600, color: active ? AppTheme.red : AppTheme.white30)),
        ]),
      ),
    );
  }
}
