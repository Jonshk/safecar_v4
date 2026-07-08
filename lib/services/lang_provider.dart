import 'package:flutter/material.dart';

class AppStrings {
  final bool isEs;
  const AppStrings(this.isEs);

  // ── Nav ──────────────────────────────────────────────────
  String get navHome => isEs ? 'Inicio' : 'Home';
  String get navShop => isEs ? 'Tienda' : 'Shop';
  String get navTraining => isEs ? 'Cursos' : 'Training';
  String get seeAll => isEs ? 'Ver todo' : 'See all';

  // ── Splash ───────────────────────────────────────────────
  String get splashConnecting => isEs ? 'Conectando...' : 'Connecting...';
  String get splashOnline => isEs ? 'En línea' : 'Online';
  String get splashOffline => isEs ? 'Sin conexión' : 'Offline';

  // ── Home ─────────────────────────────────────────────────
  String get homeLive => isEs ? 'En vivo' : 'Live';
  String get homeTagline => isEs ? 'Tu taller de confianza en Chicago' : 'Your trusted shop in Chicago';
  String get homeShopParts => isEs ? 'Ver repuestos' : 'Shop parts';
  String get homeStats1 => isEs ? 'Clientes felices' : 'Happy customers';
  String get homeStats2 => isEs ? 'Años de experiencia' : 'Years of experience';
  String get homeStats3 => isEs ? 'Satisfacción' : 'Satisfaction';
  String get homeStats => isEs ? 'Estadísticas' : 'Stats';
  String get homeCategories => isEs ? 'Categorías' : 'Categories';
  String get homeFeatured => isEs ? 'Destacados' : 'Featured';
  String get homeBannerTitle => isEs ? 'Diagnóstico gratis' : 'Free Diagnostics';
  String get homeBannerSub => isEs ? 'Trae tu vehículo y lo revisamos sin costo' : 'Bring your vehicle for a free check';
  String get homeNoPartsTitle => isEs ? 'Sin repuestos' : 'No parts found';
  String get homeNoPartsSub => isEs ? 'Intenta con otra categoría' : 'Try another category';

  // ── Categories ───────────────────────────────────────────
  String get catEngine => isEs ? 'Motor' : 'Engine';
  String get catBody => isEs ? 'Carrocería' : 'Body';
  String get catElectrical => isEs ? 'Eléctrico' : 'Electrical';
  String get catSuspension => isEs ? 'Suspensión' : 'Suspension';
  String get catFluids => isEs ? 'Fluidos' : 'Fluids';

  // ── Shop ─────────────────────────────────────────────────
  String get shopTitle => isEs ? 'Repuestos' : 'Parts';
  String get shopSubtitle => isEs ? 'Calidad garantizada' : 'Quality guaranteed';
  String get shopSearch => isEs ? 'Buscar repuestos...' : 'Search parts...';
  String get shopAll => isEs ? 'Todos' : 'All';
  String get shopInStock => isEs ? 'En stock' : 'In stock';
  String get shopOutStock => isEs ? 'Sin stock' : 'Out of stock';
  String get shopNoPartsTitle => isEs ? 'Sin resultados' : 'No results';
  String get shopNoPartsSub => isEs ? 'Intenta con otra búsqueda' : 'Try a different search';

  // ── Part detail ──────────────────────────────────────────
  String get detailDescription => isEs ? 'Descripción' : 'Description';
  String get detailUnitsAvailable => isEs ? 'unidades disponibles' : 'units available';
  String get detailAdded => isEs ? 'Agregado' : 'Added';
  String get detailAddCart => isEs ? 'Agregar al carrito' : 'Add to cart';
  String get detailAddedSnack => isEs ? 'Agregado al carrito' : 'Added to cart';

