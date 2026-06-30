// lib/screens/track_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';
import '../widgets/status_animation_overlay.dart';
import 'rate_service_screen.dart';

/// Pantalla pública de seguimiento de grúa. El cliente entra su
/// referencia (sin login) y ve el estado + mapa en vivo del técnico
/// cuando status == in_progress. Refresca cada 10s mientras está en
/// camino, igual a como quedó definido el flujo completo.
class TrackScreen extends StatefulWidget {
  final String? initialReference;
  const TrackScreen({super.key, this.initialReference});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final _refController = TextEditingController();
  Map<String, dynamic>? _data;
  bool _loading = false;
  String? _error;
  Timer? _poll;
  String? _pendingAnimationStatus; // 'confirmed' | 'in_progress' | 'completed' | null
  String? _lastSeenStatus;

  @override
  void initState() {
    super.initState();
    if (widget.initialReference != null) {
      _refController.text = widget.initialReference!;
      _lookup();
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final ref = _refController.text.trim();
    if (ref.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.trackTowByReference(ref);
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _error = 'No encontramos una solicitud con esa referencia.';
        _loading = false;
        _data = null;
      });
      return;
    }
    setState(() {
      _data = result;
      _loading = false;
    });
    _maybeTriggerLaunchAnim(result['status']);
    _setupPolling();
  }

  void _maybeTriggerLaunchAnim(String? newStatus) {
    const animatedStatuses = {'confirmed', 'in_progress', 'completed'};
    final isNewTransition = _lastSeenStatus != null &&
        _lastSeenStatus != newStatus &&
        animatedStatuses.contains(newStatus);
    if (isNewTransition) {
      setState(() => _pendingAnimationStatus = newStatus);
    }
    _lastSeenStatus = newStatus;
  }

  void _setupPolling() {
    _poll?.cancel();
    if (_data?['status'] == 'in_progress') {
      _poll = Timer.periodic(const Duration(seconds: 10), (_) async {
        final fresh = await ApiService.trackTowByReference(_refController.text.trim());
        if (!mounted || fresh == null) return;
        _maybeTriggerLaunchAnim(fresh['status']);
        setState(() => _data = fresh);
        if (fresh['status'] != 'in_progress') _poll?.cancel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text(s.isEs ? 'Mi solicitud' : 'My request')),
      body: SafeArea(
        child: Stack(
          children: [
            _data == null ? _buildLookupForm(s) : _buildTrackingView(s),
            if (_pendingAnimationStatus != null)
              Positioned.fill(
                child: _buildStatusOverlay(_pendingAnimationStatus!, s),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverlay(String status, dynamic s) {
    final config = switch (status) {
      'confirmed' => (
          asset: 'assets/lottie/confirmed.json',
          label: s.isEs ? 'CONFIRMADO' : 'CONFIRMED',
          sublabel: s.isEs ? 'Un técnico fue asignado a tu servicio' : 'A technician was assigned',
          color: AppTheme.amber,
        ),
      'in_progress' => (
          asset: 'assets/lottie/car_launch.json',
          label: s.isEs ? 'EN CAMINO' : 'ON THE WAY',
          sublabel: s.isEs ? 'Tu técnico va en camino' : 'Your technician is on the way',
          color: AppTheme.red,
        ),
      'completed' => (
          asset: 'assets/lottie/completed.json',
          label: s.isEs ? 'COMPLETADO' : 'COMPLETED',
          sublabel: s.isEs ? '¡Servicio finalizado con éxito!' : 'Service finished successfully!',
          color: const Color(0xFF22C55E),
        ),
      _ => (
          asset: 'assets/lottie/confirmed.json',
          label: '',
          sublabel: null as String?,
          color: AppTheme.red,
        ),
    };

    return StatusAnimationOverlay(
      lottieAsset: config.asset,
      label: config.label,
      sublabel: config.sublabel,
      accentColor: config.color,
      onComplete: () {
        if (!mounted) return;
        final wasCompleted = _pendingAnimationStatus == 'completed';
        setState(() => _pendingAnimationStatus = null);
        if (wasCompleted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RateServiceScreen(prefillName: _data?['customer_name']),
            ),
          );
        }
      },
    );
  }

  Widget _buildLookupForm(dynamic s) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(s.isEs ? 'Consulta tu solicitud' : 'Check your request',
              style: AppTheme.display(22)),
          const SizedBox(height: 6),
          Text(
            s.isEs
                ? 'Ingresa la referencia que recibiste al solicitar tu grúa.'
                : 'Enter the reference you received when you requested your tow.',
            style: AppTheme.body(13, color: AppTheme.white60),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _refController,
              textCapitalization: TextCapitalization.characters,
              style: AppTheme.mono(15, color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'SC-XXXX-XXXX',
                hintStyle: AppTheme.mono(15, color: AppTheme.white30),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSubmitted: (_) => _lookup(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: AppTheme.body(12, color: AppTheme.red)),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _loading ? null : _lookup,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _loading ? AppTheme.red.withOpacity(0.6) : AppTheme.red,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppTheme.red.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 5)),
                  ],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(s.isEs ? 'BUSCAR' : 'SEARCH', style: AppTheme.mono(13, w: FontWeight.w800)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingView(dynamic s) {
    final data = _data!;
    final status = data['status'] ?? 'pending';
    final techLat = (data['technician_lat'] ?? 0).toDouble();
    final showMap = status == 'in_progress' && techLat != 0.0;

    return RefreshIndicator(
      color: AppTheme.red,
      backgroundColor: AppTheme.bgCard,
      onRefresh: _lookup,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(data['reference'] ?? '', style: AppTheme.mono(13, color: AppTheme.white60)),
              ),
              TextButton(
                onPressed: () {
                  _poll?.cancel();
                  setState(() => _data = null);
                },
                child: Text(s.isEs ? 'Buscar otra' : 'Search another',
                    style: AppTheme.body(12, color: AppTheme.red)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (showMap) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                child: _TechnicianMap(
                  techLat: techLat,
                  techLng: (data['technician_lng'] ?? 0).toDouble(),
                  destLat: (data['pickup_lat'] as num?)?.toDouble(),
                  destLng: (data['pickup_lng'] as num?)?.toDouble(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _StatusCard(status: status, s: s),
          const SizedBox(height: 16),
          _StatusStepper(status: status, s: s),
          const SizedBox(height: 8),
          if (data['vehicle_description'] != null) ...[
            const SizedBox(height: 16),
            _InfoRow(label: s.isEs ? 'Vehículo' : 'Vehicle', value: data['vehicle_description']),
            _InfoRow(label: s.isEs ? 'Recogida' : 'Pickup', value: data['pickup_address'] ?? ''),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 80, child: Text(label, style: AppTheme.mono(11, color: AppTheme.white30))),
          Expanded(child: Text(value, style: AppTheme.body(13))),
        ]),
      );
}

class _StatusCard extends StatelessWidget {
  final String status;
  final dynamic s;
  const _StatusCard({required this.status, required this.s});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (status) {
      'pending' => (
          s.isEs ? 'Solicitud recibida' : 'Request received',
          Icons.inbox_rounded, AppTheme.amber),
      'confirmed' => (
          s.isEs ? 'Confirmado, asignando técnico' : 'Confirmed, assigning technician',
          Icons.task_alt_rounded, AppTheme.amber),
      'in_progress' => (
          s.isEs ? 'En camino hacia ti' : 'On the way to you',
          Icons.local_shipping_rounded, AppTheme.red),
      'completed' => (
          s.isEs ? 'Servicio completado' : 'Service completed',
          Icons.check_circle_rounded, const Color(0xFF22C55E)),
      'cancelled' => (
          s.isEs ? 'Cancelado' : 'Cancelled',
          Icons.cancel_rounded, AppTheme.red),
      _ => ('', Icons.help_outline_rounded, AppTheme.white30),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTheme.display(16))),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final String status;
  final dynamic s;
  const _StatusStepper({required this.status, required this.s});

  static const _order = ['pending', 'confirmed', 'in_progress', 'completed'];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') return const SizedBox.shrink();
    final currentIdx = _order.indexOf(status).clamp(0, 3);
    final labels = s.isEs
        ? ['RECIBIDO', 'CONFIRMADO', 'EN CAMINO', 'COMPLETADO']
        : ['RECEIVED', 'CONFIRMED', 'ON THE WAY', 'COMPLETED'];

    return Row(
      children: List.generate(_order.length, (i) {
        final done = i <= currentIdx;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(child: Container(height: 2, color: i <= currentIdx ? AppTheme.red : AppTheme.border)),
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: done ? AppTheme.red : AppTheme.border),
                  ),
                  if (i < _order.length - 1)
                    Expanded(child: Container(height: 2, color: i < currentIdx ? AppTheme.red : AppTheme.border)),
                ],
              ),
              const SizedBox(height: 6),
              Text(labels[i], textAlign: TextAlign.center,
                  style: AppTheme.mono(8, color: done ? AppTheme.red : AppTheme.white30)),
            ],
          ),
        );
      }),
    );
  }
}

/// Mapa con OpenStreetMap (sin API key). Pin rojo = técnico, marcador
/// blanco con bandera = punto de recogida del cliente.
class _TechnicianMap extends StatelessWidget {
  final double techLat, techLng;
  final double? destLat, destLng;
  const _TechnicianMap({required this.techLat, required this.techLng, this.destLat, this.destLng});

  @override
  Widget build(BuildContext context) {
    final techPoint = LatLng(techLat, techLng);
    final markers = <Marker>[
      Marker(
        point: techPoint,
        width: 40, height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: AppTheme.red.withOpacity(0.5), blurRadius: 10)],
          ),
          child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 18),
        ),
      ),
    ];
    if (destLat != null && destLng != null && destLat != 0.0) {
      markers.add(Marker(
        point: LatLng(destLat!, destLng!),
        width: 26, height: 26,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppTheme.border, width: 2)),
          child: const Icon(Icons.flag_rounded, color: Colors.black87, size: 13),
        ),
      ));
    }
    return FlutterMap(
      options: MapOptions(initialCenter: techPoint, initialZoom: 14),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.safecar.client'),
        MarkerLayer(markers: markers),
      ],
    );
  }
}