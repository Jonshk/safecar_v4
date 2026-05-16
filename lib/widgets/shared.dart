import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/cart_provider.dart';
import 'package:provider/provider.dart';

// ── Shimmer Placeholder ──────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double w, h;
  final double radius;
  const ShimmerBox(
      {super.key, required this.w, required this.h, this.radius = 12});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppTheme.bgElevated,
        highlightColor: AppTheme.surface,
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: AppTheme.bgElevated,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
}

// ── Network Image ────────────────────────────────────────────────
class NetImage extends StatelessWidget {
  final String url;
  final double? w, h;
  final BoxFit fit;
  final BorderRadius? radius;

  const NetImage(this.url,
      {super.key, this.w, this.h, this.fit = BoxFit.cover, this.radius});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url,
        width: w,
        height: h,
        fit: fit,
        placeholder: (_, __) => ShimmerBox(w: w ?? 100, h: h ?? 100),
        errorWidget: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: w,
        height: h,
        color: AppTheme.bgElevated,
        child: const Icon(Icons.car_repair_outlined,
            color: AppTheme.white30, size: 28),
      );
}

// ── Part Card ────────────────────────────────────────────────────
class PartCard extends StatelessWidget {
  final Part part;
  final VoidCallback onTap;
  final int index;

  const PartCard(
      {super.key, required this.part, required this.onTap, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.contains(part.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  NetImage(
                    part.displayImage,
                    w: double.infinity,
                    h: 130,
                  ),
                  // Stock badge
                  if (!part.inStock)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _badge('OUT OF STOCK', AppTheme.redDim),
                    ),
                  // Category badge
                  if (part.category != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _badge(
                          part.category!.toUpperCase(), AppTheme.surface),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.name,
                    style: AppTheme.display(14, w: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${part.price.toStringAsFixed(2)}',
                        style: AppTheme.mono(18,
                            w: FontWeight.w700, color: AppTheme.red),
                      ),
                      _AddBtn(part: part, inCart: inCart),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _badge(String text, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style:
                AppTheme.mono(9, w: FontWeight.w700, color: AppTheme.white80)),
      );
}

class _AddBtn extends StatefulWidget {
  final Part part;
  final bool inCart;
  const _AddBtn({required this.part, required this.inCart});

  @override
  State<_AddBtn> createState() => _AddBtnState();
}

class _AddBtnState extends State<_AddBtn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return GestureDetector(
      onTap: () {
        _ctrl.forward().then((_) => _ctrl.reverse());
        cart.add(widget.part);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.part.name} added to cart',
                style: AppTheme.body(13, color: AppTheme.white)),
            backgroundColor: AppTheme.bgElevated,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: 1.0 - (_ctrl.value * 0.15),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.inCart ? AppTheme.redGlow : AppTheme.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.inCart ? Icons.check_rounded : Icons.add_rounded,
              color: AppTheme.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Course Card ─────────────────────────────────────────────────
class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final int index;

  const CourseCard(
      {super.key, required this.course, required this.onTap, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(20)),
              child: NetImage(course.imageUrl ?? '', w: 110, h: 110),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (course.level != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.amberGlow,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(course.level!.toUpperCase(),
                            style: AppTheme.mono(8,
                                w: FontWeight.w700, color: AppTheme.amber)),
                      ),
                    Text(course.title,
                        style: AppTheme.display(14, w: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (course.duration != null)
                          Row(children: [
                            const Icon(Icons.schedule_outlined,
                                size: 13, color: AppTheme.white60),
                            const SizedBox(width: 4),
                            Text(course.duration!,
                                style:
                                    AppTheme.body(12, color: AppTheme.white60)),
                          ]),
                        if (course.price != null)
                          Text('\$${course.price!.toStringAsFixed(0)}',
                              style: AppTheme.mono(15,
                                  w: FontWeight.w700, color: AppTheme.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

// ── Red Button ───────────────────────────────────────────────────
class RedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  final double radius;

  const RedButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.icon,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.red,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
                color: AppTheme.redGlow, blurRadius: 20, offset: Offset(0, 6))
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppTheme.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: AppTheme.display(15, w: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader(
      {super.key, required this.label, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTheme.display(18, w: FontWeight.w700)),
          ],
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style:
                    AppTheme.mono(12, color: AppTheme.red, w: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ── Cart Badge Icon ──────────────────────────────────────────────
class CartIconBadge extends StatelessWidget {
  const CartIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().count;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_bag_outlined, size: 26),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                  color: AppTheme.red, shape: BoxShape.circle),
              child: Center(
                  child: Text('$count',
                      style: AppTheme.mono(9, w: FontWeight.w800))),
            ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
          ),
      ],
    );
  }
}