  // ── Cart ─────────────────────────────────────────────────
  String get cartTag => isEs ? 'CARRITO' : 'CART';
  String get cartEmpty => isEs ? 'Carrito vacío' : 'Empty cart';
  String get cartEmptySub => isEs ? 'Agrega repuestos desde la tienda' : 'Add parts from the shop';
  String get cartItem => isEs ? 'artículo' : 'item';
  String get cartSubtotal => isEs ? 'Subtotal' : 'Subtotal';
  String get cartShipping => isEs ? 'Envío' : 'Shipping';
  String get cartClearTitle => isEs ? 'Vaciar carrito' : 'Clear cart';
  String get cartClearSub => isEs ? '¿Eliminar todos los artículos?' : 'Remove all items?';
  String get cartClearAll => isEs ? 'Vaciar todo' : 'Clear all';
  String get checkoutName => isEs ? 'Nombre completo' : 'Full name';
  String get checkoutEmail => isEs ? 'Correo electrónico' : 'Email';
  String get checkoutPhone => isEs ? 'Teléfono' : 'Phone';

  // ── Training ─────────────────────────────────────────────
  String get trainingTag => isEs ? 'FORMACIÓN' : 'TRAINING';
  String get trainingTitle => isEs ? 'Cursos disponibles' : 'Available courses';
  String get trainingBannerTitle => isEs ? 'Certifícate con nosotros' : 'Get certified with us';
  String get trainingBannerSub => isEs ? 'Formación práctica por profesionales' : 'Hands-on training by professionals';
  String get trainingNoneTitle => isEs ? 'Sin cursos' : 'No courses';
  String get trainingNoneSub => isEs ? 'Vuelve pronto' : 'Check back soon';

  // ── Contact ──────────────────────────────────────────────
  String get contactTag => isEs ? 'CONTACTO' : 'CONTACT';
  String get contactTitle => isEs ? 'Estamos aquí para ayudarte' : 'We\'re here to help';
  String get contactPhone => isEs ? 'Teléfono' : 'Phone';
  String get contactPhoneSub => isEs ? 'Llámanos' : 'Call us';
  String get contactEmailSub => isEs ? 'Escríbenos' : 'Email us';
  String get contactAddress => isEs ? 'Dirección' : 'Address';
  String get contactAbout => isEs ? 'Sobre nosotros' : 'About us';
  String get contactClosed => isEs ? 'Cerrado' : 'Closed';
  String get contactAboutText => isEs
      ? 'Safe Car Automotive es tu taller de confianza en Chicago. Más de 10 años de experiencia en reparación, diagnóstico y formación automotriz.'
      : 'Safe Car Automotive is your trusted shop in Chicago. Over 10 years of experience in auto repair, diagnostics and training.';

  // ── Tow screen ───────────────────────────────────────────
  String get towTitle => isEs ? 'SERVICIO DE GRÚA' : 'TOW SERVICE';
  String get towSubtitle => isEs ? 'Grúa de emergencia 24/7' : '24/7 Emergency Towing';
  String get towMyRequests => isEs ? 'MIS SOLICITUDES' : 'MY REQUESTS';
  String get towEta => isEs ? 'ETA 30–45 min' : '30–45 min ETA';
  String get towLicensed => isEs ? 'Operadores certificados' : 'Licensed operators';
  String get towLocationBtn => isEs ? 'Compartir mi ubicación' : 'Share my location';
  String get towLocationOk => isEs ? 'Ubicación obtenida' : 'Location captured';
  String get towLocationError => isEs ? 'Error de ubicación' : 'Location failed';
  String get towLocationTapAgain => isEs ? 'Toca para intentar de nuevo' : 'Tap to try again';
  String get towLocationTap => isEs ? 'Toca para enviar tu GPS exacto' : 'Tap to send your exact GPS position';
  String get towSectionYou => isEs ? 'TUS DATOS' : 'YOUR INFORMATION';
  String get towSectionVehicle => isEs ? 'VEHÍCULO Y UBICACIÓN' : 'VEHICLE & LOCATION';
  String get towNameField => isEs ? 'Nombre completo' : 'Full name';
  String get towPhoneField => isEs ? 'Número de teléfono' : 'Phone number';
  String get towVehicleField => isEs ? 'Vehículo (Año, Marca, Modelo)' : 'Vehicle (Year, Make, Model)';
  String get towPickupField => isEs ? 'Dirección de recogida / ubicación' : 'Pickup address / location';
  String get towDestField => isEs ? 'Destino (opcional)' : 'Destination (optional)';
  String get towNotesField => isEs ? 'Notas adicionales (opcional)' : 'Additional notes (optional)';
  String get towSubmitBtn => isEs ? 'SOLICITAR GRÚA' : 'REQUEST TOW';
  String get towRequired => isEs ? 'Requerido' : 'Required';
  String get towSuccessTitle => isEs ? 'SOLICITUD ENVIADA' : 'TOW REQUESTED';
  String get towSuccessSub => isEs ? 'Un despachador te llamará pronto.' : 'A dispatcher will call you shortly.';
  String get towRefLabel => isEs ? 'REFERENCIA' : 'REFERENCE';
  String get towRefSaved => isEs ? 'Guardado — ver "Mis solicitudes"' : 'Saved — see "My Requests"';
  String get towTrackBtn => isEs ? 'SEGUIR EN VIVO' : 'TRACK LIVE';
  String get towNewBtn => isEs ? 'Nueva solicitud' : 'New Request';

