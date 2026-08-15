import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velvet/features/presentation/navigation_shell.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/i18n/app_translation.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../project_tracker/presentation/providers/project_provider.dart';
import '../providers/job_provider.dart';
import '../../../../shared_widgets/interactive_3d_tilt_card.dart';
import '../widgets/pdf_resume_matcher.dart';
import '../widgets/lpa_tax_calculator.dart';
import '../widgets/job_analytics_funnel.dart';
import '../widgets/company_dossier_modal.dart';
import '../../../../shared_widgets/workspace_tab_guide_modal.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  String _selectedStageFilter = 'All';
  final List<String> _stages = ['All', 'Saved', 'Applied', 'Shortlisted', 'Interview', 'Offer', 'Rejected'];

  void _showAddJobSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddJobSheet(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Saved':
        return const Color(0xFF64748B); // Slate
      case 'Applied':
      case 'Outreach Sent':
        return const Color(0xFF3B82F6); // Royal Blue
      case 'Shortlisted':
      case 'Response':
        return const Color(0xFF8B5CF6); // Deep Violet / Purple
      case 'Interview':
      case 'Interviewing':
        return const Color(0xFFF97316); // Vibrant Orange
      case 'Offer':
        return const Color(0xFF10B981); // Emerald Green
      case 'Rejected':
        return const Color(0xFFEF4444); // Crimson Red
      default:
        return VelvetColors.periwinkle;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(quickCaptureTriggerProvider, (previous, next) {
      if (next == 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showAddJobSheet();
            ref.read(quickCaptureTriggerProvider.notifier).state = null;
          }
        });
      }
    });

    final jobsAsync = ref.watch(jobApplicationsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          'Job Applications',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        TranslatedText(
                          'Pipeline: Saved → Applied → Shortlisted → Interview → Offer.',
                          style: TextStyle(
                            color: VelvetColors.textSecondary(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_book_rounded, color: VelvetColors.periwinkle),
                    tooltip: 'Job Tracker & Career Guide 📖',
                    onPressed: () => WorkspaceTabGuideModal.show(context, initialTab: 'jobs'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats pills bar
              jobsAsync.when(
                data: (jobs) {
                  final applied = jobs.where((j) => j.status == 'Applied' || j.status == 'Outreach Sent').length;
                  final interviews = jobs.where((j) => j.status == 'Interview' || j.status == 'Interviewing' || j.status == 'Response').length;
                  final offers = jobs.where((j) => j.status == 'Offer').length;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _JobPill(label: 'Applied', count: applied, color: VelvetColors.periwinkle),
                      _JobPill(label: 'Interviews', count: interviews, color: const Color(0xFFFFE4B5)),
                      _JobPill(label: 'Offers', count: offers, color: VelvetColors.mint),
                      GestureDetector(
                        onTap: () => CompanyDossierModal.show(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: VelvetColors.coralPeach,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: VelvetColors.coralPeach.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.saved_search_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '🏢 AI Company & JD Intel 🕵️‍♂️',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              jobsAsync.when(
                data: (jobs) => JobAnalyticsFunnel(jobs: jobs),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final stage in _stages) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedStageFilter = stage),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _selectedStageFilter == stage ? VelvetColors.coralPeach : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedStageFilter == stage ? VelvetColors.coralPeach : VelvetColors.clayTan,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              stage,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _selectedStageFilter == stage ? Colors.white : VelvetColors.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ClayCard(
                      color: VelvetColors.cardSurface(context),
                      padding: const EdgeInsets.all(12),
                      onTap: () => PdfResumeMatcherModal.show(context),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.picture_as_pdf_rounded, color: VelvetColors.coralPeach, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🎯 AI Resume Matcher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                SizedBox(height: 2),
                                Text('Scan CV & test JD fit %', style: TextStyle(fontSize: 9.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClayCard(
                      color: VelvetColors.cardSurface(context),
                      padding: const EdgeInsets.all(12),
                      onTap: () => LpaTaxCalculatorModal.show(context),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.calculate_rounded, color: VelvetColors.periwinkle, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🧮 LPA Tax Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                SizedBox(height: 2),
                                Text('Calculate in-hand salary', style: TextStyle(fontSize: 9.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              jobsAsync.when(
                data: (jobs) {
                  final filtered = jobs.where((j) {
                    if (_selectedStageFilter == 'All') return true;
                    return j.status == _selectedStageFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              VelvetColors.mint.withValues(alpha: 0.18),
                              VelvetColors.periwinkle.withValues(alpha: 0.08),
                              VelvetColors.surface(context),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: VelvetColors.mint.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: VelvetColors.mint.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: VelvetColors.mint.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: VelvetColors.mint),
                              ),
                              child: const Icon(Icons.work_history_rounded, size: 36, color: VelvetColors.mint),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No $_selectedStageFilter Jobs Found',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: VelvetColors.textPrimary(context)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Track career opportunities, analyze JD keyword alignment, generate dossiers & salary offers.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context)),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VelvetColors.mint,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add Job Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              onPressed: _showAddJobSheet,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filtered.map((job) {
                      final isOverdue = job.status == 'Outreach Sent' &&
                          (job.followUpDate != null
                              ? DateTime.now().isAfter(job.followUpDate!)
                              : DateTime.now().difference(job.createdAt).inDays >= 7);

                        final statusColor = _getStatusColor(job.status);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Interactive3DTiltCard(
                            onTap: () => context.go('/jobs/${job.id}'),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Left status strip — vivid & wide
                                    Container(
                                      width: 8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          bottomLeft: Radius.circular(18),
                                        ),
                                      ),
                                    ),
                                    // Card content
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              job.company,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: VelvetColors.textPrimary(context),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              job.role,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: VelvetColors.textSecondary(context),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: statusColor,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      job.status,
                                                      style: const TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        letterSpacing: 0.3,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  job.outreachChannel ?? '',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: VelvetColors.textSecondary(context),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              if (job.salaryTarget != null && job.salaryTarget!.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: VelvetColors.mint.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '💰 ${job.salaryTarget}',
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal),
                                                  ),
                                                ),
                                              if (job.contactPerson != null && job.contactPerson!.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '👤 ${job.contactPerson}',
                                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                                  ),
                                                ),
                                              if (job.jobUrl != null && job.jobUrl!.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.link, size: 10, color: VelvetColors.coralPeach),
                                                      const SizedBox(width: 3),
                                                      ConstrainedBox(
                                                        constraints: const BoxConstraints(maxWidth: 110),
                                                        child: Text(
                                                          job.jobUrl!,
                                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (isOverdue) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.orangeAccent.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.notification_important_rounded, size: 13, color: Colors.orangeAccent),
                                                  SizedBox(width: 5),
                                                  Flexible(
                                                    child: Text(
                                                      'Overdue for follow-up!',
                                                      style: TextStyle(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading applications: $err')),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _JobPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: VelvetColors.textPrimary(context),
        ),
      ),
    );
  }
}

class _AddJobSheet extends ConsumerStatefulWidget {
  const _AddJobSheet();

  @override
  ConsumerState<_AddJobSheet> createState() => _AddJobSheetState();
}

class _AddJobSheetState extends ConsumerState<_AddJobSheet> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _resumeController = TextEditingController(text: 'Resume_Default.pdf');
  final _outreachController = TextEditingController(text: 'LinkedIn DM');
  final _jdController = TextEditingController();
  final _salaryController = TextEditingController();
  final _jobUrlController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedStatus = 'Saved';
  int? _selectedProjectId;

  final List<String> _outreachPresets = ['LinkedIn DM', 'Email', 'Referral', 'Twitter/X', 'Company Portal', 'Cold Outreach'];

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _resumeController.dispose();
    _outreachController.dispose();
    _jdController.dispose();
    _salaryController.dispose();
    _jobUrlController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    final companion = JobApplicationsCompanion.insert(
      company: _companyController.text.trim(),
      role: _roleController.text.trim(),
      status: _selectedStatus,
      jdSnapshot: drift.Value(_jdController.text.trim().isEmpty ? null : _jdController.text.trim()),
      resumeVersion: drift.Value(_resumeController.text.trim().isEmpty ? null : _resumeController.text.trim()),
      outreachChannel: drift.Value(_outreachController.text.trim().isEmpty ? null : _outreachController.text.trim()),
      salaryTarget: drift.Value(_salaryController.text.trim().isEmpty ? null : _salaryController.text.trim()),
      jobUrl: drift.Value(_jobUrlController.text.trim().isEmpty ? null : _jobUrlController.text.trim()),
      contactPerson: drift.Value(_contactController.text.trim().isEmpty ? null : _contactController.text.trim()),
      projectId: drift.Value(_selectedProjectId),
      followUpDate: drift.Value(
        _selectedStatus == 'Outreach Sent'
            ? DateTime.now().add(const Duration(days: 7))
            : null,
      ),
    );

    await ref.read(jobRepositoryProvider).insertApplication(companion);

    // Physical success haptic vibration
    await ref.read(hapticServiceProvider).successPattern();

    if (mounted) {
      Navigator.of(context).pop();
      showGlassSnackBar(
        context,
        message: 'Job application added successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    InputDecoration buildInputDecoration(String label) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: VelvetColors.textSecondary(context)),
        filled: true,
        fillColor: VelvetColors.inputFill(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: VelvetColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : VelvetColors.clayTan.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.50),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: VelvetColors.border(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Job Application',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context), size: 24),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close sheet',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onPressed: _submitJob,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Add Application (Quick Save)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _companyController,
                  decoration: buildInputDecoration('Company'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter company name' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _roleController,
                  decoration: buildInputDecoration('Job Role'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter role title' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: buildInputDecoration('Stage'),
                        dropdownColor: VelvetColors.dropdownFill(context),
                        borderRadius: BorderRadius.circular(20),
                        menuMaxHeight: 280,
                        isExpanded: true,
                        items: ['Saved', 'Applied', 'Shortlisted', 'Interview', 'Offer', 'Rejected']
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 11, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedStatus = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _outreachController,
                        decoration: buildInputDecoration('Outreach Channel'),
                        style: TextStyle(color: VelvetColors.textPrimary(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6.0,
                  children: _outreachPresets.map((channel) {
                    final isSel = _outreachController.text.trim() == channel;
                    return ActionChip(
                      label: Text(
                        channel,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSel ? Colors.white : VelvetColors.textPrimary(context),
                        ),
                      ),
                      backgroundColor: isSel ? VelvetColors.coralPeach : VelvetColors.chipBg(context),
                      onPressed: () => setState(() => _outreachController.text = channel),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salaryController,
                        decoration: buildInputDecoration('Target Compensation / Salary'),
                        style: TextStyle(color: VelvetColors.textPrimary(context)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _contactController,
                        decoration: buildInputDecoration('Recruiter / Contact Info'),
                        style: TextStyle(color: VelvetColors.textPrimary(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _jobUrlController,
                  decoration: buildInputDecoration('Job Posting URL'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _resumeController,
                  decoration: buildInputDecoration('Resume Version'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _jdController,
                  decoration: buildInputDecoration('Job Description (JD) Notes'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                projectsAsync.when(
                  data: (projects) {
                    return DropdownButtonFormField<int?>(
                      initialValue: _selectedProjectId,
                      decoration: buildInputDecoration('Related Project (optional)'),
                      dropdownColor: VelvetColors.surface(context),
                      borderRadius: BorderRadius.circular(20),
                      menuMaxHeight: 320,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('No Project Link', style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 11)),
                        ),
                        ...projects.map((p) => DropdownMenuItem<int?>(
                              value: p.id,
                              child: Text(
                                p.name,
                                style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (val) => setState(() => _selectedProjectId = val),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
