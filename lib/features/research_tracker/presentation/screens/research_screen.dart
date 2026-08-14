import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../idea_vault/presentation/screens/biometric_vault_screen.dart';
import '../../../../core/security/auth_service.dart';
import 'package:velvet/features/presentation/navigation_shell.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/i18n/app_translation.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../project_tracker/presentation/providers/project_provider.dart';
import '../providers/research_provider.dart';
import 'package:velvet/features/ai_agents/domain/agents.dart';
import '../../../../shared_widgets/dynamic_island.dart';
import '../../../../shared_widgets/interactive_3d_tilt_card.dart';
import '../widgets/pdf_research_summarizer.dart';
import '../widgets/pdf_highlighter_sheet.dart';
import '../../../../shared_widgets/workspace_tab_guide_modal.dart';

class ResearchScreen extends ConsumerStatefulWidget {
  const ResearchScreen({super.key});

  @override
  ConsumerState<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends ConsumerState<ResearchScreen> {
  String _selectedStatusFilter = 'All';
  final List<String> _statuses = ['All', 'Draft', 'Preliminary Upload', 'Under Review', 'Published', 'Rejected'];
  bool _isDashboardExpanded = true;
  List<int> _securePaperIds = [];

  @override
  void initState() {
    super.initState();
    _loadSecureIds();
  }

  Future<void> _loadSecureIds() async {
    final secureIds = await ref.read(secureStorageProvider).getSecurePaperIds();
    if (mounted) {
      setState(() {
        _securePaperIds = secureIds;
      });
    }
  }

  Future<void> _lockPaper(ResearchPaper paper) async {
    await ref.read(secureStorageProvider).setPaperSecure(paper.id, true);
    await _loadSecureIds();
    if (mounted) {
      GlassSnackBar.show(context, 'Research Paper locked in secure vault 🔒');
    }
  }

  void _showAddPaperSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddPaperSheet(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return const Color(0xFFE65100);
      case 'In Writing':
        return const Color(0xFF7B1FA2);
      case 'Preliminary Upload':
        return const Color(0xFFD84315);
      case 'Under Review':
        return const Color(0xFF1565C0);
      case 'Published':
        return const Color(0xFF2E7D32);
      case 'Rejected':
        return const Color(0xFFC62828);
      default:
        return VelvetColors.cocoa;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(quickCaptureTriggerProvider, (previous, next) {
      if (next == 2) {
        _showAddPaperSheet();
        ref.read(quickCaptureTriggerProvider.notifier).state = null;
      }
    });

    ref.listen<String?>(quickAddTriggerProvider, (previous, next) {
      if (next == 'research') {
        _showAddPaperSheet();
        ref.read(quickAddTriggerProvider.notifier).state = null;
      }
    });

    final papersAsync = ref.watch(researchPapersStreamProvider);

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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: TranslatedText(
                        'Research Tracker',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_book_rounded, color: VelvetColors.periwinkle),
                        tooltip: 'Research Hub Guide 📖',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () => WorkspaceTabGuideModal.show(context, initialTab: 'research'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lock_outline_rounded, color: VelvetColors.coralPeach),
                        tooltip: 'Secure Vault',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BiometricVaultScreen(),
                            ),
                          );
                          await _loadSecureIds();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TranslatedText(
                'SSRN, arXiv abstracts, and submission statuses.',
                style: TextStyle(
                  color: VelvetColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),

              // Pipeline stats bar
              papersAsync.when(
                data: (papers) {
                  final draft = papers.where((p) => p.status == 'Draft').length;
                  final submitted = papers.where((p) => p.status == 'Preliminary Upload').length;
                  final review = papers.where((p) => p.status == 'Under Review').length;
                  final published = papers.where((p) => p.status == 'Published').length;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ResPill(label: 'Draft', count: draft, color: VelvetColors.clayTan),
                      _ResPill(label: 'Submitted', count: submitted, color: VelvetColors.periwinkle),
                      _ResPill(label: 'Review', count: review, color: const Color(0xFFFFE4B5)),
                      _ResPill(label: 'Published', count: published, color: VelvetColors.mint),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelvetColors.coralPeach,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.auto_stories_rounded, size: 13),
                        label: const Text('Summarize PDF 📄', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        onPressed: () => PdfResearchSummarizerSheet.show(context),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelvetColors.periwinkle,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.edit_note_rounded, size: 13),
                        label: const Text('PDF Annotator 📝', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        onPressed: () => PdfHighlighterSheet.show(context, 'PDF Research Document'),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),


              // Colorful Research Domain & Impact Spectrum Card
              papersAsync.when(
                data: (papers) {
                  if (papers.isEmpty) return const SizedBox.shrink();

                  final totalCitations = papers.fold<int>(0, (prev, p) => prev + p.citationCount);
                  final highImpact = papers.where((p) => p.citationCount > 5).length;
                  final published = papers.where((p) => p.status == 'Published').length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClayCard(
                      color: VelvetColors.cardSurface(context),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _isDashboardExpanded = !_isDashboardExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.palette_rounded, size: 16, color: VelvetColors.coralPeach),
                                    const SizedBox(width: 6),
                                    Text(
                                      'RESEARCH DOMAIN & IMPACT SPECTRUM',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.5,
                                        color: VelvetColors.textPrimary(context),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  _isDashboardExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: VelvetColors.periwinkle,
                                ),
                              ],
                            ),
                          ),
                          if (_isDashboardExpanded) ...[
                            const SizedBox(height: 14),
                            // Colorful Impact Badges
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [VelvetColors.coralPeach.withValues(alpha: 0.2), VelvetColors.coralPeach.withValues(alpha: 0.05)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('Citations 📈', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach)),
                                        const SizedBox(height: 2),
                                        Text('$totalCitations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [VelvetColors.mint.withValues(alpha: 0.25), VelvetColors.mint.withValues(alpha: 0.05)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: VelvetColors.mint.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('Published 🏆', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: VelvetColors.mint)),
                                        const SizedBox(height: 2),
                                        Text('$published', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [VelvetColors.periwinkle.withValues(alpha: 0.25), VelvetColors.periwinkle.withValues(alpha: 0.05)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('High Impact 🌟', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: VelvetColors.periwinkle)),
                                        const SizedBox(height: 2),
                                        Text('$highImpact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Multi-color Progress Spectrum Bars for Papers
                            const Text('PAPERS FIELD DISTRIBUTION & READINESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: VelvetColors.periwinkle, letterSpacing: 1.0)),
                            const SizedBox(height: 6),
                            ...papers.take(4).map((paper) {
                              final colors = [VelvetColors.coralPeach, VelvetColors.periwinkle, VelvetColors.mint, Colors.orangeAccent];
                              final color = colors[paper.id % colors.length];
                              final progress = (paper.citationCount / (totalCitations > 0 ? totalCitations : 1)).clamp(0.2, 1.0);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            paper.title,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${paper.status} • ${paper.citationCount} cite',
                                          style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 6,
                                        backgroundColor: VelvetColors.clayTan.withValues(alpha: 0.25),
                                        valueColor: AlwaysStoppedAnimation<Color>(color),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statuses.map((status) {
                    final isSelected = _selectedStatusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedStatusFilter = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? VelvetColors.coralPeach : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? VelvetColors.coralPeach : VelvetColors.border(context),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : VelvetColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              papersAsync.when(
                data: (papers) {
                  final filtered = papers.where((p) {
                    if (_securePaperIds.contains(p.id)) return false;
                    if (_selectedStatusFilter == 'All') return true;
                    return p.status == _selectedStatusFilter;
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
                              VelvetColors.periwinkle.withValues(alpha: 0.15),
                              VelvetColors.coralPeach.withValues(alpha: 0.08),
                              VelvetColors.surface(context),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: VelvetColors.periwinkle.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: VelvetColors.periwinkle.withValues(alpha: 0.1),
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
                                color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: VelvetColors.periwinkle),
                              ),
                              child: const Icon(Icons.auto_stories_rounded, size: 36, color: VelvetColors.periwinkle),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No $_selectedStatusFilter Papers Found',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: VelvetColors.textPrimary(context)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Log research publications, track arXiv papers, highlight PDFs, and compute citation h-indices.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context)),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VelvetColors.periwinkle,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add Research Paper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              onPressed: _showAddPaperSheet,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final paper = filtered[index];
                        final isStalled = paper.status == 'Preliminary Upload' &&
                            DateTime.now().difference(paper.updatedAt).inDays >= 7;

                        final statusColor = _getStatusColor(paper.status);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Interactive3DTiltCard(
                            onTap: () => context.go('/research/${paper.id}'),
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
                                              paper.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: VelvetColors.textPrimary(context),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                if (paper.abstractId != null && paper.abstractId!.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFBBDEFB),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      paper.abstractId!,
                                                      style: const TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF0D47A1),
                                                      ),
                                                    ),
                                                  ),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    paper.status,
                                                    style: const TextStyle(
                                                      fontSize: 9.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                if (paper.targetVenue != null && paper.targetVenue!.isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFCDD2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '🏛️ ${paper.targetVenue}',
                                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C)),
                                                    ),
                                                  ),
                                                if (paper.submissionDeadline != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '📅 Submit: ${paper.submissionDeadline!.day}/${paper.submissionDeadline!.month}/${paper.submissionDeadline!.year}',
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (paper.keywords != null && paper.keywords!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 4,
                                                children: paper.keywords!.split(',').take(4).map((kw) {
                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: VelvetColors.clayTan.withValues(alpha: 0.35),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      '#${kw.trim()}',
                                                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Citations: ${paper.citationCount}',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: VelvetColors.textPrimary(context),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                         InkWell(
                                                           onTap: () => PdfHighlighterSheet.show(context, paper.title),
                                                           child: Container(
                                                             padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                             decoration: BoxDecoration(
                                                               color: VelvetColors.periwinkle.withValues(alpha: 0.18),
                                                               borderRadius: BorderRadius.circular(8),
                                                               border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.4)),
                                                             ),
                                                             child: Row(
                                                               mainAxisSize: MainAxisSize.min,
                                                               children: [
                                                                 const Icon(Icons.edit_note_rounded, size: 13, color: VelvetColors.periwinkle),
                                                                 const SizedBox(width: 3),
                                                                 Text(
                                                                   'Annotate PDF 📝',
                                                                   style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                         const SizedBox(width: 6),
                                                         IconButton(
                                                           icon: const Icon(Icons.lock_outline_rounded, color: VelvetColors.coralPeach, size: 18),
                                                           padding: EdgeInsets.zero,
                                                           constraints: const BoxConstraints(),
                                                           onPressed: () => _lockPaper(paper),
                                                           tooltip: 'Lock in Secure Vault',
                                                         ),
                                                         const SizedBox(width: 6),
                                                         const Text(
                                                           'View Details →',
                                                           style: TextStyle(
                                                             fontSize: 10.5,
                                                             fontWeight: FontWeight.w600,
                                                             color: VelvetColors.coralPeach,
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                              ],
                                            ),
                                            if (isStalled) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.warning_amber_rounded, size: 13, color: Colors.redAccent),
                                                    SizedBox(width: 5),
                                                    Flexible(
                                                      child: Text(
                                                        'Stalled 7+ days',
                                                        style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold),
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
                      },
                    );
                  },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading papers: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ResPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
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

class _AddPaperSheet extends ConsumerStatefulWidget {
  const _AddPaperSheet();

  @override
  ConsumerState<_AddPaperSheet> createState() => _AddPaperSheetState();
}

class _AddPaperSheetState extends ConsumerState<_AddPaperSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _abstractIdController = TextEditingController();
  final _linkController = TextEditingController();
  final _coAuthorsController = TextEditingController();
  final _venueController = TextEditingController();
  final _keywordsController = TextEditingController();
  
  String _selectedStatus = 'Draft';
  DateTime? _selectedSubmissionDeadline;
  int? _selectedProjectId;
  bool _isAutofilling = false;

  final List<String> _venuePresetChips = ['arXiv', 'IEEE', 'ACM', 'SSRN', 'Springer', 'Nature', 'Cryptology ePrint'];

  Future<void> _autofill() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showGlassSnackBar(
        context,
        message: 'Please enter a paper title first',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.amber,
      );
      return;
    }

    setState(() => _isAutofilling = true);

    try {
      final agent = ref.read(autofillAgentProvider);
      final result = await agent.autofillResearch(title);
      
      if (result.abstractId.isNotEmpty) {
        _abstractIdController.text = result.abstractId;
      }
      if (result.paperLink.isNotEmpty) {
        _linkController.text = result.paperLink;
      }
      if (result.coAuthors.isNotEmpty) {
        _coAuthorsController.text = result.coAuthors;
      }

      if (mounted) {
        showGlassSnackBar(
          context,
          message: 'AI Autofill completed successfully!',
          icon: Icons.auto_awesome,
          iconColor: VelvetColors.coralPeach,
        );
      }
    } catch (e) {
      if (mounted) {
        showGlassSnackBar(
          context,
          message: 'Autofill error: $e',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAutofilling = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _abstractIdController.dispose();
    _linkController.dispose();
    _coAuthorsController.dispose();
    _venueController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _submitPaper() async {
    if (!_formKey.currentState!.validate()) return;

    final companion = ResearchPapersCompanion.insert(
      title: _titleController.text.trim(),
      abstractId: drift.Value(_abstractIdController.text.trim().isEmpty ? null : _abstractIdController.text.trim()),
      status: _selectedStatus,
      coAuthors: drift.Value(_coAuthorsController.text.trim().isEmpty ? null : _coAuthorsController.text.trim()),
      paperLink: drift.Value(_linkController.text.trim().isEmpty ? null : _linkController.text.trim()),
      targetVenue: drift.Value(_venueController.text.trim().isEmpty ? null : _venueController.text.trim()),
      submissionDeadline: drift.Value(_selectedSubmissionDeadline),
      keywords: drift.Value(_keywordsController.text.trim().isEmpty ? null : _keywordsController.text.trim()),
      projectId: drift.Value(_selectedProjectId),
    );

    await ref.read(researchRepositoryProvider).insertPaper(companion);

    // Physical success haptic vibration
    await ref.read(hapticServiceProvider).successPattern();

    if (mounted) {
      Navigator.of(context).pop();
      showGlassSnackBar(
        context,
        message: 'Research paper logged successfully',
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
                      'Log Research Paper',
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
                  onPressed: _submitPaper,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Log Paper (Quick Save)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: buildInputDecoration('Paper Title').copyWith(
                    suffixIcon: _isAutofilling
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: VelvetColors.coralPeach,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.auto_awesome, color: VelvetColors.coralPeach),
                            tooltip: 'AI Autofill metadata',
                            onPressed: _autofill,
                          ),
                  ),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter paper title' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _abstractIdController,
                  decoration: buildInputDecoration('Abstract ID (arXiv/SSRN)'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 12),

                // Related Project Link (prominent dropdown)
                projectsAsync.when(
                  data: (projects) {
                    return DropdownButtonFormField<int?>(
                      initialValue: _selectedProjectId,
                      isExpanded: true,
                      menuMaxHeight: 320,
                      borderRadius: BorderRadius.circular(20),
                      decoration: buildInputDecoration('Related Project Link (optional)'),
                      dropdownColor: VelvetColors.dropdownFill(context),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('No Project Link (Standalone)', style: TextStyle(color: VelvetColors.textPrimary(context))),
                        ),
                        ...projects.map((p) => DropdownMenuItem<int?>(
                              value: p.id,
                              child: Text('🔗 Project: ${p.name}', style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold)),
                            )),
                      ],
                      onChanged: (val) => setState(() => _selectedProjectId = val),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _linkController,
                  decoration: buildInputDecoration('Research Paper Link'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _venueController,
                        decoration: buildInputDecoration('Target Venue / Journal'),
                        style: TextStyle(color: VelvetColors.textPrimary(context)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() => _selectedSubmissionDeadline = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: VelvetColors.inputFill(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: VelvetColors.border(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_note_rounded, size: 18, color: VelvetColors.coralPeach),
                            const SizedBox(width: 6),
                            Text(
                              _selectedSubmissionDeadline == null
                                  ? 'Submission Date'
                                  : '${_selectedSubmissionDeadline!.day}/${_selectedSubmissionDeadline!.month}/${_selectedSubmissionDeadline!.year}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6.0,
                  children: _venuePresetChips.map((venue) {
                    final isSelected = _venueController.text.trim() == venue;
                    return ActionChip(
                      label: Text(
                        venue,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white : VelvetColors.textPrimary(context),
                        ),
                      ),
                      backgroundColor: isSelected ? VelvetColors.coralPeach : VelvetColors.chipBg(context),
                      onPressed: () {
                        setState(() {
                          _venueController.text = venue;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _keywordsController,
                  decoration: buildInputDecoration('Research Keywords / Tags (comma-separated)'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: ['Draft', 'In Writing', 'Preliminary Upload', 'Under Review', 'Published', 'Rejected'].contains(_selectedStatus)
                      ? _selectedStatus
                      : 'Draft',
                  decoration: buildInputDecoration('Status'),
                  dropdownColor: VelvetColors.dropdownFill(context),
                  menuMaxHeight: 180,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(20),
                  items: ['Draft', 'In Writing', 'Preliminary Upload', 'Under Review', 'Published', 'Rejected']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _coAuthorsController,
                  decoration: buildInputDecoration('Co-Authors (comma-separated)'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 220),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
