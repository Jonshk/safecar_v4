import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/lang_provider.dart';
import '../widgets/shared.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});
  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  List<Course> _courses = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await ApiService.getCourses();
    if (!mounted) return;
    setState(() { _courses = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LangProvider>().s;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(child: RefreshIndicator(
        onRefresh: _load, color: AppTheme.red, backgroundColor: AppTheme.bgCard,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.trainingTag, style: AppTheme.mono(11, color: AppTheme.amber, w: FontWeight.w700)),
              Text(s.trainingTitle, style: AppTheme.display(28, w: FontWeight.w800)),
            ]),
          )),
          SliverToBoxAdapter(child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1A1200), Color(0xFF0E1118)]),
              border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.trainingBannerTitle, style: AppTheme.display(18, w: FontWeight.w900), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(s.trainingBannerSub, style: AppTheme.body(13, color: AppTheme.white60)),
              ])),
              Container(width: 64, height: 64,
                decoration: BoxDecoration(color: AppTheme.amberGlow, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.amber.withOpacity(0.3))),
                child: const Icon(Icons.school_outlined, color: AppTheme.amber, size: 30)),
            ]),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0)),
          SliverToBoxAdapter(child: _buildList(s)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      )),
    );
  }

  Widget _buildList(s) {
    if (_loading) {
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: List.generate(4, (_) =>
          Container(margin: const EdgeInsets.only(bottom: 16),
            child: const ShimmerBox(w: double.infinity, h: 110, radius: 20)))));
    }
    if (_courses.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border)),
        child: Column(children: [
          const Icon(Icons.menu_book_outlined, color: AppTheme.white30, size: 40),
          const SizedBox(height: 12),
          Text(s.trainingNoneTitle, style: AppTheme.body(14, color: AppTheme.white60)),
          const SizedBox(height: 6),
          Text(s.trainingNoneSub, style: AppTheme.mono(11, color: AppTheme.white30)),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(label: s.trainingAllCourses),
        const SizedBox(height: 16),
        ...(_courses.asMap().entries.map((e) =>
          CourseCard(course: e.value, index: e.key, onTap: () {}))),
      ]),
    );
  }
}
