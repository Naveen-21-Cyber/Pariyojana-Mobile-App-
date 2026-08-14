import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';

class WorkspaceTabGuideModal extends ConsumerStatefulWidget {
  final String initialTab;

  const WorkspaceTabGuideModal({
    super.key,
    this.initialTab = 'ideas',
  });

  static void show(BuildContext context, {String initialTab = 'ideas'}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkspaceTabGuideModal(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<WorkspaceTabGuideModal> createState() => _WorkspaceTabGuideModalState();
}

class _WorkspaceTabGuideModalState extends ConsumerState<WorkspaceTabGuideModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeFeatureIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'id': 'ideas',
      'label': 'Idea Vault',
      'icon': Icons.lightbulb_rounded,
      'color': Colors.amber.shade700,
      'features': [
        {
          'title': '1. Instant Wide Typing & Fast Capture',
          'icon': Icons.edit_note_rounded,
          'color': Colors.amber.shade800,
          'desc': 'Type thoughts directly into the streamlined bottom capture bar. Designed for maximum horizontal space with zero distraction.',
          'tip': 'Press Return / Enter on your keyboard to instantly encrypt & commit the idea.',
          'badge': 'SPEED ENGINE',
        },
        {
          'title': '2. AI Auto-Triage & Intelligent Routing ✨',
          'icon': Icons.auto_awesome,
          'color': VelvetColors.periwinkle,
          'desc': 'Tap the Sparkle icon to have on-device & cloud models tag your note, detect urgency, and route it to Project, Research, or Job queues.',
          'tip': 'Long-press the Sparkle icon anytime to view token efficiency and model capabilities.',
          'badge': 'SMART TRIAGE',
        },
        {
          'title': '3. Voice AI Note Capture 🎙️',
          'icon': Icons.mic_rounded,
          'color': VelvetColors.coralPeach,
          'desc': 'Dictate notes on the go. Local speech-to-text processes voice notes securely on your device with zero cloud audio logging.',
          'tip': 'Includes live audio visualizer and pause/resume recording controls.',
          'badge': 'VOICE AUDIO',
        },
        {
          'title': '4. Smart Chime Reminders 🔔',
          'icon': Icons.notifications_active_rounded,
          'color': Colors.teal,
          'desc': 'Schedule reminders with custom chime tones (Singing Bowl, Temple Bell, Harp) and local Android notifications.',
          'tip': 'Quick presets for 1h, 3h, Tomorrow Morning, or custom date/time.',
          'badge': 'ALARM CHIME',
        },
        {
          'title': '5. Encrypted Photo & Snapshot Attachments 📷',
          'icon': Icons.camera_alt_outlined,
          'color': VelvetColors.mint,
          'desc': 'Snap whiteboard brainstorms, textbook diagrams, or UI mockups. Images are stored encrypted in the application sandbox.',
          'tip': 'Tap the camera icon in the capture bar to snap or pick from gallery.',
          'badge': 'ENCRYPTED MEDIA',
        },
        {
          'title': '6. Zero-Knowledge Biometric Vault 🛡️',
          'icon': Icons.security_rounded,
          'color': Colors.indigo,
          'desc': 'Lock confidential intellectual property behind AES-256-GCM hardware encryption accessible only with your fingerprint or PIN.',
          'tip': 'Tap the lock icon in the top header to enter your private vault.',
          'badge': 'HARDWARE LOCK',
        },
      ],
    },
    {
      'id': 'projects',
      'label': 'Projects',
      'icon': Icons.account_tree_rounded,
      'color': VelvetColors.coralPeach,
      'features': [
        {
          'title': '1. 6-Stage Agile Scrum Pipeline',
          'icon': Icons.view_kanban_rounded,
          'color': VelvetColors.coralPeach,
          'desc': 'Progress projects smoothly: Backlog → Sprint Planning → In Progress → Review & QA → Security Audit → Done & Deployed.',
          'tip': 'Switch between Kanban board and List views using the view toggle in the header.',
          'badge': 'AGILE BOARD',
        },
        {
          'title': '2. Modular Tech Stack Provisioning (7 Layers)',
          'icon': Icons.construction_rounded,
          'color': Colors.deepOrange,
          'desc': 'Configure technology combinations: Frontend Desktop/GUI (Tkinter, PyQt, JavaFX, Swing, WinForms), Web, Backend, Database, Auth & AI.',
          'tip': 'Supports student GUI frameworks and full enterprise modular stacks.',
          'badge': 'TECH MATRIX',
        },
        {
          'title': '3. Live AI Compatibility & Architecture Synergy',
          'icon': Icons.hub_rounded,
          'color': VelvetColors.periwinkle,
          'desc': 'Whenever you select a Frontend and Backend, the AI evaluates architecture fit, flags protocol conflicts, and calculates match score.',
          'tip': 'Tap recommended AI chips to add them to your project stack with 1 tap.',
          'badge': 'AI ARCHITECT',
        },
        {
          'title': '4. GitHub Remote Repository Linking',
          'icon': Icons.code_rounded,
          'color': Colors.blueGrey,
          'desc': 'Link your GitHub repo URL and check the box to automatically initialize a remote repository directly on project creation.',
          'tip': 'Supports personal access tokens stored securely in the hardware KeyStore.',
          'badge': 'GITHUB SYNC',
        },
        {
          'title': '5. Milestone Tracking & Priority Deadlines',
          'icon': Icons.flag_rounded,
          'color': Colors.redAccent,
          'desc': 'Set High, Medium, Low, or Critical priorities. Track milestones, target release dates, and sprint checklists.',
          'tip': 'Deadlines automatically highlight in amber/red as target dates approach.',
          'badge': 'DEADLINE CONTROL',
        },
        {
          'title': '6. Encrypted Project Backup & Local Database Export 📦',
          'icon': Icons.archive_rounded,
          'color': Colors.amber.shade800,
          'desc': 'Export full project specifications, task logs, and local SQLite data into encrypted `.velvet` backup archives.',
          'tip': 'Access backups anytime from Settings → Vault Security & Backup.',
          'badge': 'BACKUP ARCHIVE',
        },
      ],
    },
    {
      'id': 'research',
      'label': 'Research',
      'icon': Icons.menu_book_rounded,
      'color': VelvetColors.periwinkle,
      'features': [
        {
          'title': '1. Structured Deep-Dive Markdown Editor',
          'icon': Icons.article_rounded,
          'color': VelvetColors.periwinkle,
          'desc': 'Draft research papers, literature reviews, and architectural RFCs with rich headers, code snippets, LaTeX formulas, and bullet tables.',
          'tip': 'Supports live side-by-side Markdown preview and syntax highlighting.',
          'badge': 'DEEP WRITER',
        },
        {
          'title': '2. Cross-Document Keyword Graph Search',
          'icon': Icons.travel_explore_rounded,
          'color': Colors.cyan.shade700,
          'desc': 'Instantly search across all stored citations, abstracts, and notes with local full-text search indexing.',
          'tip': 'Search matches are highlighted directly in document bodies.',
          'badge': 'FULL TEXT',
        },
        {
          'title': '3. BibTeX Citation Parser & Reference Generator',
          'icon': Icons.format_quote_rounded,
          'color': Colors.teal,
          'desc': 'Paste BibTeX references, DOIs, or arXiv identifiers to automatically generate structured IEEE, APA, and ACM citation blocks.',
          'tip': 'Easily export formatted references with 1 tap.',
          'badge': 'BIBTEX CITE',
        },
        {
          'title': '4. Multi-Layer Tagging & Cross-Linking',
          'icon': Icons.tag_rounded,
          'color': Colors.purple,
          'desc': 'Organize research papers with flexible colored chips and link notes directly to associated Projects or Jobs.',
          'tip': 'Filter research papers by tag directly from the top horizontal chip row.',
          'badge': 'TAXONOMY',
        },
        {
          'title': '5. Document Version History & Diff Snapshots',
          'icon': Icons.history_rounded,
          'color': Colors.blueGrey,
          'desc': 'Review incremental paper edits, revert unwanted modifications, and inspect word counts over time.',
          'tip': 'Snapshots are saved locally upon each save milestone.',
          'badge': 'VERSIONING',
        },
        {
          'title': '6. PDF & Text Export 📄',
          'icon': Icons.picture_as_pdf_rounded,
          'color': Colors.red.shade700,
          'desc': 'Export research write-ups and structured notes directly to formatted PDF or raw markdown for distribution.',
          'tip': 'Exports can be saved to device storage or shared via Android share sheet.',
          'badge': 'PDF EXPORT',
        },
      ],
    },
    {
      'id': 'jobs',
      'label': 'Job Tracker',
      'icon': Icons.work_rounded,
      'color': VelvetColors.mint,
      'features': [
        {
          'title': '1. 5-Stage Job Pipeline & Application Funnel',
          'icon': Icons.view_column_rounded,
          'color': VelvetColors.mint,
          'desc': 'Track opportunities effortlessly across 5 core stages: Saved → Applied → Shortlisted → Interview → Offer (with Rejected filter).',
          'tip': 'Move stages directly from the card dropdown or detailed job sheet.',
          'badge': '5-STAGE FUNNEL',
        },
        {
          'title': '2. Real-World LPA In-Hand Salary & Tax Calculator',
          'icon': Icons.calculate_rounded,
          'color': VelvetColors.coralPeach,
          'desc': 'Accurate Indian Income Tax calculations under Section 115BAC (Standard Deduction ₹75k, ₹7L rebate) + 7 global countries.',
          'tip': 'Tap the calculator icon on any job card to simulate in-hand take-home pay.',
          'badge': 'TAX SIMULATOR',
        },
        {
          'title': '3. ATS Resume Match Matrix & Token Matrix',
          'icon': Icons.analytics_outlined,
          'color': VelvetColors.periwinkle,
          'desc': 'Upload or paste your resume to calculate keyword intersections, missing critical skills, and ATS alignment percentages.',
          'tip': 'Works with any AI key (OpenRouter, OpenAI, Claude, Groq, Gemini) or offline token analysis.',
          'badge': 'ATS MATRIX',
        },
        {
          'title': '4. AI Mock Interview Simulator 🎯',
          'icon': Icons.psychology_rounded,
          'color': Colors.deepOrange,
          'desc': 'Practice tailored technical and behavioral questions generated specifically for the job role, tech stack, and company.',
          'tip': 'Receive instant scoring, strengths, and areas to improve.',
          'badge': 'MOCK INTERVIEW',
        },
        {
          'title': '5. Outreach Channels & Recruiter Log',
          'icon': Icons.connect_without_contact_rounded,
          'color': Colors.cyan.shade700,
          'desc': 'Record recruiter contacts, referral employees, and follow-up dates (LinkedIn, Referral, Direct Email, Naukri).',
          'tip': 'Never lose track of a recruiter message or follow-up deadline.',
          'badge': 'OUTREACH',
        },
        {
          'title': '6. Project Portfolio Linker',
          'icon': Icons.link_rounded,
          'color': Colors.amber.shade800,
          'desc': 'Link your tracked engineering projects directly to job applications to showcase proof-of-work in interviews.',
          'tip': 'Tap linked project chips to navigate straight to the project repository.',
          'badge': 'PORTFOLIO LINK',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    int initialIdx = _tabs.indexWhere((t) => t['id'] == widget.initialTab);
    if (initialIdx == -1) initialIdx = 0;
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIdx);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _activeFeatureIndex = 0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFeatureCardClicked(int index) {
    ref.read(hapticServiceProvider).lightTap();
    setState(() => _activeFeatureIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    final currentTabObj = _tabs[_tabController.index];
    final currentFeatures = currentTabObj['features'] as List<Map<String, dynamic>>;
    final activeFeature = currentFeatures[_activeFeatureIndex.clamp(0, currentFeatures.length - 1)];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: true,
      bottom: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: mediaQuery.size.height - topPadding - 16,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: VelvetColors.surface(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: VelvetColors.coralPeach.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: VelvetColors.border(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: VelvetColors.coralPeach,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PARIYOJANA WORKSPACE GUIDE',
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: VelvetColors.textPrimary(context),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Explore features, workflows & power shortcuts',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: VelvetColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context), size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Tab Bar Navigation Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: VelvetColors.cardSurface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VelvetColors.border(context)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: VelvetColors.coralPeach,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: VelvetColors.textSecondary(context),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                      onTap: (idx) {
                        ref.read(hapticServiceProvider).lightTap();
                        setState(() => _activeFeatureIndex = 0);
                      },
                      tabs: _tabs.map((tab) {
                        return Tab(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tab['icon'] as IconData, size: 16),
                                const SizedBox(width: 6),
                                Text(tab['label'] as String),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Active Feature Spotlight Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VelvetColors.cardSurface(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: (activeFeature['color'] as Color), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: (activeFeature['color'] as Color).withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (activeFeature['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(activeFeature['icon'] as IconData, size: 20, color: activeFeature['color'] as Color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeFeature['title'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: VelvetColors.textPrimary(context),
                                    ),
                                  ),
                                  Text(
                                    '${currentTabObj['label']} • Feature ${_activeFeatureIndex + 1} of ${currentFeatures.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: (activeFeature['color'] as Color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: (activeFeature['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activeFeature['badge'] as String,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: (activeFeature['color'] as Color),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          activeFeature['desc'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: VelvetColors.textSecondary(context),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : const Color(0xFFFFF8F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5A852).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_rounded, size: 14, color: Color(0xFFB45309)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Pro Tip: ${activeFeature['tip']}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF7C4A03),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Click-and-See Feature Grid List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      final features = tab['features'] as List<Map<String, dynamic>>;
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 14,
                          right: 14,
                          top: 4,
                          bottom: bottomPadding + 32,
                        ),
                        itemCount: features.length,
                        itemBuilder: (context, idx) {
                          final feat = features[idx];
                          final isSelected = _activeFeatureIndex == idx;
                          final color = feat['color'] as Color;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Material(
                              color: isSelected ? VelvetColors.cardSurface(context) : (isDark ? VelvetColors.darkCard : const Color(0xFFFFFDF9)),
                              borderRadius: BorderRadius.circular(16),
                              elevation: isSelected ? 2 : 0,
                              child: InkWell(
                                onTap: () => _onFeatureCardClicked(idx),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? color : VelvetColors.border(context),
                                      width: isSelected ? 1.8 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: isSelected ? 0.22 : 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(feat['icon'] as IconData, size: 18, color: color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              feat['title'] as String,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? VelvetColors.textPrimary(context) : VelvetColors.textSecondary(context),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              feat['desc'] as String,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: VelvetColors.textSecondary(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('SELECTED', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white)),
                                        )
                                      else
                                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: VelvetColors.iconColor(context)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
