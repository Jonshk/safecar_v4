import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../theme/app_theme.dart';
import '../services/cart_provider.dart';
import '../services/lang_provider.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../widgets/shared.dart';

// ══════════════════════════════════════════════════════════════════
// CART SCREEN
// ══════════════════════════════════════════════════════════════════
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: cart.isEmpty ? _buildEmpty(s) : _buildCart(context, cart, s),
      ),
    );
  }

  Widget _buildEmpty(s) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border)),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: AppTheme.white30, size: 38)),
          const SizedBox(height: 20),
          Text(s.cartEmpty, style: AppTheme.display(20, w: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(s.cartEmptySub,
              style: AppTheme.body(14, color: AppTheme.white60)),
        ]).animate().fadeIn(duration: 400.ms),
      );

  Widget _buildCart(BuildContext context, CartProvider cart, s) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.cartTag,
                style:
                    AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
            Text('${cart.count} ${cart.count == 1 ? s.cartItem : s.cartItems}',
                style: AppTheme.display(24, w: FontWeight.w800)),
          ]),
          const Spacer(),
          GestureDetector(
              onTap: () => _confirmClear(context, cart, s),
              child: Text(s.cartClearAll,
                  style: AppTheme.mono(12, color: AppTheme.white30))),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cart.items.length,
          itemBuilder: (ctx, i) => _buildItem(ctx, cart.items[i], cart, i),
        ),
      ),
      _buildSummary(context, cart, s),
    ]);
  }

  Widget _buildItem(
      BuildContext context, CartItem item, CartProvider cart, int i) {
    return Dismissible(
      key: Key('cart_${item.part.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: AppTheme.redDim, borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 24)),
      onDismissed: (_) => cart.remove(item.part.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border)),
        child: Row(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetImage(item.part.displayImage, w: 70, h: 70)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.part.name,
                    style: AppTheme.display(13, w: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('\$${item.part.price.toStringAsFixed(2)} c/u',
                    style: AppTheme.mono(11, color: AppTheme.white60)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${item.subtotal.toStringAsFixed(2)}',
                style:
                    AppTheme.mono(15, w: FontWeight.w800, color: AppTheme.red)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _qtyBtn(
                    Icons.remove_rounded, () => cart.decrement(item.part.id)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.qty}',
                        style: AppTheme.mono(13, w: FontWeight.w700))),
                _qtyBtn(Icons.add_rounded, () => cart.add(item.part)),
              ]),
            ),
          ]),
        ]),
      ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn(duration: 350.ms),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
            width: 30,
            height: 30,
            child:
                Center(child: Icon(icon, size: 16, color: AppTheme.white60))),
      );

  Widget _buildSummary(BuildContext context, CartProvider cart, s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.border))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.cartSubtotal,
              style: AppTheme.body(14, color: AppTheme.white60)),
          Text('\$${cart.total.toStringAsFixed(2)}',
              style: AppTheme.mono(15, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.cartShipping,
              style: AppTheme.body(14, color: AppTheme.white60)),
          Text('TBD', style: AppTheme.mono(14, color: AppTheme.white60)),
        ]),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppTheme.border)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('TOTAL', style: AppTheme.display(16, w: FontWeight.w800)),
          Text('\$${cart.total.toStringAsFixed(2)}',
              style:
                  AppTheme.mono(22, w: FontWeight.w800, color: AppTheme.red)),
        ]),
        const SizedBox(height: 16),
        RedButton(
          label: s.isEs ? 'PROCEDER AL PAGO' : 'PROCEED TO CHECKOUT',
          icon: Icons.arrow_forward_rounded,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiProvider(providers: [
                  ChangeNotifierProvider.value(value: cart),
                  ChangeNotifierProvider.value(
                      value: context.read<LangProvider>()),
                ], child: CheckoutScreen(cart: cart)),
              )),
        ),
      ]),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart, s) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: AppTheme.bgCard,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(s.cartClearTitle,
                  style: AppTheme.display(18, w: FontWeight.w700)),
              content: Text(s.cartClearSub,
                  style: AppTheme.body(14, color: AppTheme.white60)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(s.cancel,
                        style: AppTheme.body(14, color: AppTheme.white60))),
                TextButton(
                    onPressed: () {
                      cart.clear();
                      Navigator.pop(context);
                    },
                    child: Text(s.clear,
                        style: AppTheme.body(14, color: AppTheme.red))),
              ],
            ));
  }
}