  // ── Track screen ─────────────────────────────────────────
  String get trackTitle => isEs ? 'Mi solicitud' : 'My request';
  String get trackSearchTitle => isEs ? 'Rastrear mi solicitud' : 'Track my request';
  String get trackSearchSub => isEs ? 'Introduce tu código de referencia' : 'Enter your reference code';
  String get trackSearchBtn => isEs ? 'BUSCAR' : 'SEARCH';
  String get trackSearchAnother => isEs ? 'Buscar otra' : 'Search another';
  String get trackChatOpen => isEs ? 'Chat' : 'Chat';
  String get trackChatClose => isEs ? 'Cerrar' : 'Close';
  String get trackChatPlaceholder => isEs ? 'Escribe un mensaje...' : 'Type a message...';
  String get trackChatEmpty => isEs ? 'Escríbele al técnico' : 'Message the technician';
  String get trackPickup => isEs ? 'Recogida' : 'Pickup';
  String get trackDest => isEs ? 'Destino' : 'Destination';

  // ── Status ───────────────────────────────────────────────
  String statusLabel(String status) => switch (status) {
    'pending'     => isEs ? 'Solicitud recibida' : 'Request received',
    'confirmed'   => isEs ? 'Confirmado · Técnico asignado' : 'Confirmed · Technician assigned',
    'in_progress' => isEs ? 'En camino hacia ti' : 'On the way',
    'completed'   => isEs ? 'Servicio completado' : 'Service completed',
    'cancelled'   => isEs ? 'Cancelado' : 'Cancelled',
    _             => status,
  };

  String animLabel(String status) => switch (status) {
    'confirmed'   => isEs ? 'CONFIRMADO' : 'CONFIRMED',
    'in_progress' => isEs ? 'EN CAMINO' : 'ON THE WAY',
    'completed'   => isEs ? 'COMPLETADO' : 'COMPLETED',
    _             => '',
  };

  String animSublabel(String status) => switch (status) {
    'confirmed'   => isEs ? 'Un técnico fue asignado' : 'A technician was assigned',
    'in_progress' => isEs ? 'Tu técnico va en camino' : 'Your technician is on the way',
    'completed'   => isEs ? '¡Servicio finalizado!' : 'Service completed!',
    _             => '',
  };
}

class LangProvider extends ChangeNotifier {
  bool _isEs = true;
  bool get isEs => _isEs;
  AppStrings get s => AppStrings(_isEs);
  void toggle() { _isEs = !_isEs; notifyListeners(); }
  void setEs(bool v) { _isEs = v; notifyListeners(); }
}