import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/cart_provider.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';

class PartDetailScreen extends StatelessWidget {
  final Part part;
  const PartDetailScreen({super.key, required this.part});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final s = context.watch<LangProvider>().s;
    final inCart = cart.contains(part.id);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 300,
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
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppTheme.bg.withOpacity(0.8),
                          shape: BoxShape.circle),
                      child: const Padding(
                          padding: EdgeInsets.all(8), child: CartIconBadge())))
            ],
            flexibleSpace: FlexibleSpaceBar(
                background: part.displayImage.isNotEmpty
                    ? NetImage(part.displayImage, w: double.infinity)
                    : Container(
                        color: AppTheme.bgCard,
                        child: const Icon(Icons.car_repair_outlined,
                            color: AppTheme.white30, size: 64))),
          ),
          SliverToBoxAdapter(
              child: Container(
            decoration: const BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (part.category != null)
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.border)),
                            child: Text(part.category!.toUpperCase(),
                                style: AppTheme.mono(10,
                                    color: AppTheme.white60,
                                    w: FontWeight.w700))),
                      const Spacer(),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: part.inStock
                                  ? const Color(0xff00c47a22)
                                  : AppTheme.redGlow,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: part.inStock
                                        ? const Color(0xFF00C47A)
                                        : AppTheme.red)),
                            const SizedBox(width: 5),
                            Text(part.inStock ? s.shopInStock : s.shopOutStock,
                                style: AppTheme.mono(10,
                                    w: FontWeight.w700,
                                    color: part.inStock
                                        ? const Color(0xFF00C47A)
                                        : AppTheme.red)),
                          ])),
                    ]).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    Text(part.name,
                            style: AppTheme.display(26, w: FontWeight.w900))
                        .animate()
                        .fadeIn(delay: 150.ms)
                        .slideY(begin: 0.1, end: 0),
                    if (part.sku != null) ...[
                      const SizedBox(height: 6),
                      Text('SKU: ${part.sku}',
                          style: AppTheme.mono(12, color: AppTheme.white30)),
                    ],
                    const SizedBox(height: 20),
                    Text('\$${part.price.toStringAsFixed(2)}',
                            style: AppTheme.mono(38,
                                w: FontWeight.w800, color: AppTheme.red))
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: AppTheme.border)),
                    Text(s.detailDescription,
                        style: AppTheme.mono(10,
                            color: AppTheme.white30, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(part.description,
                            style: AppTheme.body(15, color: AppTheme.white80))
                        .animate(delay: 250.ms)
                        .fadeIn(),
                    if (part.stock != null) ...[
                      const SizedBox(height: 24),
                      Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border)),
                          child: Row(children: [
                            const Icon(Icons.inventory_2_outlined,
                                color: AppTheme.white60, size: 18),
                            const SizedBox(width: 10),
                            Text('${part.stock} ${s.detailUnitsAvailable}',
                                style:
                                    AppTheme.body(14, color: AppTheme.white60)),
                          ])),
                    ],
                  ]),
            ),
          )),
        ]),
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
                Expanded(
                    child: RedButton(
                  label: inCart ? s.detailAdded : s.detailAddCart,
                  icon: inCart ? null : Icons.shopping_bag_outlined,
                  onTap: part.inStock
                      ? () {
                          context.read<CartProvider>().add(part);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${part.name} ${s.detailAddedSnack}',
                                style:
                                    AppTheme.body(13, color: AppTheme.white)),
                            backgroundColor: AppTheme.bgElevated,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 1),
                          ));
                        }
                      : null,
                ))
              ]),
            )),
      ]),
    );
  }
}
