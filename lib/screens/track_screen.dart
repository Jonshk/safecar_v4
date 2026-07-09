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
  Timer? _chatPoll;
  String? _pendingAnimationStatus;
  String? _lastSeenStatus;

  // Chat
  final List<Map<String, dynamic>> _messages = [];
  int _lastMsgId = 0;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sendingMsg = false;
  bool _chatExpanded = false;

  // Mapa redimensionable
  double _mapHeight = 280;
  static const _minMap = 80.0;
  static const _maxMap = 500.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialReference != null) {
      _refController.text = widget.initialReference!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup());
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _chatPoll?.cancel();
    _refController.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final ref = _refController.text.trim();
    if (ref.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final result = await ApiService.trackTowByReference(ref);
    if (!mounted) return;
    if (result == null) {
      setState(() { _loading = false; _error = 'Reference not found.'; });
      return;
    }
    setState(() { _data = result; _loading = false; });
    _maybeTriggerAnim(result['status']);
    _setupPolling();
    _setupChatPolling();
  }

  void _maybeTriggerAnim(String? newStatus) {
    const animated = {'confirmed', 'in_progress', 'arrived', 'completed', 'cancelled'};
    if (_lastSeenStatus != null && _lastSeenStatus != newStatus && animated.contains(newStatus)) {
      setState(() => _pendingAnimationStatus = newStatus);
    }
    _lastSeenStatus = newStatus;
  }

  void _setupPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 10), (_) async {
      final fresh = await ApiService.trackTowByReference(_refController.text.trim());
      if (!mounted || fresh == null) return;
      _maybeTriggerAnim(fresh['status']);
      setState(() => _data = fresh);
    });
  }

  void _setupChatPolling() {
    _chatPoll?.cancel();
    _chatPoll = Timer.periodic(const Duration(seconds: 4), (_) => _loadMessages());
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final towId = _data?['id'] as int?;
    if (towId == null) return;
    final msgs = await ApiService.getChatMessages(towId, afterId: _lastMsgId);
    if (msgs.isEmpty || !mounted) return;
    setState(() {
      _messages.addAll(msgs);
      _lastMsgId = msgs.last['id'] as int;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    final towId = _data?['id'] as int?;
    if (text.isEmpty || towId == null || _sendingMsg) return;
    setState(() => _sendingMsg = true);
    _msgCtrl.clear();
    final ok = await ApiService.sendChatMessage(
      towId: towId,
      sender: 'client',
      senderName: _data?['customer_name'] ?? 'Cliente',
      text: text,
    );
    setState(() => _sendingMsg = false);
    if (ok) _loadMessages();
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
            _data == null ? _buildLookup(s) : _buildUberLayout(s),
            if (_pendingAnimationStatus != null)
              Positioned.fill(child: _buildAnim(_pendingAnimationStatus!, s)),
          ],
        ),
      ),
    );
  }

  // ── Layout tipo Uber: mapa arriba, chat abajo ─────────────────────

  Widget _buildUberLayout(dynamic s) {
    final data = _data!;
    final status = data['status'] as String? ?? 'pending';
    final techLat = (data['technician_lat'] as num?)?.toDouble() ?? 0;
    final techLng = (data['technician_lng'] as num?)?.toDouble() ?? 0;
    final pickLat = (data['pickup_lat'] as num?)?.toDouble() ?? 0;
    final pickLng = (data['pickup_lng'] as num?)?.toDouble() ?? 0;
    final hasGps = techLat != 0 && techLng != 0;
    final showChat = status == 'confirmed' || status == 'in_progress' || status == 'arrived';

    return Column(
      children: [
        // ── MAPA ──────────────────────────────────────────────────
        SizedBox(
          height: _mapHeight,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: hasGps ? LatLng(techLat, techLng) : LatLng(pickLat, pickLng),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.safecar.safecar_app',
                  ),
                  MarkerLayer(markers: [
                    if (pickLat != 0) Marker(
                      point: LatLng(pickLat, pickLng),
                      width: 40, height: 40,
                      child: Container(
                        decoration: BoxDecoration(color: AppTheme.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    if (hasGps) Marker(
                      point: LatLng(techLat, techLng),
                      width: 44, height: 44,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ]),
                ],
              ),
              // Status pill encima del mapa
              Positioned(
                top: 12, left: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bg.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(children: [
                    _statusDot(status),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_statusLabel(status, s), style: AppTheme.mono(13, w: FontWeight.w700))),
                    if (_data != null) GestureDetector(
                      onTap: () {
                        _poll?.cancel();
                        _chatPoll?.cancel();
                        _data = null;
                        _messages.clear();
                        _lastMsgId = 0;
                        setState(() {});
                      },
                      child: Text(s.isEs ? 'Buscar otra' : 'Search another',
                          style: AppTheme.mono(11, color: AppTheme.red)),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // Handle para redimensionar el mapa
        GestureDetector(
          onVerticalDragUpdate: (d) {
            setState(() {
              _mapHeight = (_mapHeight + d.delta.dy).clamp(_minMap, _maxMap);
            });
          },
          child: Container(
            height: 18,
            color: AppTheme.bgCard,
            child: Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        // ── INFO + CHAT ───────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bg,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Column(
              children: [
                // Info fila
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(data['reference'] ?? '', style: AppTheme.mono(12, color: AppTheme.red)),
                      const SizedBox(height: 2),
                      Text(data['vehicle_description'] ?? '', style: AppTheme.body(13, color: AppTheme.white60), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    if (showChat) GestureDetector(
                      onTap: () => setState(() => _chatExpanded = !_chatExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _messages.isNotEmpty ? AppTheme.red : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _messages.isNotEmpty ? AppTheme.red : AppTheme.border),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.chat_bubble_rounded, size: 14, color: _messages.isNotEmpty ? Colors.white : AppTheme.white60),
                          const SizedBox(width: 5),
                          Text(
                            _chatExpanded ? (s.isEs ? 'Cerrar' : 'Close') : (s.isEs ? 'Chat' : 'Chat'),
                            style: AppTheme.mono(11, w: FontWeight.w700, color: _messages.isNotEmpty ? Colors.white : AppTheme.white60),
                          ),
                          if (_messages.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Container(
                              width: 16, height: 16,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Center(child: Text('${_messages.length}', style: const TextStyle(color: AppTheme.red, fontSize: 9, fontWeight: FontWeight.w800))),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ]),
                ),

                if (showChat && _chatExpanded) ...[
                  // Mensajes
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(child: Text(s.isEs ? 'Escríbele al técnico' : 'Message the technician',
                            style: AppTheme.body(13, color: AppTheme.white30)))
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            itemCount: _messages.length,
                            itemBuilder: (_, i) => _buildBubble(_messages[i]),
                          ),
                  ),
                  // Input
                  Container(
                    padding: EdgeInsets.only(
                      left: 10, right: 10, top: 8,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    ),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: TextField(
                            controller: _msgCtrl,
                            style: AppTheme.body(13),
                            maxLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: s.isEs ? 'Escribe un mensaje...' : 'Type a message...',
                              hintStyle: AppTheme.body(12, color: AppTheme.white30),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: AppTheme.red, shape: BoxShape.circle),
                          child: _sendingMsg
                              ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ]),
                  ),
                ] else if (!showChat) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _InfoRow(label: s.isEs ? 'Recogida' : 'Pickup', value: data['pickup_address'] ?? ''),
                        if ((data['destination_address'] as String?)?.isNotEmpty ?? false)
                          _InfoRow(label: s.isEs ? 'Destino' : 'Destination', value: data['destination_address']),
                      ]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final isMe = msg['sender'] == 'client';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.red : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 3),
            bottomRight: Radius.circular(isMe ? 3 : 14),
          ),
        ),
        child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          if (!isMe) Text(msg['sender_name'] ?? 'Técnico', style: AppTheme.mono(9, w: FontWeight.w700, color: Colors.orange)),
          Text(msg['text'] ?? '', style: AppTheme.body(13, color: Colors.white)),
          Text((msg['created_at'] as String?)?.substring(11, 16) ?? '',
              style: AppTheme.body(10, color: Colors.white.withOpacity(0.4))),
        ]),
      ),
    );
  }

  Widget _statusDot(String status) {
    final color = switch (status) {
      'confirmed' => Colors.amber,
      'in_progress' => Colors.orange,
      'arrived' => const Color(0xFF22C55E),
      'completed' => const Color(0xFF22C55E),
      'cancelled' => Colors.grey,
      _ => AppTheme.white30,
    };
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  String _statusLabel(String status, dynamic s) => switch (status) {
    'pending' => s.isEs ? 'Solicitud recibida' : 'Request received',
    'confirmed' => s.isEs ? 'Confirmado · Técnico asignado' : 'Confirmed · Technician assigned',
    'in_progress' => s.isEs ? 'En camino hacia ti' : 'On the way',
    'arrived' => s.isEs ? '¡Tu técnico llegó!' : 'Technician arrived!',
    'completed' => s.isEs ? 'Servicio completado' : 'Service completed',
    'cancelled' => s.isEs ? 'Cancelado' : 'Cancelled',
    'arrived' => s.isEs ? '¡Tu técnico llegó!' : 'Technician arrived!',
    _ => status,
  };

  // ── Lookup form ───────────────────────────────────────────────────

  Widget _buildLookup(dynamic s) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_rounded, color: AppTheme.red, size: 48),
        const SizedBox(height: 16),
        Text(s.isEs ? 'Rastrear mi solicitud' : 'Track my request',
            style: AppTheme.display(22, w: FontWeight.w800), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(s.isEs ? 'Introduce tu código de referencia' : 'Enter your reference code',
            style: AppTheme.body(14, color: AppTheme.white60), textAlign: TextAlign.center),
        const SizedBox(height: 28),
        TextField(
          controller: _refController,
          style: AppTheme.mono(16, w: FontWeight.w700),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'SC-XXXX-XXXX',
            hintStyle: AppTheme.mono(16, color: AppTheme.white30),
            filled: true, fillColor: AppTheme.bgCard,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.red, width: 1.5)),
          ),
        ),
        if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: AppTheme.body(12, color: AppTheme.red))],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 52,
          child: GestureDetector(
            onTap: _loading ? null : _lookup,
            child: Container(
              decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(s.isEs ? 'BUSCAR' : 'SEARCH', style: AppTheme.mono(14, w: FontWeight.w800)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAnim(String status, dynamic s) {
    final config = switch (status) {
      'confirmed' => (asset: 'assets/lottie/confirmed.json', label: s.isEs ? 'CONFIRMADO' : 'CONFIRMED', sublabel: s.isEs ? 'Un técnico fue asignado' : 'A technician was assigned', color: Colors.amber),
      'in_progress' => (asset: 'assets/lottie/car_launch.json', label: s.isEs ? 'EN CAMINO' : 'ON THE WAY', sublabel: s.isEs ? 'Tu técnico va en camino' : 'Your technician is on the way', color: AppTheme.red),
      'cancelled' => (asset: 'assets/lottie/cancelled.json', label: s.isEs ? 'CANCELADO' : 'CANCELLED', sublabel: s.isEs ? 'La solicitud fue cancelada' : 'The request was cancelled', color: Colors.grey),
      'arrived' => (asset: 'assets/lottie/arrived.json', label: s.isEs ? '¡LLEGÓ!' : 'ARRIVED!', sublabel: s.isEs ? 'Tu técnico está en tu ubicación' : 'Your technician is at your location', color: const Color(0xFF22C55E)),
      'completed' => (asset: 'assets/lottie/completed.json', label: s.isEs ? 'COMPLETADO' : 'COMPLETED', sublabel: s.isEs ? '¡Servicio finalizado!' : 'Service completed!', color: const Color(0xFF22C55E)),
      _ => (asset: 'assets/lottie/confirmed.json', label: '', sublabel: null as String?, color: AppTheme.red),
    };
    return StatusAnimationOverlay(
      lottieAsset: config.asset, label: config.label,
      sublabel: config.sublabel, accentColor: config.color,
      onComplete: () {
        if (!mounted) return;
        final was = _pendingAnimationStatus;
        setState(() => _pendingAnimationStatus = null);
        if (was == 'completed') {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => RateServiceScreen(prefillName: _data?['customer_name']),
          ));
        }
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 72, child: Text(label, style: AppTheme.mono(11, color: AppTheme.white30))),
          Expanded(child: Text(value, style: AppTheme.body(13))),
        ]),
      );
}