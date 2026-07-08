// lib/screens/tow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';
import 'track_screen.dart';

class TowScreen extends StatefulWidget {
  const TowScreen({super.key});
  @override
  State<TowScreen> createState() => _TowScreenState();
}

class _TowScreenState extends State<TowScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _vehicle = TextEditingController();
  final _pickup = TextEditingController();
  final _destination = TextEditingController();
  final _notes = TextEditingController();

  double? _lat, _lng;
  bool _locLoading = false;
  String _locStatus = 'not_set';
  bool _loading = false;
  bool _submitted = false;
  String? _reference;
  List<String> _savedRefs = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRefs();
  }

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _vehicle.dispose();
    _pickup.dispose(); _destination.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _loadSavedRefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _savedRefs = prefs.getStringList('tow_references') ?? []);
  }

  Future<void> _saveRef(String ref) async {
    final prefs = await SharedPreferences.getInstance();
    final refs = prefs.getStringList('tow_references') ?? [];
    if (!refs.contains(ref)) { refs.insert(0, ref); if (refs.length > 5) refs.removeLast(); }
    await prefs.setStringList('tow_references', refs);
    setState(() => _savedRefs = refs);
  }

  Future<void> _getLocation() async {
    setState(() { _locLoading = true; _locStatus = 'loading'; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() { _locLoading = false; _locStatus = 'error'; }); return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() { _locLoading = false; _locStatus = 'error'; }); return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 15));
      setState(() { _lat = pos.latitude; _lng = pos.longitude; _locLoading = false; _locStatus = 'ok'; });
      if (_pickup.text.trim().isEmpty) _pickup.text = 'GPS: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
    } catch (_) { setState(() { _locLoading = false; _locStatus = 'error'; }); }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    String fcmToken = '';
    try { fcmToken = await FirebaseMessaging.instance.getToken() ?? ''; } catch (_) {}
    final result = await ApiService.createTowRequest(
      customerName: _name.text.trim(), customerPhone: _phone.text.trim(),
      vehicleDescription: _vehicle.text.trim(), pickupAddress: _pickup.text.trim(),
      pickupLat: _lat ?? 0.0, pickupLng: _lng ?? 0.0,
      destinationAddress: _destination.text.trim(), notes: _notes.text.trim(),
      fcmToken: fcmToken,
    );
    setState(() => _loading = false);
    if (result != null) {
      final ref = result['reference'] as String;
      await _saveRef(ref);
      setState(() { _submitted = true; _reference = ref; });
    }
  }

  void _reset() => setState(() {
    _submitted = false; _reference = null;
    _lat = null; _lng = null; _locStatus = 'not_set';
    _name.clear(); _phone.clear(); _vehicle.clear();
    _pickup.clear(); _destination.clear(); _notes.clear();
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: _submitted
            ? _SuccessView(reference: _reference!, onNew: _reset, s: s)
            : CustomScrollView(slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Color(0xFF1A0608), Color(0xFF0E1118), Color(0xFF080A0F)]),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(children: [
                      Container(width: 56, height: 56,
                        decoration: BoxDecoration(color: AppTheme.redGlow, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.red.withOpacity(0.4))),
                        child: const Icon(Icons.local_shipping_rounded, color: AppTheme.red, size: 28)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.towTitle, style: AppTheme.display(22, w: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(s.towSubtitle, style: AppTheme.body(13, color: AppTheme.white60)),
                      ])),
                    ]),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
                ),

                if (_savedRefs.isNotEmpty) SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.towMyRequests, style: AppTheme.mono(11, w: FontWeight.w700, color: AppTheme.white30)),
                      const SizedBox(height: 10),
                      ..._savedRefs.map((ref) => GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackScreen(initialReference: ref))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                          child: Row(children: [
                            const Icon(Icons.receipt_long_rounded, color: AppTheme.red, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ref, style: AppTheme.mono(13, color: AppTheme.red))),
                            Icon(Icons.chevron_right_rounded, color: AppTheme.white30, size: 18),
                          ]),
                        ),
                      )),
                      const SizedBox(height: 16),
                    ]),
                  ).animate(delay: 50.ms).fadeIn(),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      _InfoChip(Icons.access_time_rounded, s.towEta),
                      const SizedBox(width: 8),
                      _InfoChip(Icons.verified_rounded, s.towLicensed),
                    ]),
                  ).animate(delay: 100.ms).fadeIn(),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _LocationButton(s: s, status: _locStatus, loading: _locLoading, lat: _lat, lng: _lng, onTap: _getLocation),
                  ).animate(delay: 150.ms).fadeIn(),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Form(
                      key: _form,
                      child: Column(children: [
                        _SectionLabel(s.towSectionYou),
                        const SizedBox(height: 12),
                        _Field(ctrl: _name, label: s.towNameField, icon: Icons.person_outline_rounded,
                            validator: (v) => (v?.trim().isEmpty ?? true) ? s.towRequired : null),
                        const SizedBox(height: 12),
                        _Field(ctrl: _phone, label: s.towPhoneField, icon: Icons.phone_outlined,
                            keyboard: TextInputType.phone,
                            validator: (v) => (v?.trim().isEmpty ?? true) ? s.towRequired : null),
                        const SizedBox(height: 20),
                        _SectionLabel(s.towSectionVehicle),
                        const SizedBox(height: 12),
                        _Field(ctrl: _vehicle, label: s.towVehicleField, icon: Icons.directions_car_outlined,
                            validator: (v) => (v?.trim().isEmpty ?? true) ? s.towRequired : null),
                        const SizedBox(height: 12),
                        _Field(ctrl: _pickup, label: s.towPickupField, icon: Icons.location_on_outlined,
                            validator: (v) => (v?.trim().isEmpty ?? true) ? s.towRequired : null),
                        const SizedBox(height: 12),
                        _Field(ctrl: _destination, label: s.towDestField, icon: Icons.flag_outlined),
                        const SizedBox(height: 12),
                        _Field(ctrl: _notes, label: s.towNotesField, icon: Icons.notes_rounded, maxLines: 3),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: _loading ? null : _submit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 56,
                            decoration: BoxDecoration(
                              color: _loading ? AppTheme.red.withOpacity(0.6) : AppTheme.red,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: AppTheme.red.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
                            ),
                            child: Center(child: _loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Text(s.towSubmitBtn, style: AppTheme.mono(14, w: FontWeight.w800))),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                ),
              ]),
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final AppStrings s;
  final String status;
  final bool loading;
  final double? lat, lng;
  final VoidCallback onTap;
  const _LocationButton({required this.s, required this.status, required this.loading, required this.lat, required this.lng, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isOk = status == 'ok';
    final isError = status == 'error';
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOk ? const Color(0xFF002800) : isError ? const Color(0xFF1A0608) : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isOk ? const Color(0xFF00C47A) : isError ? AppTheme.red.withOpacity(0.5) : AppTheme.border, width: isOk ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isOk ? const Color(0xFF00C47A).withOpacity(0.15) : isError ? AppTheme.redGlow : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: loading
                ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00C47A))))
                : Icon(isOk ? Icons.location_on_rounded : isError ? Icons.location_off_rounded : Icons.my_location_rounded,
                    color: isOk ? const Color(0xFF00C47A) : isError ? AppTheme.red : AppTheme.white60, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isOk ? s.towLocationOk : isError ? s.towLocationError : s.towLocationBtn,
                style: AppTheme.mono(13, w: FontWeight.w700, color: isOk ? const Color(0xFF00C47A) : isError ? AppTheme.red : AppTheme.white80)),
            const SizedBox(height: 3),
            Text(isOk ? '${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}' : isError ? s.towLocationTapAgain : s.towLocationTap,
                style: AppTheme.mono(11, color: isOk ? const Color(0xFF00C47A).withOpacity(0.7) : AppTheme.white30)),
          ])),
          if (!loading) Icon(isOk ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: isOk ? const Color(0xFF00C47A) : AppTheme.white30, size: isOk ? 22 : 18),
        ]),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String reference;
  final VoidCallback onNew;
  final AppStrings s;
  const _SuccessView({required this.reference, required this.onNew, required this.s});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(color: const Color(0xFF002800), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00C47A), width: 2)),
          child: const Icon(Icons.check_rounded, color: Color(0xFF00C47A), size: 40),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(s.towSuccessTitle, style: AppTheme.display(26, w: FontWeight.w900)).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(s.towSuccessSub, style: AppTheme.body(14, color: AppTheme.white60), textAlign: TextAlign.center).animate(delay: 300.ms).fadeIn(),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
          child: Column(children: [
            Text(s.towRefLabel, style: AppTheme.mono(11, color: AppTheme.white30)),
            const SizedBox(height: 8),
            Text(reference, style: AppTheme.display(22, w: FontWeight.w800, color: AppTheme.red)),
            const SizedBox(height: 4),
            Text(s.towRefSaved, style: AppTheme.mono(11, color: AppTheme.white30)),
          ]),
        ).animate(delay: 400.ms).fadeIn(),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackScreen(initialReference: reference))),
          child: Container(height: 48,
            decoration: BoxDecoration(color: AppTheme.redGlow, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.red.withOpacity(0.4))),
            child: Center(child: Text(s.towTrackBtn, style: AppTheme.mono(13, w: FontWeight.w700, color: AppTheme.red))),
          ),
        ).animate(delay: 450.ms).fadeIn(),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onNew,
          child: Container(height: 48,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
            child: Center(child: Text(s.towNewBtn, style: AppTheme.mono(13, w: FontWeight.w600))),
          ),
        ).animate(delay: 500.ms).fadeIn(),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label;
  const _InfoChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppTheme.red), const SizedBox(width: 5),
      Text(label, style: AppTheme.mono(10, w: FontWeight.w600, color: AppTheme.white60)),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: AppTheme.mono(11, w: FontWeight.w700, color: AppTheme.white30)),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboard;
  final int maxLines;
  final String? Function(String?)? validator;
  const _Field({required this.ctrl, required this.label, required this.icon, this.keyboard, this.maxLines = 1, this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, keyboardType: keyboard, maxLines: maxLines,
    style: AppTheme.body(14), validator: validator,
    decoration: InputDecoration(
      labelText: label, labelStyle: AppTheme.body(13, color: AppTheme.white30),
      prefixIcon: Icon(icon, color: AppTheme.white30, size: 20),
      filled: true, fillColor: AppTheme.bgCard,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.red, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.red.withOpacity(0.7))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.red, width: 1.5)),
    ),
  );
}