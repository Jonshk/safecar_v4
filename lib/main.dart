import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hugeicons/hugeicons.dart';
import 'theme/app_theme.dart';
import 'services/cart_provider.dart';
import 'services/lang_provider.dart';
import 'services/fcm_service.dart';
import 'firebase_config.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/training_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/part_detail_screen.dart';
import 'screens/tow_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/body_shop_screen.dart';
import 'models/models.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Stripe.publishableKey = AppTheme.stripeKey;
  } catch (_) {}

  await Firebase.initializeApp(options: firebaseOptions);
  FcmService.init(navigatorKey);

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
      navigatorKey: navigatorKey,
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
  String? _shopCategory;

  void _navigate(int i, {String? category}) {
    setState(() {
      _idx = i;
      if (i == 1) _shopCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final lang = context.watch<LangProvider>();
    final s = lang.s;

    final screens = [
      HomeScreen(onNavigate: _navigate),
      ShopScreen(initialCategory: _shopCategory),
      const TrainingScreen(),
      const TowScreen(),
      const BookingScreen(),
      const CartScreen(),
      const ContactScreen(),
      const BodyShopScreen(),
    ];

    final navActive = [0, 1, 4, 2, 3, -1, -1, 5][_idx.clamp(0, 7)];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _idx == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                GestureDetector(
                  onTap: () => context.read<LangProvider>().toggle(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      lang.isEs ? '🇺🇸 EN' : '🇲🇽 ES',
                      style: AppTheme.mono(11, w: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            )
          : null,
      floatingActionButton: _idx != 5
          ? _CartFAB(count: cart.count, onTap: () => _navigate(5))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: s.navHome,
                  index: 0,
                  current: navActive,
                  onTap: (_) => _navigate(0),
                ),
                _NavItem(
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: s.navShop,
                  index: 1,
                  current: navActive,
                  onTap: (_) => _navigate(1),
                ),
                _HugeNavItem(
                  hugeIcon: HugeIcons.strokeRoundedTowTruck,
                  label: 'Tow',
                  index: 2,
                  current: navActive,
                  onTap: (_) => _navigate(3),
                ),
                _NavItem(
                  icon: Icons.build_circle_outlined,
                  activeIcon: Icons.build_circle_rounded,
                  label: 'Book',
                  index: 3,
                  current: navActive,
                  onTap: (_) => _navigate(4),
                ),
                _NavItem(
                  icon: Icons.car_crash_outlined,
                  activeIcon: Icons.car_crash_rounded,
                  label: s.isEs ? 'Carrocería' : 'Body Shop',
                  index: 5,
                  current: navActive,
                  onTap: (_) => _navigate(7),
                ),
                _NavItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school_rounded,
                  label: s.navTraining,
                  index: 4,
                  current: navActive,
                  onTap: (_) => _navigate(2),
                ),
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
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.redGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(active ? activeIcon : icon,
              color: active ? AppTheme.red : AppTheme.white30, size: 22),
          const SizedBox(height: 3),
          Text(label,
              style: AppTheme.mono(9,
                  w: FontWeight.w600,
                  color: active ? AppTheme.red : AppTheme.white30)),
        ]),
      ),
    );
  }
}

class _HugeNavItem extends StatelessWidget {
  final IconData hugeIcon;
  final String label;
  final int index, current;
  final void Function(int) onTap;

  const _HugeNavItem({
    required this.hugeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.redGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          HugeIcon(
            icon: hugeIcon,
            color: active ? AppTheme.red : AppTheme.white30,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(label,
              style: AppTheme.mono(9,
                  w: FontWeight.w600,
                  color: active ? AppTheme.red : AppTheme.white30)),
        ]),
      ),
    );
  }
}

class _CartFAB extends StatefulWidget {
  final int count;
  final VoidCallback onTap;
  const _CartFAB({required this.count, required this.onTap});
  @override
  State<_CartFAB> createState() => _CartFABState();
}

class _CartFABState extends State<_CartFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.28)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.28, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 60),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_CartFAB old) {
    super.didUpdateWidget(old);
    if (widget.count != _prevCount && widget.count > 0) _ctrl.forward(from: 0);
    _prevCount = widget.count;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppTheme.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppTheme.red.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Stack(alignment: Alignment.center, children: [
              const Icon(Icons.shopping_bag_rounded,
                  color: Colors.white, size: 28),
              if (widget.count > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                        child: Text(
                      widget.count > 9 ? '9+' : '${widget.count}',
                      style: const TextStyle(
                          color: AppTheme.red,
                          fontSize: 9,
                          fontWeight: FontWeight.w900),
                    )),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
