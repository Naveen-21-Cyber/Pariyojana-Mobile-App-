import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../project_tracker/presentation/providers/project_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/ai_interview_simulator.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;

  const JobDetailScreen({
    super.key,
    required this.jobId,
  });

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  final Map<String, bool> _checklistState = {};
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Saved':
        return const Color(0xFF64748B);
      case 'Applied':
      case 'Outreach Sent':
        return const Color(0xFF3B82F6);
      case 'Shortlisted':
      case 'Response':
        return const Color(0xFF8B5CF6);
      case 'Interview':
      case 'Interviewing':
        return const Color(0xFFF97316);
      case 'Offer':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      default:
        return VelvetColors.periwinkle;
    }
  }

  Future<void> _updateStage(JobApplication job, String status) async {
    final updated = job.copyWith(
      status: status,
      // If we move to outreach sent, automatically suggest a 7-day follow-up
      followUpDate: drift.Value(
        status == 'Outreach Sent'
            ? DateTime.now().add(const Duration(days: 7))
            : job.followUpDate,
      ),
    );
    await ref.read(jobRepositoryProvider).updateApplication(updated);
  }

  Future<void> _setFollowUpDate(JobApplication job) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: job.followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      final updated = job.copyWith(followUpDate: drift.Value(picked));
      await ref.read(jobRepositoryProvider).updateApplication(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobApplicationsStreamProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      backgroundColor: VelvetColors.surface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: VelvetColors.iconColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Application Details',
          style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 12) {
            context.pop();
          }
        },
        child: jobsAsync.when(
        data: (jobs) {
          final job = jobs.firstWhereOrNull((j) => j.id == widget.jobId);
          if (job == null) {
            return const Center(child: Text('Application not found'));
          }

          final isOverdue = job.status == 'Outreach Sent' &&
              (job.followUpDate != null
                  ? DateTime.now().isAfter(job.followUpDate!)
                  : DateTime.now().difference(job.createdAt).inDays >= 7);

          Project? linkedProject;
          if (job.projectId != null) {
            linkedProject = projectsAsync.value?.firstWhereOrNull((p) => p.id == job.projectId);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header overview card
                ClayCard(
                  color: VelvetColors.cardSurface(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.role,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: VelvetColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: VelvetColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(job.status).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getStatusColor(job.status).withValues(alpha: 0.45)),
                            ),
                            child: Text(
                              job.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: VelvetColors.textPrimary(context),
                              ),
                            ),
                          ),
                          if (job.outreachChannel != null && job.outreachChannel!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: VelvetColors.periwinkle.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                job.outreachChannel!,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (job.salaryTarget != null || job.contactPerson != null || job.jobUrl != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (job.salaryTarget != null && job.salaryTarget!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: VelvetColors.mint.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '💰 Target: ${job.salaryTarget}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                                ),
                              ),
                            if (job.contactPerson != null && job.contactPerson!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '👤 Recruiter: ${job.contactPerson}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                ),
                              ),
                          ],
                        ),
                        if (job.jobUrl != null && job.jobUrl!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.link_rounded, size: 14, color: VelvetColors.coralPeach),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job.jobUrl!,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Overdue Follow-up alert nudge
                if (isOverdue) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notification_important_rounded, color: Colors.orangeAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FOLLOW-UP OVERDUE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.followUpDate != null
                                    ? 'Follow-up was scheduled on ${DateFormat('yMMMd').format(job.followUpDate!)}. Send a check-in message.'
                                    : 'It has been 7+ days since this outreach was logged. Check outreach channels.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orangeAccent.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],


                // Outreach & Resume Details
                ClayCard(
                  color: VelvetColors.cardSurface(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_ind_outlined, color: VelvetColors.iconColor(context)),
                          const SizedBox(width: 8),
                          Text(
                            'Pipeline & Intel Information',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: VelvetColors.textPrimary(context),
                                ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: VelvetColors.clayTan),
                      _buildDetailRow('Outreach Channel', job.outreachChannel ?? 'Not Configured'),
                      _buildDetailRow('Resume Version', job.resumeVersion ?? 'Default Resume'),
                      _buildDetailRow(
                        'Follow-up Date',
                        job.followUpDate == null
                            ? 'Not Scheduled'
                            : DateFormat('yMMMd').format(job.followUpDate!),
                      ),

                      // Linked project link
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 96,
                              child: Text(
                                'Linked Project',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.clayTan),
                              ),
                            ),
                            Expanded(
                              child: linkedProject != null
                                  ? TextButton.icon(
                                      onPressed: () => context.go('/projects/${linkedProject!.id}'),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.centerLeft,
                                        foregroundColor: VelvetColors.periwinkle,
                                      ),
                                      icon: const Icon(Icons.link_rounded, size: 14),
                                      label: Text(linkedProject.name, style: const TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
                                    )
                                  : Text(
                                      'No Linked Project',
                                      style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(height: 20, color: VelvetColors.clayTan),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VelvetColors.coralPeach,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.psychology_outlined, size: 16),
                              label: const Text('Practice AI Interview 🎯', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AiInterviewSimulator(job: job),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: job.status,
                              decoration: const InputDecoration(
                                labelText: 'Move Stage',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: VelvetColors.clayTan)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)), borderSide: BorderSide(color: VelvetColors.coralPeach, width: 2)),
                              ),
                              dropdownColor: VelvetColors.dropdownFill(context),
                              borderRadius: BorderRadius.circular(20),
                              menuMaxHeight: 220,
                              items: ['Saved', 'Applied', 'Shortlisted', 'Interview', 'Offer', 'Rejected']
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s, style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13, fontWeight: FontWeight.bold)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) _updateStage(job, val);
                              },
                            ),
                          ),
                          if (job.status == 'Outreach Sent') ...[
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.calendar_month_rounded, color: VelvetColors.coralPeach, size: 28),
                              onPressed: () => _setFollowUpDate(job),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildPrepChecklist(context, job),
                const SizedBox(height: 20),

                // Job Description Card
                if (job.jdSnapshot != null && job.jdSnapshot!.isNotEmpty) ...[
                  ClayCard(
                    color: VelvetColors.cardSurface(context),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job Description (JD) Snapshot',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.jdSnapshot!,
                          style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading details: $err')),
      ),
    ),
  );
  }

  Widget _buildPrepChecklist(BuildContext context, JobApplication job) {
    final status = job.status;
    List<String> items = [];
    String title = 'Preparation Tracker';

    if (status == 'Saved' || status == 'Applied') {
      title = 'Apply & Outreach Checklist';
      items = [
        'Find a warm referral inside the company',
        'Verify resume contains keywords from description',
        'Draft outreach message for hiring manager',
        'Send application and update tracking log'
      ];
    } else if (status == 'Outreach Sent' || status == 'Response') {
      title = 'Outreach Follow-Up Checklist';
      items = [
        'Set calendar reminder for 7-day outreach nudge',
        'Locate hiring manager\'s profile on LinkedIn',
        'Read companies latest release notes / blog updates',
        'Prepare introductory self-bio pitch'
      ];
    } else if (status == 'Interview') {
      title = 'Interview Preparation Guide';
      items = [
        'Research the interview panel members',
        'Prepare 3-5 high-value questions for them',
        'Review project portfolio and technical designs',
        'Practice mock coding and design sessions'
      ];
    } else if (status == 'Offer') {
      title = 'Offer Negotiation Guide';
      items = [
        'Review base salary against market rates',
        'Evaluate equity / stock details and vesting schedule',
        'Review health insurance and auxiliary benefits',
        'Draft accept / negotiate email response'
      ];
    } else {
      title = 'Application Retrospective Checklist';
      items = [
        'Review tech stack gaps from interview feedback',
        'Update portfolio projects with new insights',
        'Reach out to interviewer for constructive feedback',
        'Identify 3 new target companies to apply to'
      ];
    }

    return ClayCard(
      color: VelvetColors.cardSurface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: VelvetColors.coralPeach, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: VelvetColors.clayTan),
          ...items.map((item) {
            final key = '${job.id}_$item';
            final isChecked = _checklistState[key] ?? false;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _checklistState[key] = !isChecked;
                });
                ref.read(hapticServiceProvider).lightTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isChecked ? VelvetColors.coralPeach : VelvetColors.clayTan,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: VelvetColors.textPrimary(context),
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: VelvetColors.textSecondary(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: VelvetColors.textPrimary(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
