import 'package:flutter/material.dart';

class AppStrings {
  final String lang;
  const AppStrings._(this.lang);

  static const en = AppStrings._('en');
  static const es = AppStrings._('es');

  bool get isEs => lang == 'es';

  // ── General ──────────────────────────────────────────────────
  String get appName => 'Safe Car Automotive';
  String get chicago => 'CHICAGO, IL · EST. 2012';
  String get seeAll => isEs ? 'VER TODO →' : 'SEE ALL →';
  String get pullRefresh => isEs ? 'Desliza para actualizar' : 'Pull to refresh';
  String get loading => isEs ? 'Cargando...' : 'Loading...';
  String get noResults => isEs ? 'Sin resultados' : 'No results';
  String get retry => isEs ? 'Reintentar' : 'Retry';
  String get cancel => isEs ? 'Cancelar' : 'Cancel';
  String get send => isEs ? 'ENVIAR' : 'SEND';
  String get close => isEs ? 'Cerrar' : 'Close';
  String get clear => isEs ? 'Limpiar' : 'Clear';

  // ── Splash ───────────────────────────────────────────────────
  String get splashConnecting => isEs ? 'CONECTANDO...' : 'CONNECTING...';
  String get splashOnline => isEs ? 'SERVIDOR EN LÍNEA ✓' : 'SERVER ONLINE ✓';
  String get splashOffline => isEs ? 'MODO OFFLINE' : 'OFFLINE MODE';
  String get splashLoading => isEs ? 'CARGANDO...' : 'LOADING...';
  String get splashReady => isEs ? 'LISTO' : 'READY';

  // ── Nav ──────────────────────────────────────────────────────
  String get navHome => isEs ? 'Inicio' : 'Home';
  String get navShop => isEs ? 'Tienda' : 'Shop';
  String get navTraining => isEs ? 'Cursos' : 'Training';
  String get navCart => isEs ? 'Carrito' : 'Cart';
  String get navContact => isEs ? 'Contacto' : 'Contact';

  // ── Home ─────────────────────────────────────────────────────
  String get homeTagline => isEs
      ? 'La fuente premier de Chicago para\nrefacciones y capacitación profesional.'
      : "Chicago's premier source for\nauto parts & professional training.";
  String get homeShopParts => isEs ? 'VER REFACCIONES' : 'SHOP PARTS';
  String get homeCategories => 'CATEGORIES';
  String get homeFeatured => isEs ? 'DESTACADOS' : 'FEATURED PARTS';
  String get homeStats1 => isEs ? 'Refacciones\nEn Stock' : 'Parts\nIn Stock';
  String get homeStats2 => isEs ? 'Años de\nExperiencia' : 'Years\nExperience';
  String get homeStats3 => isEs ? 'Satisfacción\nde Clientes' : 'Customer\nSatisfaction';
  String get homeBannerTitle => isEs ? '¿NECESITAS UNA PARTE ESPECIAL?' : 'NEED A CUSTOM PART?';
  String get homeBannerSub => isEs ? 'Obtén una cotización gratis →' : 'Get a free quote in minutes →';
  String get homeNoPartsTitle => isEs ? 'Sin refacciones cargadas' : 'No parts loaded yet';
  String get homeNoPartsSub => isEs ? 'Desliza para actualizar' : 'Pull to refresh';
  String get homeLive => isEs ? 'EN VIVO · CHICAGO, IL' : 'LIVE · CHICAGO, IL';

  // ── Categories ───────────────────────────────────────────────
  String get catEngine => isEs ? 'Motor' : 'Engine';
  String get catBody => isEs ? 'Carrocería' : 'Body';
  String get catElectrical => isEs ? 'Eléctrico' : 'Electrical';
  String get catSuspension => 'Suspensión';
  String get catFluids => isEs ? 'Fluidos' : 'Fluids';

  // ── Shop ─────────────────────────────────────────────────────
  String get shopTitle => isEs ? 'TIENDA' : 'PARTS SHOP';
  String get shopSubtitle => isEs ? 'Refacciones' : 'Auto Parts';
  String get shopSearch => isEs ? 'Buscar refacciones, SKU...' : 'Search parts, SKU...';
  String get shopAll => isEs ? 'Todas' : 'All';
  String get shopNoPartsTitle => isEs ? 'Sin refacciones' : 'No parts found';
  String get shopNoPartsSub => isEs ? 'Intenta otra búsqueda o categoría' : 'Try a different search or category';
  String get shopInStock => isEs ? 'EN STOCK' : 'IN STOCK';
  String get shopOutStock => isEs ? 'AGOTADO' : 'OUT OF STOCK';
  String get shopEach => isEs ? 'c/u' : 'each';

  // ── Part Detail ──────────────────────────────────────────────
  String get detailDescription => isEs ? 'DESCRIPCIÓN' : 'DESCRIPTION';
  String get detailUnitsAvailable => isEs ? 'unidades disponibles' : 'units available';
  String get detailAddCart => isEs ? 'AGREGAR AL CARRITO' : 'ADD TO CART';
  String get detailAdded => isEs ? 'AGREGADO ✓' : 'ADDED TO CART ✓';
  String get detailAddedSnack => isEs ? 'agregado al carrito' : 'added to cart';

