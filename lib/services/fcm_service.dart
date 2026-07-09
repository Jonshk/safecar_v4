// lib/services/fcm_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../theme/app_theme.dart';
import '../widgets/status_animation_overlay.dart';
import '../screens/track_screen.dart';
import '../screens/rate_service_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// FCM del lado Cliente. El token viaja amarrado a la solicitud
/// (tow_requests.fcm_token), eso ya pasa en ApiService.createTowRequest.
/// Este servicio se encarga de:
/// 1) pedir permiso y crear el canal de notificaciones
/// 2) si la app está ABIERTA cuando llega el push, mostrar la
///    animación correspondiente al estado (confirmado/en camino/
///    completado) encima de lo que sea que el cliente esté viendo
/// 3) si el cliente TOCA la notificación, navegar a tracking (o a
///    calificar, si el servicio ya se completó)
class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState>? _navigatorKey;

  static const _channelId = 'safecar_client_channel';
  static const _channelName = 'Safe Car';
  static const _channelDesc = 'Actualizaciones de tu grúa, reserva o pedido';

  static const _animatedStatuses = {'confirmed', 'in_progress', 'arrived', 'completed', 'cancelled'};

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotif.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (response) {
        final ref = response.payload;
        if (ref != null && ref.isNotEmpty) _navigateToTracking(ref);
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // App ABIERTA cuando llega el push.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final eventType = message.data['event_type'];
      final reference = message.data['reference_code'];
      final status = message.data['status'];

      if (eventType == 'tow_status_update' && _animatedStatuses.contains(status)) {
        _showStatusOverlay(status!, reference);
      } else {
        final notif = message.notification;
        if (notif == null) return;
        _localNotif.show(
          notif.hashCode,
          notif.title,
          notif.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDesc,
              importance: Importance.max,
              priority: Priority.high,
              color: Color(0xFFE8323C),
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: reference,
        );
      }
    });

    // App en background y el cliente TOCA la notificación.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final reference = message.data['reference_code'];
      if (reference != null && reference.isNotEmpty) {
        _navigateToTracking(reference);
      }
    });
  }

  static void _showStatusOverlay(String status, String? reference) {
    final navState = _navigatorKey?.currentState;
    if (navState == null) return;
    final overlay = navState.overlay;
    if (overlay == null) return;

    final config = switch (status) {
      'confirmed' => (
          asset: 'assets/lottie/confirmed.json',
          label: 'CONFIRMADO',
          sublabel: 'Un técnico fue asignado a tu servicio',
          color: AppTheme.amber,
        ),
      'in_progress' => (
          asset: 'assets/lottie/car_launch.json',
          label: 'EN CAMINO',
          sublabel: 'Tu técnico va en camino',
          color: AppTheme.red,
        ),
      'arrived' => (
          asset: 'assets/lottie/arrived.json',
          label: 'LLEGÓ',
          sublabel: 'Tu técnico está en tu ubicación',
          color: const Color(0xFF22C55E),
        ),
        'cancelled' => (
          asset: 'assets/lottie/cancelled.json',
          label: 'CANCELADO',
          sublabel: 'La solicitud fue cancelada',
          color: Colors.grey,
        ),
        'completed' => (
          asset: 'assets/lottie/completed.json',
          label: 'COMPLETADO',
          sublabel: '¡Servicio finalizado con éxito!',
          color: const Color(0xFF22C55E),
        ),
      _ => null,
    };
    if (config == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => StatusAnimationOverlay(
        lottieAsset: config.asset,
        label: config.label,
        sublabel: config.sublabel,
        accentColor: config.color,
        onComplete: () {
          entry.remove();
          if (status == 'completed') {
            navState.push(MaterialPageRoute(builder: (_) => const RateServiceScreen()));
          } else if (reference != null && reference.isNotEmpty) {
            _navigateToTracking(reference);
          }
        },
      ),
    );
    overlay.insert(entry);
  }

  static void _navigateToTracking(String reference) {
    final navState = _navigatorKey?.currentState;
    if (navState == null) return;
    navState.push(
      MaterialPageRoute(builder: (_) => TrackScreen(initialReference: reference)),
    );
  }
}