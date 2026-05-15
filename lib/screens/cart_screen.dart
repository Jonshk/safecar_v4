import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/cart_provider.dart';
import '../services/lang_provider.dart';
import '../models/models.dart';
import '../widgets/shared.dart';
import '../services/api_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(child: cart.isEmpty ? _buildEmpty(context, s) : _buildCart(context, cart, s)),
    );
  }

  Widget _buildEmpty(BuildContext context, s) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 88, height: 88,
        decoration: BoxDecoration(color: AppTheme.bgCard, shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border)),
        child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.white30, size: 38)),
      const SizedBox(height: 20),
      Text(s.cartEmpty, style: AppTheme.display(20, w: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(s.cartEmptySub, style: AppTheme.body(14, color: AppTheme.white60)),
    ]).animate().fadeIn(duration: 400.ms),
  );

  Widget _buildCart(BuildContext context, CartProvider cart, s) {
    final itemCount = cart.count;
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.cartTag, style: AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
            Text('$itemCount ${itemCount == 1 ? s.cartItem : s.cartItems}',
              style: AppTheme.display(24, w: FontWeight.w800)),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () => _confirmClear(context, cart, s),
            child: Text(s.cartClearAll, style: AppTheme.mono(12, color: AppTheme.white30))),
        ])),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cart.items.length,
        itemBuilder: (ctx, i) => _buildItem(ctx, cart.items[i], cart, i, s),
      )),
      _buildSummary(context, cart, s),
    ]);
  }

  Widget _buildItem(BuildContext context, CartItem item, CartProvider cart, int i, s) {
    return Dismissible(
      key: Key('cart_${item.part.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppTheme.redDim, borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24)),
      onDismissed: (_) => cart.remove(item.part.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12),
            child: NetImage(item.part.displayImage, w: 70, h: 70)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.part.name, style: AppTheme.display(13, w: FontWeight.w700),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text('\$${item.part.price.toStringAsFixed(2)} ${s.cartSubtotal == 'Subtotal' ? 'each' : 'c/u'}',
              style: AppTheme.mono(11, color: AppTheme.white60)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${item.subtotal.toStringAsFixed(2)}',
              style: AppTheme.mono(15, w: FontWeight.w800, color: AppTheme.red)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _qtyBtn(Icons.remove_rounded, () => cart.decrement(item.part.id)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('${item.qty}', style: AppTheme.mono(13, w: FontWeight.w700))),
                _qtyBtn(Icons.add_rounded, () => cart.add(item.part)),
              ]),
            ),
          ]),
        ]),
      ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn(duration: 350.ms).slideX(begin: -0.05, end: 0),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: SizedBox(width: 30, height: 30, child: Center(child: Icon(icon, size: 16, color: AppTheme.white60))),
  );

  Widget _buildSummary(BuildContext context, CartProvider cart, s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(color: AppTheme.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.cartSubtotal, style: AppTheme.body(14, color: AppTheme.white60)),
          Text('\$${cart.total.toStringAsFixed(2)}', style: AppTheme.mono(15, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.cartShipping, style: AppTheme.body(14, color: AppTheme.white60)),
          Text(s.cartShippingTbd, style: AppTheme.mono(14, color: AppTheme.white60)),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: AppTheme.border)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.cartTotal, style: AppTheme.display(16, w: FontWeight.w800)),
          Text('\$${cart.total.toStringAsFixed(2)}', style: AppTheme.mono(22, w: FontWeight.w800, color: AppTheme.red)),
        ]),
        const SizedBox(height: 16),
        RedButton(label: s.cartRequestQuote, icon: Icons.send_outlined,
          onTap: () => _showCheckout(context, cart, s)),
      ]),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart, s) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(s.cartClearTitle, style: AppTheme.display(18, w: FontWeight.w700)),
      content: Text(s.cartClearSub, style: AppTheme.body(14, color: AppTheme.white60)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: AppTheme.body(14, color: AppTheme.white60))),
        TextButton(onPressed: () { cart.clear(); Navigator.pop(context); },
          child: Text(s.clear, style: AppTheme.body(14, color: AppTheme.red))),
      ],
    ));
  }

  void _showCheckout(BuildContext context, CartProvider cart, s) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cart),
        ChangeNotifierProvider.value(value: context.read<LangProvider>()),
      ],
      child: _CheckoutScreen(cart: cart),
    )));
  }
}

class _CheckoutScreen extends StatefulWidget {
  final CartProvider cart;
  const _CheckoutScreen({required this.cart});
  @override
  State<_CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<_CheckoutScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _msg = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() { _name.dispose(); _email.dispose(); _phone.dispose(); _msg.dispose(); super.dispose(); }

  Future<void> _send(s) async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final partsList = widget.cart.items.map((i) => '${i.qty}x ${i.part.name}').join(', ');
    final ok = await ApiService.sendQuote(QuoteRequest(
      name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim(),
      message: '${_msg.text.trim()}\n\nCart: $partsList\nTotal: \$${widget.cart.total.toStringAsFixed(2)}'));
    if (!mounted) return;
    setState(() { _sending = false; _sent = ok; });
    if (ok) widget.cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        leading: GestureDetector(onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18)),
        title: Text(s.checkoutTitle, style: AppTheme.mono(13, w: FontWeight.w700)),
      ),
      body: _sent ? _buildSuccess(s) : _buildForm(s),
    );
  }

  Widget _buildSuccess(s) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 90, height: 90,
      decoration: const BoxDecoration(color: Color(0xFF00C47A22), shape: BoxShape.circle),
      child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00C47A), size: 44),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
    const SizedBox(height: 20),
    Text(s.checkoutSuccessTitle, style: AppTheme.display(26, w: FontWeight.w800)),
    const SizedBox(height: 10),
    Text(s.checkoutSuccessSub, style: AppTheme.body(15, color: AppTheme.white60)),
  ]));

  Widget _buildForm(s) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _field(_name, s.checkoutName, Icons.person_outline_rounded),
      const SizedBox(height: 12),
      _field(_email, s.checkoutEmail, Icons.email_outlined, type: TextInputType.emailAddress),
      const SizedBox(height: 12),
      _field(_phone, s.checkoutPhone, Icons.phone_outlined, type: TextInputType.phone),
      const SizedBox(height: 12),
      _field(_msg, s.checkoutMessage, Icons.message_outlined, maxLines: 3),
      const SizedBox(height: 24),
      RedButton(label: s.checkoutSend, icon: Icons.send_rounded, onTap: () => _send(s), loading: _sending),
    ]),
  );

  Widget _field(TextEditingController c, String hint, IconData icon,
      {TextInputType type = TextInputType.text, int maxLines = 1}) =>
    Container(
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border)),
      child: TextField(controller: c, keyboardType: type, maxLines: maxLines, style: AppTheme.body(14),
        decoration: InputDecoration(hintText: hint, hintStyle: AppTheme.body(14, color: AppTheme.white30),
          prefixIcon: Icon(icon, color: AppTheme.white30, size: 20), border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
    );
}