  // ── Training ─────────────────────────────────────────────────
  String get trainingTag => isEs ? 'CENTRO DE CAPACITACIÓN' : 'TRAINING CENTER';
  String get trainingTitle => isEs ? 'Cursos' : 'Courses';
  String get trainingBannerTitle => isEs ? 'CERTIFICACIÓN\nPROFESIONAL' : 'PROFESSIONAL\nCERTIFICATION';
  String get trainingBannerSub => isEs
      ? 'Programas de capacitación automotriz\nreconocidos por la industria.'
      : 'Industry-recognized automotive\ntraining programs.';
  String get trainingAllCourses => isEs ? 'TODOS LOS CURSOS' : 'ALL COURSES';
  String get trainingNoneTitle => isEs ? 'Sin cursos disponibles' : 'No courses available';
  String get trainingNoneSub => isEs ? '¡Vuelve pronto!' : 'Check back soon!';

  // ── Cart ─────────────────────────────────────────────────────
  String get cartTag => isEs ? 'MI CARRITO' : 'MY CART';
  String get cartItems => isEs ? 'artículos' : 'items';
  String get cartItem => isEs ? 'artículo' : 'item';
  String get cartClearAll => isEs ? 'Vaciar todo' : 'Clear all';
  String get cartClearTitle => isEs ? '¿Vaciar carrito?' : 'Clear cart?';
  String get cartClearSub => isEs ? 'Esto eliminará todos los artículos.' : 'This will remove all items.';
  String get cartSubtotal => isEs ? 'Subtotal' : 'Subtotal';
  String get cartShipping => isEs ? 'Envío' : 'Shipping';
  String get cartShippingTbd => 'TBD';
  String get cartTotal => 'TOTAL';
  String get cartRequestQuote => isEs ? 'SOLICITAR COTIZACIÓN' : 'REQUEST QUOTE';
  String get cartEmpty => isEs ? 'Tu carrito está vacío' : 'Your cart is empty';
  String get cartEmptySub => isEs ? 'Agrega refacciones para comenzar' : 'Add parts to get started';
  String get cartSwipeDelete => isEs ? 'Desliza para eliminar' : 'Swipe to delete';

  // ── Checkout ─────────────────────────────────────────────────
  String get checkoutTitle => isEs ? 'SOLICITAR COTIZACIÓN' : 'REQUEST QUOTE';
  String get checkoutName => isEs ? 'Nombre completo' : 'Full Name';
  String get checkoutEmail => 'Email';
  String get checkoutPhone => isEs ? 'Teléfono' : 'Phone';
  String get checkoutMessage => isEs ? 'Mensaje (opcional)' : 'Message (optional)';
  String get checkoutSend => isEs ? 'ENVIAR COTIZACIÓN' : 'SEND QUOTE';
  String get checkoutSuccessTitle => isEs ? '¡Cotización Enviada!' : 'Quote Sent!';
  String get checkoutSuccessSub => isEs ? 'Te responderemos pronto.' : "We'll get back to you shortly.";

  // ── Contact ──────────────────────────────────────────────────
  String get contactTag => isEs ? 'CONTACTO' : 'CONTACT';
  String get contactTitle => isEs ? 'Contáctanos' : 'Get In Touch';
  String get contactPhone => isEs ? 'TELÉFONO' : 'PHONE';
  String get contactPhoneSub => isEs ? 'Lun-Sáb 8am-6pm' : 'Call us Mon-Sat 8am-6pm';
  String get contactEmailSub => isEs ? 'Respondemos en 24 horas' : 'We reply within 24 hours';
  String get contactAddress => isEs ? 'DIRECCIÓN' : 'ADDRESS';
  String get contactAddressSub => 'Chicago, IL 60601';
  String get contactHours => isEs ? 'HORARIO' : 'BUSINESS HOURS';
  String get contactAbout => isEs ? 'NOSOTROS' : 'ABOUT US';
  String get contactAboutText => isEs
      ? 'Safe Car Automotive lleva más de 12 años sirviendo a la comunidad automotriz de Chicago. Nos especializamos en refacciones OEM y de aftermarket para todas las marcas principales, y ofrecemos programas de capacitación profesional para técnicos automotrices.\n\nNuestro compromiso es proveer refacciones de calidad a precios competitivos, respaldados por conocimiento experto y un servicio al cliente insuperable.'
      : "Safe Car Automotive has been serving Chicago's automotive community for over 12 years. We specialize in OEM and aftermarket parts for all major vehicle brands, and offer professional training programs for automotive technicians.\n\nOur commitment is to provide quality parts at competitive prices, backed by expert knowledge and unmatched customer service.";
  String get contactHoursMF => isEs ? 'Lunes - Viernes' : 'Mon - Fri';
  String get contactHoursSat => isEs ? 'Sábado' : 'Saturday';
  String get contactHoursSun => isEs ? 'Domingo' : 'Sunday';
  String get contactClosed => isEs ? 'CERRADO' : 'CLOSED';
  String get contactCopied => isEs ? 'Copiado' : 'Copied';
}

// ── Language Provider ─────────────────────────────────────────────
class LangProvider extends ChangeNotifier {
  AppStrings _strings = AppStrings.es; // default español

  AppStrings get s => _strings;
  bool get isEs => _strings.isEs;

  void toggle() {
    _strings = isEs ? AppStrings.en : AppStrings.es;
    notifyListeners();
  }

  void setLang(String lang) {
    _strings = lang == 'es' ? AppStrings.es : AppStrings.en;
    notifyListeners();
  }
}