// ══════════════════════════════════════════════════════════════════
// CHECKOUT SCREEN
// ══════════════════════════════════════════════════════════════════
class CheckoutScreen extends StatefulWidget {
  final CartProvider cart;
  const CheckoutScreen({super.key, required this.cart});
  @override
  State<CheckoutScreen> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  String _method = 'zelle';
  bool _loading = false;
  Map<String, dynamic>? _orderResult;
  Map<String, dynamic>? _instructions;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  // ── Crear orden ──────────────────────────────────────────────
  Future<void> _placeOrder() async {
    final s = context.read<LangProvider>().s;
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      _snack(
          s.isEs
              ? 'Completa nombre, email y telefono'
              : 'Fill name, email and phone',
          isError: true);
      return;
    }
    setState(() => _loading = true);

    final req = OrderRequest(
      customerName: _name.text.trim(),
      customerEmail: _email.text.trim(),
      customerPhone: _phone.text.trim(),
      shippingAddress: _address.text.trim().isEmpty
          ? 'Pickup in store'
          : _address.text.trim(),
      paymentMethod: _method,
      items: widget.cart.items
          .map((i) => OrderItem(partId: i.part.id, quantity: i.qty))
          .toList(),
    );

    final result = await ApiService.createOrder(req);
    if (!mounted) return;

    if (result == null) {
      setState(() => _loading = false);
      _snack(
          context.read<LangProvider>().s.isEs
              ? 'Error al crear la orden'
              : 'Error creating order',
          isError: true);
      return;
    }

    // Tarjeta → Stripe Payment Sheet
    if (_method == 'card') {
      await _stripePayment(result);
      return;
    }

