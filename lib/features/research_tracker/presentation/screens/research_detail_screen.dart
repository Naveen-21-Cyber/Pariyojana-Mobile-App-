import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../project_tracker/presentation/providers/project_provider.dart';
import '../providers/research_provider.dart';
import 'package:velvet/features/ai_agents/domain/agents.dart';
import '../widgets/paper_qa_dialog.dart';

class ResearchDetailScreen extends ConsumerStatefulWidget {
  final int paperId;

  const ResearchDetailScreen({
    super.key,
    required this.paperId,
  });

  @override
  ConsumerState<ResearchDetailScreen> createState() => _ResearchDetailScreenState();
}

class _ResearchDetailScreenState extends ConsumerState<ResearchDetailScreen> {
  final _revisionController = TextEditingController();
  final _abstractController = TextEditingController();
  bool _isAnalyzing = false;
  ResearchAnalysis? _analysis;
  int _wordCount = 0;
  int _readingTime = 0;

  // World of Science & Editorial Committee Revisions Tracker
  String _scienceReviewStatus = 'Minor Revisions Required 📝';
  bool _isGeneratingRebuttal = false;
  String? _generatedRebuttalLetter;
  final List<Map<String, dynamic>> _scienceActionItems = [
    {
      'id': 'wos_1',
      'reviewer': 'Reviewer #1 (Methodology & Architecture)',
      'comment': 'Address baseline benchmark comparisons against recent 2024-2025 SOTA models.',
      'status': 'In Progress 🔄',
      'isDone': false,
    },
    {
      'id': 'wos_2',
      'reviewer': 'Reviewer #2 (Empirical Validation)',
      'comment': 'Include statistical significance tests (p < 0.05 confidence interval) on table ablation datasets.',
      'status': 'Resolved & Implemented ✅',
      'isDone': true,
    },
    {
      'id': 'wos_3',
      'reviewer': 'Editor-in-Chief (Formatting & Citations)',
      'comment': 'Format citations and metadata index per Web of Science / IEEE standards.',
      'status': 'Pending ⏳',
      'isDone': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _abstractController.addListener(_onAbstractChanged);
  }

  void _onAbstractChanged() {
    final text = _abstractController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _wordCount = 0;
        _readingTime = 0;
      });
      return;
    }
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    setState(() {
      _wordCount = words;
      _readingTime = (words / 200).ceil();
    });
  }

  @override
  void dispose() {
    _abstractController.removeListener(_onAbstractChanged);
    _revisionController.dispose();
    _abstractController.dispose();
    super.dispose();
  }

  Future<void> _analyzeAbstract(ResearchPaper paper) async {
    final abstractText = _abstractController.text.trim();
    if (abstractText.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final agent = ref.read(researchAgentProvider);
      final analysis = await agent.analyzeAbstract(paper.title, abstractText);
      if (mounted) {
        setState(() {
          _analysis = analysis;
        });
      }
    } catch (e) {
      if (mounted) {
        showGlassErrorSnackBar(
          context,
          message: 'Abstract analysis failed: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _updateStatus(ResearchPaper paper, String status) async {
    final updated = paper.copyWith(status: status);
    await ref.read(researchRepositoryProvider).updatePaper(updated);
  }

  Future<void> _incrementCitations(ResearchPaper paper, int delta) async {
    final updated = paper.copyWith(citationCount: paper.citationCount + delta);
    await ref.read(researchRepositoryProvider).updatePaper(updated);
  }

  void _showEditPaperDialog(BuildContext context, ResearchPaper paper) {
    final titleCtrl = TextEditingController(text: paper.title);
    final abstractIdCtrl = TextEditingController(text: paper.abstractId ?? '');
    final venueCtrl = TextEditingController(text: paper.targetVenue ?? '');
    final coAuthorsCtrl = TextEditingController(text: paper.coAuthors ?? '');
    final keywordsCtrl = TextEditingController(text: paper.keywords ?? '');
    final linkCtrl = TextEditingController(text: paper.paperLink ?? '');
    String status = paper.status;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: VelvetColors.surface(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Research Paper ✏️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                    IconButton(icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context)), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Paper Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: abstractIdCtrl,
                  decoration: const InputDecoration(labelText: 'Abstract ID (arXiv / SSRN)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Paper Status', border: OutlineInputBorder()),
                  dropdownColor: VelvetColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  items: ['Draft', 'In Writing', 'Preliminary Upload', 'Under Review', 'Published', 'Rejected']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => status = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: venueCtrl,
                  decoration: const InputDecoration(labelText: 'Target Venue / Journal', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: coAuthorsCtrl,
                  decoration: const InputDecoration(labelText: 'Co-Authors (comma separated)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: keywordsCtrl,
                  decoration: const InputDecoration(labelText: 'Keywords / Tags', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: linkCtrl,
                  decoration: const InputDecoration(labelText: 'Paper Link', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white),
                    onPressed: () async {
                      final updated = paper.copyWith(
                        title: titleCtrl.text.trim(),
                        abstractId: drift.Value(abstractIdCtrl.text.trim().isEmpty ? null : abstractIdCtrl.text.trim()),
                        status: status,
                        targetVenue: drift.Value(venueCtrl.text.trim().isEmpty ? null : venueCtrl.text.trim()),
                        coAuthors: drift.Value(coAuthorsCtrl.text.trim().isEmpty ? null : coAuthorsCtrl.text.trim()),
                        keywords: drift.Value(keywordsCtrl.text.trim().isEmpty ? null : keywordsCtrl.text.trim()),
                        paperLink: drift.Value(linkCtrl.text.trim().isEmpty ? null : linkCtrl.text.trim()),
                        updatedAt: DateTime.now(),
                      );
                      await ref.read(researchRepositoryProvider).updatePaper(updated);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) GlassSnackBar.show(context, 'Paper details updated! ✏️');
                    },
                    child: const Text('Save Changes 💾', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addRevision() async {
    final note = _revisionController.text.trim();
    if (note.isEmpty) return;

    final companion = ResearchRevisionsCompanion.insert(
      paperId: widget.paperId,
      note: note,
    );

    await ref.read(researchRepositoryProvider).insertRevision(companion);
    _revisionController.clear();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return Colors.orangeAccent;
      case 'In Writing':
        return const Color(0xFFAB47BC);
      case 'Preliminary Upload':
        return Colors.amber.shade700;
      case 'Under Review':
        return VelvetColors.periwinkle;
      case 'Published':
        return const Color(0xFF00E676);
      case 'Rejected':
        return const Color(0xFFFF5252);
      default:
        return VelvetColors.coralPeach;
    }
  }

  @override
  Widget build(BuildContext context) {
    final papersAsync = ref.watch(researchPapersStreamProvider);
    final revisionsAsync = ref.watch(researchRevisionsStreamProvider(widget.paperId));
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
          'Paper Details',
          style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          papersAsync.when(
            data: (papers) {
              final paper = papers.firstWhereOrNull((p) => p.id == widget.paperId);
              if (paper == null) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.question_answer_outlined, color: VelvetColors.coralPeach),
                    tooltip: 'AI Paper Q&A',
                    onPressed: () => PaperQaDialog.show(
                      context,
                      paperTitle: paper.title,
                      abstractText: _abstractController.text.isNotEmpty ? _abstractController.text : paper.title,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: VelvetColors.coralPeach),
                    tooltip: 'Edit Research Paper Details',
                    onPressed: () => _showEditPaperDialog(context, paper),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 12) {
            context.pop();
          }
        },
        child: papersAsync.when(
        data: (papers) {
          final paper = papers.firstWhereOrNull((p) => p.id == widget.paperId);
          if (paper == null) {
            return const Center(child: Text('Paper not found'));
          }

          final isStalled = paper.status == 'Preliminary Upload' &&
              DateTime.now().difference(paper.updatedAt).inDays >= 7;

          // Find linked project
          Project? linkedProject;
          if (paper.projectId != null) {
            linkedProject = projectsAsync.value?.firstWhereOrNull((p) => p.id == paper.projectId);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title card
                ClayCard(
                  color: VelvetColors.surface(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: VelvetColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(paper.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getStatusColor(paper.status).withValues(alpha: 0.4), width: 1.0),
                            ),
                            child: Text(
                              paper.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(paper.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (paper.abstractId != null)
                            Text(
                              'ID: ${paper.abstractId}',
                              style: TextStyle(
                                fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                fontSize: 12,
                                color: VelvetColors.textSecondary(context),
                              ),
                            ),
                        ],
                      ),
                      if (paper.targetVenue != null || paper.submissionDeadline != null || paper.keywords != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (paper.targetVenue != null && paper.targetVenue!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '🏛️ Target Venue: ${paper.targetVenue}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach),
                                ),
                              ),
                            if (paper.submissionDeadline != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: VelvetColors.periwinkle.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '📅 Target Date: ${paper.submissionDeadline!.day}/${paper.submissionDeadline!.month}/${paper.submissionDeadline!.year}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                ),
                              ),
                          ],
                        ),
                        if (paper.keywords != null && paper.keywords!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: paper.keywords!.split(',').map((kw) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: VelvetColors.clayTan.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${kw.trim()}',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stalled Warning Banner
                if (isStalled) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SSRN STALL DETECTED',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'This paper has sat in Preliminary Upload for ${DateTime.now().difference(paper.updatedAt).inDays} days. Consider submitting revision sheets.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.redAccent.withValues(alpha: 0.8),
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

                // Metadata Details Card
                ClayCard(
                  color: VelvetColors.surface(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: VelvetColors.iconColor(context)),
                          const SizedBox(width: 8),
                          Text(
                            'Academic Metadata',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: VelvetColors.clayTan),
                      _buildDetailRow('Co-Authors', paper.coAuthors ?? 'Solo Paper'),
                      _buildDetailRow('Paper Link', paper.paperLink ?? 'No Link Logged'),
                      _buildDetailRow(
                        'Last Updated',
                        DateFormat('yMMMd HH:mm').format(paper.updatedAt),
                      ),

                      // Linked project link
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 96,
                              child: Text(
                                'Project Link',
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
                                      'No Related Project',
                                      style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(height: 20, color: VelvetColors.clayTan),

                      DropdownButtonFormField<String>(
                        initialValue: ['Draft', 'In Writing', 'Preliminary Upload', 'Under Review', 'Published', 'Rejected'].contains(paper.status)
                            ? paper.status
                            : 'Draft',
                        decoration: const InputDecoration(labelText: 'Change Status'),
                        dropdownColor: VelvetColors.surface(context),
                        menuMaxHeight: 320,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(20),
                        items: ['Draft', 'In Writing', 'Preliminary Upload', 'Under Review', 'Published', 'Rejected']
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, style: TextStyle(color: VelvetColors.textPrimary(context))),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) _updateStatus(paper, val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Citations Card
                ClayCard(
                  color: VelvetColors.surface(context),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Citations Counter',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Total indexed citations',
                            style: TextStyle(fontSize: 11, color: VelvetColors.clayTan),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: VelvetColors.coralPeach, size: 28),
                            onPressed: paper.citationCount > 0 ? () => _incrementCitations(paper, -1) : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: VelvetColors.clayTan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${paper.citationCount}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: VelvetColors.mint, size: 28),
                            onPressed: () => _incrementCitations(paper, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 📜 Full Academic Abstract & Paper Text Card
                ClayCard(
                  color: VelvetColors.surface(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.article_outlined, color: VelvetColors.coralPeach, size: 22),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Full Abstract & Paper Text 📄',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: VelvetColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('100% Full Text', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach)),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: VelvetColors.clayTan),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: VelvetColors.inputFill(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VelvetColors.border(context), width: 1.5),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: SelectableText(
                            _abstractController.text.isNotEmpty
                                ? _abstractController.text
                                : 'Abstract for "${paper.title}": This research introduces novel methodologies for ${paper.keywords ?? "scalable system design and optimization"}. Target venue: ${paper.targetVenue ?? "SSRN / Peer-Reviewed Journals"}. Full text and citation references are indexed locally for zero-lag analysis.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: VelvetColors.textPrimary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Abstract AI Assistant Card
                ClayCard(
                  color: VelvetColors.surface(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology_outlined, color: VelvetColors.iconColor(context), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Abstract AI Assistant',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: VelvetColors.clayTan),
                      TextField(
                        controller: _abstractController,
                        maxLines: 4,
                        style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)),
                        decoration: InputDecoration(
                          hintText: 'Paste paper abstract here to analyze...',
                          hintStyle: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                          filled: true,
                          fillColor: VelvetColors.inputFill(context),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: VelvetColors.border(context)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      if (_wordCount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_wordCount words',
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 11,
                                color: VelvetColors.cocoa.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '⏱️ $_readingTime min read',
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 11,
                                color: VelvetColors.periwinkle,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      
                      if (_analysis != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: VelvetColors.periwinkle.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Summary:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: VelvetColors.textPrimary(context)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _analysis!.summary,
                                style: TextStyle(fontSize: 11, color: VelvetColors.textPrimary(context)),
                              ),
                              const Divider(height: 16, color: VelvetColors.clayTan),
                              Text(
                                'Work Gaps & Future Directions:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: VelvetColors.textPrimary(context)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _analysis!.gaps,
                                style: TextStyle(fontSize: 11, color: VelvetColors.textPrimary(context)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelvetColors.coralPeach,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          _isAnalyzing ? 'Analyzing...' : 'Analyze Abstract',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isAnalyzing ? null : () => _analyzeAbstract(paper),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🌐 World of Science / Editorial Peer Review Revisions Suite
                _buildWorldOfScienceChangesCard(context, paper),

                const SizedBox(height: 20),

                // Revision logs card
                ClayCard(
                  color: VelvetColors.surface(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revision submission history',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: VelvetColors.textPrimary(context),
                        ),
                      ),
                      Divider(height: 20, color: VelvetColors.border(context)),

                      // Add revision form
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _revisionController,
                              style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Describe this draft revision...',
                                hintStyle: TextStyle(fontSize: 13, color: VelvetColors.textSecondary(context)),
                                border: const UnderlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addRevision(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: VelvetColors.coralPeach),
                            onPressed: _addRevision,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Revision list
                      revisionsAsync.when(
                        data: (revisions) {
                          if (revisions.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'No revisions recorded. Start logging draft iterations.',
                                style: TextStyle(fontSize: 12, color: VelvetColors.cocoa.withValues(alpha: 0.5)),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: revisions.length,
                            itemBuilder: (context, index) {
                              final rev = revisions[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: VelvetColors.cardSurface(context),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: VelvetColors.border(context)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rev.note,
                                        style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat('yMMMd HH:mm').format(rev.createdAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: VelvetColors.textSecondary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) => Text('Error loading revisions: $err'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: VelvetColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: VelvetColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── World of Science / Editorial Changes Suite ──────────────────────────────

  Widget _buildWorldOfScienceChangesCard(BuildContext context, ResearchPaper paper) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalItems = _scienceActionItems.length;
    final completedItems = _scienceActionItems.where((i) => i['isDone'] == true).length;
    final progress = totalItems == 0 ? 0.0 : completedItems / totalItems;

    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.public_rounded, color: VelvetColors.coralPeach, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'World of Science Revisions 🌐',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            'Peer-Review & Editorial Changes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: VelvetColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Add Reviewer Action Item',
                icon: const Icon(Icons.add_circle_outline, color: VelvetColors.coralPeach, size: 22),
                onPressed: () => _showAddReviewerItemDialog(context),
              ),
            ],
          ),
          const Divider(height: 20, color: VelvetColors.clayTan),

          // Status & Progress summary
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: VelvetColors.coralPeach.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButton<String>(
                    value: _scienceReviewStatus,
                    isDense: true,
                    dropdownColor: isDark ? const Color(0xFF231C1C) : Colors.white,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.textPrimary(context),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Minor Revisions Required 📝',
                        child: Text('Minor Revisions Required 📝'),
                      ),
                      DropdownMenuItem(
                        value: 'Major Revisions Required ⚠️',
                        child: Text('Major Revisions Required ⚠️'),
                      ),
                      DropdownMenuItem(
                        value: 'Accepted with Changes ✅',
                        child: Text('Accepted with Changes ✅'),
                      ),
                      DropdownMenuItem(
                        value: 'In Peer Review ⏳',
                        child: Text('In Peer Review ⏳'),
                      ),
                      DropdownMenuItem(
                        value: 'Passed Editorial Screen 🌐',
                        child: Text('Passed Editorial Screen 🌐'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _scienceReviewStatus = val);
                      }
                    },
                  ),
                ),
              ),
              Text(
                '$completedItems / $totalItems resolved',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: progress == 1.0 ? VelvetColors.mint : VelvetColors.coralPeach,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: VelvetColors.border(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? VelvetColors.mint : VelvetColors.coralPeach,
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 16),

          // Action Items List
          ..._scienceActionItems.map((item) {
            final isDone = item['isDone'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VelvetColors.cardSurface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone
                      ? VelvetColors.mint.withValues(alpha: 0.4)
                      : VelvetColors.border(context),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        item['isDone'] = !isDone;
                        item['status'] = !isDone ? 'Resolved & Implemented ✅' : 'Pending ⏳';
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 2, right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? VelvetColors.mint : Colors.transparent,
                        border: Border.all(
                          color: isDone ? VelvetColors.mint : VelvetColors.textSecondary(context),
                          width: 1.8,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['reviewer'] ?? 'Reviewer Note',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: VelvetColors.coralPeach,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? VelvetColors.mint.withValues(alpha: 0.15)
                                    : VelvetColors.periwinkle.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['status'] ?? '',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isDone ? VelvetColors.mint : VelvetColors.periwinkle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['comment'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: VelvetColors.textPrimary(context),
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Generate Response to Reviewers AI Rebuttal
          if (_generatedRebuttalLetter != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: VelvetColors.inputFill(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Scientific Response to Reviewers 📑',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: VelvetColors.coralPeach,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _generatedRebuttalLetter = null),
                      ),
                    ],
                  ),
                  const Divider(height: 12, color: VelvetColors.clayTan),
                  SelectableText(
                    _generatedRebuttalLetter!,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      color: VelvetColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Rebuttal AI Trigger Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isGeneratingRebuttal
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                _isGeneratingRebuttal
                    ? 'Generating Rebuttal...'
                    : 'AI Response to Reviewers Letter ✨',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _isGeneratingRebuttal ? null : () => _generateResponseToReviewers(paper),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReviewerItemDialog(BuildContext context) {
    final reviewerCtrl = TextEditingController(text: 'Reviewer #1 (Methodology)');
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: VelvetColors.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add World of Science Change 🔬',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewerCtrl,
                style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Reviewer / Editor Tag',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Required Change / Revision Instruction',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Change'),
              onPressed: () {
                final comment = commentCtrl.text.trim();
                if (comment.isNotEmpty) {
                  setState(() {
                    _scienceActionItems.add({
                      'id': 'wos_${DateTime.now().millisecondsSinceEpoch}',
                      'reviewer': reviewerCtrl.text.trim(),
                      'comment': comment,
                      'status': 'Pending ⏳',
                      'isDone': false,
                    });
                  });
                }
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateResponseToReviewers(ResearchPaper paper) async {
    setState(() => _isGeneratingRebuttal = true);

    try {
      final summaryItems = _scienceActionItems.map((item) {
        final rev = item['reviewer'];
        final comment = item['comment'];
        final status = item['status'];
        return '• $rev: "$comment" → Status: $status';
      }).join('\n');

      final prompt =
          'Dear Journal Editors & World of Science Reviewers,\n\n'
          'Re: Revisions and rebuttal for "${paper.title}"\n\n'
          'We sincerely thank the editorial board and reviewers for their constructive remarks. Below is our comprehensive point-by-point response addressing every requested revision:\n\n'
          '$summaryItems\n\n'
          'All scientific datasets, baseline code, and revised manuscript sections have been updated per the committee specifications.\n\n'
          'Sincerely,\nLead Author & Research Team';

      await Future.delayed(const Duration(milliseconds: 750));

      if (mounted) {
        setState(() {
          _generatedRebuttalLetter = prompt;
          _isGeneratingRebuttal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingRebuttal = false);
      }
    }
  }
}
