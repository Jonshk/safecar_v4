// lib/screens/booking_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

const _kBase = 'https://safecar-backend.fly.dev';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  // Permite preseleccionar un service_type al navegar desde otra pantalla
  // (ej. el banner de Body Shop en Home). Se consume una sola vez.
  static String? presetServiceType;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _notes = TextEditingController();

  String _serviceType = 'oil_change';
  DateTime? _selectedDate;
  String _selectedTime = '09:00';
  bool _loading = false;
  bool _submitted = false;
  String? _reference;

  static const _services = [
    ('oil_change', 'Oil Change', Icons.opacity_rounded),
    ('brake_service', 'Brake Service', Icons.radio_button_on_rounded),
    ('diagnostics', 'Diagnostics', Icons.search_rounded),
    ('tire_rotation', 'Tire Rotation', Icons.rotate_right_rounded),
    ('general_repair', 'General Repair', Icons.build_rounded),
    ('body_collision_repair', 'Collision Repair', Icons.car_crash_rounded),
    (
      'body_paint_refinishing',
      'Paint & Refinishing',
      Icons.format_paint_rounded
    ),
    ('body_dent_removal', 'Dent Removal', Icons.remove_circle_outline_rounded),
    (
      'body_frame_straightening',
      'Frame Straightening',
      Icons.straighten_rounded
    ),
    ('body_shop_estimate', 'Body Shop Estimate', Icons.receipt_long_rounded),
    ('other', 'Other Service', Icons.more_horiz_rounded),
  ];

  static const _times = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00'
  ];

  @override
  void initState() {
    super.initState();
    if (BookingScreen.presetServiceType != null) {
      _serviceType = BookingScreen.presetServiceType!;
      BookingScreen.presetServiceType = null;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.red,
            onPrimary: Colors.white,
            surface: AppTheme.bgCard,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a date'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final res = await http.post(
        Uri.parse('$_kBase/bookings/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_name': _name.text.trim(),
          'customer_email': _email.text.trim(),
          'customer_phone': _phone.text.trim(),
          'vehicle_make': _make.text.trim(),
          'vehicle_model': _model.text.trim(),
          'vehicle_year': _year.text.trim(),
          'service_type': _serviceType,
          'preferred_date': dateStr,
          'preferred_time': _selectedTime,
          'notes': _notes.text.trim(),
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        setState(() {
          _submitted = true;
          _reference = data['reference'];
        });
      } else {
        _showError('Server error (${res.statusCode}). Try again.');
      }
    } catch (_) {
      _showError('No connection. Check your internet.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.red),
      );

  void _reset() => setState(() {
        _submitted = false;
        _reference = null;
        _selectedDate = null;
        _serviceType = 'oil_change';
        _selectedTime = '09:00';
        _name.clear();
        _email.clear();
        _phone.clear();
        _make.clear();
        _model.clear();
        _year.clear();
        _notes.clear();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: _submitted
            ? _SuccessView(reference: _reference!, onNew: _reset)
            : CustomScrollView(slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A0608),
                          Color(0xFF0E1118),
                          Color(0xFF080A0F)
                        ],
                      ),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.redGlow,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppTheme.red.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.build_circle_rounded,
                            color: AppTheme.red, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('BOOK A SERVICE',
                                style:
                                    AppTheme.display(20, w: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('Schedule your next appointment',
                                style:
                                    AppTheme.body(13, color: AppTheme.white60)),
                          ])),
                    ]),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0),
                ),

                // Selector de servicio
                SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text('SELECT SERVICE',
                              style: AppTheme.mono(11,
                                  w: FontWeight.w700, color: AppTheme.white30)),
                        ),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _services.length,
                            itemBuilder: (_, i) {
                              final s = _services[i];
                              final selected = _serviceType == s.$1;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _serviceType = s.$1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppTheme.redGlow
                                        : AppTheme.bgCard,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.red
                                          : AppTheme.border,
                                      width: selected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(s.$3,
                                            color: selected
                                                ? AppTheme.red
                                                : AppTheme.white30,
                                            size: 22),
                                        const Spacer(),
                                        Text(s.$2,
                                            style: AppTheme.mono(11,
                                                w: FontWeight.w700,
                                                color: selected
                                                    ? AppTheme.white80
                                                    : AppTheme.white60),
                                            maxLines: 2),
                                      ]),
                                )
                                    .animate(
                                        delay: Duration(milliseconds: 60 * i))
                                    .fadeIn()
                                    .slideX(begin: 0.1, end: 0),
                              );
                            },
                          ),
                        ),
                      ]),
                ),

                // Formulario
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Form(
                      key: _form,
                      child: Column(children: [
                        _SectionLabel('YOUR INFORMATION'),
                        const SizedBox(height: 12),
                        _Field(
                            ctrl: _name,
                            label: 'Full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Required'
                                : null),
                        const SizedBox(height: 12),
                        _Field(
                            ctrl: _email,
                            label: 'Email address',
                            icon: Icons.email_outlined,
                            keyboard: TextInputType.emailAddress,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Required'
                                : null),
                        const SizedBox(height: 12),
                        _Field(
                            ctrl: _phone,
                            label: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboard: TextInputType.phone,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Required'
                                : null),
                        const SizedBox(height: 20),
                        _SectionLabel('YOUR VEHICLE'),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: _Field(
                                  ctrl: _year,
                                  label: 'Year',
                                  icon: Icons.calendar_today_outlined,
                                  keyboard: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(
                              flex: 2,
                              child: _Field(
                                  ctrl: _make,
                                  label: 'Make',
                                  icon: Icons.directions_car_outlined)),
                        ]),
                        const SizedBox(height: 12),
                        _Field(
                            ctrl: _model,
                            label: 'Model',
                            icon: Icons.commute_rounded),
                        const SizedBox(height: 20),
                        _SectionLabel('PREFERRED DATE & TIME'),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _selectedDate != null
                                    ? AppTheme.red
                                    : AppTheme.border,
                                width: _selectedDate != null ? 1.5 : 1,
                              ),
                            ),
                            child: Row(children: [
                              Icon(Icons.calendar_month_rounded,
                                  color: _selectedDate != null
                                      ? AppTheme.red
                                      : AppTheme.white30,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                                    : 'Select date',
                                style: AppTheme.body(14,
                                    color: _selectedDate != null
                                        ? AppTheme.white80
                                        : AppTheme.white30),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppTheme.white30, size: 18),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _times.length,
                            itemBuilder: (_, i) {
                              final t = _times[i];
                              final sel = _selectedTime == t;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTime = t),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AppTheme.redGlow
                                        : AppTheme.bgCard,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color:
                                          sel ? AppTheme.red : AppTheme.border,
                                      width: sel ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(t,
                                      style: AppTheme.mono(12,
                                          w: FontWeight.w700,
                                          color: sel
                                              ? AppTheme.red
                                              : AppTheme.white60)),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionLabel('ADDITIONAL NOTES'),
                        const SizedBox(height: 12),
                        _Field(
                            ctrl: _notes,
                            label: 'Describe your issue or any details',
                            icon: Icons.notes_rounded,
                            maxLines: 3),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: _loading ? null : _submit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 56,
                            decoration: BoxDecoration(
                              color: _loading
                                  ? AppTheme.red.withOpacity(0.6)
                                  : AppTheme.red,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.red.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white))
                                  : Text('CONFIRM BOOKING',
                                      style: AppTheme.mono(14,
                                          w: FontWeight.w800)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ).animate(delay: 150.ms).fadeIn(),
                ),
              ]),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String reference;
  final VoidCallback onNew;
  const _SuccessView({required this.reference, required this.onNew});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF002800),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00C47A), width: 2),
          ),
          child: const Icon(Icons.check_rounded,
              color: Color(0xFF00C47A), size: 40),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('BOOKING CONFIRMED',
                style: AppTheme.display(24, w: FontWeight.w900))
            .animate(delay: 200.ms)
            .fadeIn()
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text('We\'ll call you to confirm your appointment.',
                style: AppTheme.body(14, color: AppTheme.white60),
                textAlign: TextAlign.center)
            .animate(delay: 300.ms)
            .fadeIn(),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(children: [
            Text('BOOKING REFERENCE',
                style: AppTheme.mono(11, color: AppTheme.white30)),
            const SizedBox(height: 8),
            Text(reference,
                style: AppTheme.display(22,
                    w: FontWeight.w800, color: AppTheme.red)),
            const SizedBox(height: 4),
            Text('Save this for your records',
                style: AppTheme.mono(11, color: AppTheme.white30)),
          ]),
        ).animate(delay: 400.ms).fadeIn(),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: onNew,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
                child: Text('New Booking',
                    style: AppTheme.mono(13, w: FontWeight.w600))),
          ),
        ).animate(delay: 500.ms).fadeIn(),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style:
                AppTheme.mono(11, w: FontWeight.w700, color: AppTheme.white30)),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboard;
  final int maxLines;
  final String? Function(String?)? validator;
  const _Field(
      {required this.ctrl,
      required this.label,
      required this.icon,
      this.keyboard,
      this.maxLines = 1,
      this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: AppTheme.body(14),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.body(13, color: AppTheme.white30),
          prefixIcon: Icon(icon, color: AppTheme.white30, size: 20),
          filled: true,
          fillColor: AppTheme.bgCard,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.red, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.red.withOpacity(0.7))),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.red, width: 1.5)),
        ),
      );
}