    // Zelle / Transferencia → instrucciones
    final instr = await ApiService.getPaymentInstructions(result['id']);
    widget.cart.clear();
    if (mounted) {
      setState(() {
        _loading = false;
        _orderResult = result;
        _instructions = instr;
      });
    }
  }

  // ── Stripe Payment Sheet ─────────────────────────────────────
  Future<void> _stripePayment(Map<String, dynamic> order) async {
    final s = context.read<LangProvider>().s;

    // En web no hay Stripe nativo - mostrar instrucciones manuales
    if (kIsWeb) {
      widget.cart.clear();
      if (mounted) {
        setState(() {
          _loading = false;
          _orderResult = order;
          _instructions = {'method': 'card', 'paid': false};
        });
      }
      return;
    }

    try {
      final intent = await ApiService.createPaymentIntent(order['id']);
      if (intent == null) throw Exception('No intent');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent['client_secret'],
          merchantDisplayName: 'Safe Car Automotive',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFE8323C),
              background: Color(0xFF0E1118),
              componentBackground: Color(0xFF1A1E2A),
            ),
            shapes: PaymentSheetShape(borderRadius: 14),
          ),
          billingDetails: BillingDetails(
            name: order['customer_name'],
            email: order['customer_email'],
            phone: order['customer_phone'],
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      widget.cart.clear();
      if (mounted) {
        setState(() {
          _loading = false;
          _orderResult = order;
          _instructions = {'method': 'card', 'paid': true};
        });
      }
    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (e.error.code != FailureCode.Canceled) {
        _snack(
            '${s.isEs ? "Error de pago" : "Payment error"}: ${e.error.localizedMessage}',
            isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(s.isEs ? 'Error procesando pago' : 'Error processing payment',
          isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: AppTheme.body(13, color: AppTheme.white)),
        backgroundColor: isError ? AppTheme.redDim : AppTheme.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18)),
        title: Text(
            _orderResult != null
                ? (s.isEs ? 'ORDEN CONFIRMADA' : 'ORDER CONFIRMED')
                : (s.isEs ? 'CHECKOUT' : 'CHECKOUT'),
            style: AppTheme.mono(13, w: FontWeight.w700)),
      ),
      body: _orderResult != null ? _buildSuccess(s) : _buildForm(s),
    );
  }

  // ── Formulario ───────────────────────────────────────────────
  Widget _buildForm(s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cartSummary(),
        const SizedBox(height: 24),
        Text(s.isEs ? 'TUS DATOS' : 'YOUR INFO',
            style: AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
        const SizedBox(height: 12),
        _field(_name, s.checkoutName, Icons.person_outline_rounded),
        const SizedBox(height: 10),
        _field(_email, s.checkoutEmail, Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _field(_phone, s.checkoutPhone, Icons.phone_outlined,
            type: TextInputType.phone),
        const SizedBox(height: 10),
        _field(
            _address,
            s.isEs
                ? 'Dirección de envío (opcional)'
                : 'Shipping address (optional)',
            Icons.location_on_outlined,
            maxLines: 2),
        const SizedBox(height: 24),
        Text(s.isEs ? 'MÉTODO DE PAGO' : 'PAYMENT METHOD',
            style: AppTheme.mono(11, color: AppTheme.red, w: FontWeight.w700)),
        const SizedBox(height: 12),
        _paymentOption('zelle', 'Zelle', Icons.phone_android_outlined,
            '+1 (872) 361-1607'),
        const SizedBox(height: 8),
        _paymentOption(
            'bank_transfer',
            s.isEs ? 'Transferencia Bancaria' : 'Bank Transfer',
            Icons.account_balance_outlined,
            'Citi Bank — Rodolfo Merecuane'),
        const SizedBox(height: 8),
        _paymentOption(
            'card',
            s.isEs ? 'Tarjeta Crédito/Débito' : 'Credit/Debit Card',
            Icons.credit_card_outlined,
            'Visa · Mastercard · Amex · Discover'),
        const SizedBox(height: 28),
        RedButton(
          label: s.isEs ? 'CONFIRMAR ORDEN' : 'CONFIRM ORDER',
          icon: Icons.check_circle_outline_rounded,
          onTap: _placeOrder,
          loading: _loading,
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _cartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border)),
      child: Column(children: [
        ...widget.cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                    child: Text('${item.qty}x ${item.part.name}',
                        style: AppTheme.body(13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                Text('\$${item.subtotal.toStringAsFixed(2)}',
                    style: AppTheme.mono(13,
                        w: FontWeight.w700, color: AppTheme.red)),
              ]),
            )),
        const Divider(color: AppTheme.border),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('TOTAL', style: AppTheme.display(15, w: FontWeight.w800)),
          Text('\$${widget.cart.total.toStringAsFixed(2)}',
              style:
                  AppTheme.mono(18, w: FontWeight.w800, color: AppTheme.red)),
        ]),
      ]),
    );
  }

  Widget _paymentOption(String value, String label, IconData icon, String sub) {
    final selected = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: selected ? AppTheme.redGlow : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? AppTheme.red : AppTheme.border,
                width: selected ? 1.5 : 1)),
        child: Row(children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: selected ? AppTheme.red : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon,
                  color: selected ? Colors.white : AppTheme.white60, size: 20)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label, style: AppTheme.display(14, w: FontWeight.w700)),
                Text(sub, style: AppTheme.body(11, color: AppTheme.white60)),
              ])),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.red, size: 22),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
          {TextInputType type = TextInputType.text, int maxLines = 1}) =>
      Container(
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border)),
        child: TextField(
            controller: c,
            keyboardType: type,
            maxLines: maxLines,
            style: AppTheme.body(14),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTheme.body(14, color: AppTheme.white30),
                prefixIcon: Icon(icon, color: AppTheme.white30, size: 20),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
      );

  // ── Pantalla de éxito ────────────────────────────────────────
  Widget _buildSuccess(s) {
    final ref = _orderResult!['reference'] ?? '';
    final total = _orderResult!['total']?.toString() ?? '';
    final method = _orderResult!['payment_method'] ?? '';
    final cardPaid = _instructions?['paid'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
              color: Color(0xff00c47a22), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline_rounded,
              color: Color(0xFF00C47A), size: 50),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(s.isEs ? '¡Orden Creada!' : 'Order Created!',
            style: AppTheme.display(26, w: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('REF: $ref',
            style: AppTheme.mono(13, color: AppTheme.red, w: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Total: \$$total', style: AppTheme.mono(16, w: FontWeight.w700)),
        const SizedBox(height: 28),

        // Instrucciones según método
        if (method == 'card' && cardPaid)
          _cardSuccess(s)
        else if (method == 'card')
          _cardPending(s)
        else if (_instructions != null)
          _transferInstructions(s, _instructions!),

        const SizedBox(height: 20),
        // Copiar referencia
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: ref));
            _snack(s.isEs ? 'Referencia copiada' : 'Reference copied');
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.copy_outlined,
                  color: AppTheme.white60, size: 16),
              const SizedBox(width: 8),
              Text('${s.isEs ? "Copiar ref" : "Copy ref"}: $ref',
                  style: AppTheme.mono(12, color: AppTheme.white60)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        // WhatsApp
        GestureDetector(
          onTap: () {
            final msg = Uri.encodeComponent(s.isEs
                ? 'Hola! Pedido en Safe Car.\nRef: $ref\nTotal: \$$total\nMetodo: $method'
                : 'Hi! Order at Safe Car.\nRef: $ref\nTotal: \$$total\nMethod: $method');
            launchUrl(Uri.parse('https://wa.me/18723545706?text=$msg'),
                mode: LaunchMode.externalApplication);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF075E54), Color(0xFF128C7E)]),
                borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.chat_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(s.isEs ? 'Confirmar por WhatsApp' : 'Confirm via WhatsApp',
                  style: AppTheme.display(14, w: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _cardSuccess(s) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xff00c47a11),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: const Color(0xFF00C47A).withOpacity(0.3))),
        child: Column(children: [
          const Icon(Icons.verified_outlined,
              color: Color(0xFF00C47A), size: 40),
          const SizedBox(height: 10),
          Text(s.isEs ? 'Pago Confirmado' : 'Payment Confirmed',
              style: AppTheme.display(18,
                  w: FontWeight.w800, color: const Color(0xFF00C47A))),
          const SizedBox(height: 6),
          Text(
              s.isEs
                  ? 'Tu tarjeta fue procesada exitosamente.'
                  : 'Your card was processed successfully.',
              textAlign: TextAlign.center,
              style: AppTheme.body(13, color: AppTheme.white60)),
        ]),
      );

  Widget _cardPending(s) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border)),
        child: Column(children: [
          const Icon(Icons.credit_card_outlined, color: AppTheme.red, size: 36),
          const SizedBox(height: 10),
          Text(s.isEs ? 'Pago con Tarjeta' : 'Card Payment',
              style: AppTheme.display(16, w: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
              s.isEs
                  ? 'Te contactaremos para procesar el pago de forma segura.'
                  : 'We will contact you to process your payment securely.',
              textAlign: TextAlign.center,
              style: AppTheme.body(13, color: AppTheme.white60)),
        ]),
      );

  Widget _transferInstructions(s, Map<String, dynamic> data) {
    final method = data['method'] as String;
    final instructions = (data['instructions'] as List?)?.cast<String>() ?? [];
    final isZelle = method == 'zelle';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.amber.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
              isZelle
                  ? Icons.phone_android_outlined
                  : Icons.account_balance_outlined,
              color: AppTheme.amber,
              size: 24),
          const SizedBox(width: 10),
          Text(isZelle ? 'ZELLE' : 'BANK TRANSFER',
              style:
                  AppTheme.mono(13, w: FontWeight.w800, color: AppTheme.amber)),
        ]),
        const SizedBox(height: 14),
        ...instructions.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.arrow_right_rounded,
                    color: AppTheme.red, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(line, style: AppTheme.body(13))),
              ]),
            )),
        const SizedBox(height: 10),
        // Botón copiar cuenta (banco) o enviar por WA (zelle)
        if (!isZelle && data['account'] != null)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: data['account']));
              _snack(s.isEs ? 'Número copiado' : 'Number copied');
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.isEs ? 'Número de cuenta' : 'Account number',
                              style: AppTheme.mono(9, color: AppTheme.white30)),
                          Text(data['account'],
                              style: AppTheme.mono(15, w: FontWeight.w800)),
                        ]),
                    const Icon(Icons.copy_outlined,
                        color: AppTheme.white30, size: 18),
                  ]),
            ),
          ),
        if (isZelle)
          GestureDetector(
            onTap: () {
              final ref = _orderResult!['reference'] ?? '';
              final total = _orderResult!['total']?.toString() ?? '';
              final msg = Uri.encodeComponent(
                  'Zelle payment for order $ref - \$$total');
              launchUrl(Uri.parse('https://wa.me/18723611607?text=$msg'),
                  mode: LaunchMode.externalApplication);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF075E54), Color(0xFF128C7E)]),
                  borderRadius: BorderRadius.circular(10)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.send_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                    s.isEs
                        ? 'Enviar comprobante por WhatsApp'
                        : 'Send proof via WhatsApp',
                    style: AppTheme.mono(12, w: FontWeight.w700)),
              ]),
            ),
          ),
      ]),
    );
  }
}
