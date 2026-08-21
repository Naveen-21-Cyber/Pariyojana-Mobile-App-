import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';
import 'quick_thought_capture_sheet.dart';
import '../features/focus_shield/presentation/focus_shield_overlay.dart';
import 'gita_shloka_dialog.dart';
import 'cyber_command_launcher.dart';

class FeatureItem {
  final String title;
  final String category;
  final String tag;
  final IconData icon;
  final Color color;
  final String summary;
  final String howToUse;
  final String proTip;
  final String actionLabel;
  final void Function(BuildContext context, WidgetRef ref) onAction;

  const FeatureItem({
    required this.title,
    required this.category,
    required this.tag,
    required this.icon,
    required this.color,
    required this.summary,
    required this.howToUse,
    required this.proTip,
    required this.actionLabel,
    required this.onAction,
  });
}

class FeatureExplainerSheet extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const FeatureExplainerSheet({
    super.key,
    this.initialTabIndex = 0,
  });

  static void show(BuildContext context, {int initialTabIndex = 0}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeatureExplainerSheet(initialTabIndex: initialTabIndex),
    );
  }

  @override
  ConsumerState<FeatureExplainerSheet> createState() => _FeatureExplainerSheetState();
}

class _FeatureExplainerSheetState extends ConsumerState<FeatureExplainerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categoryNames = [
    'All Features',
    'Idea Vault',
    'Projects',
    'Research',
    'Job Tracker',
    'Power & AI',
  ];

  late final List<FeatureItem> _allFeatures = [
    // ── 1. Idea Vault ────────────────────────────────────────────────────────
    FeatureItem(
      title: 'Instant Idea Capture (Bottom Bar)',
      category: 'Idea Vault',
      tag: 'FAST CAPTURE',
      icon: Icons.edit_note_rounded,
      color: Colors.amber.shade800,
      summary: 'Never let a great idea vanish. Type raw thoughts or flash insights in 2 seconds right from the bottom bar — everything is automatically encrypted on your phone.',
      howToUse: '1. Open the Idea Vault tab 💡\n2. Type your thought into the bottom bar\n3. Tap Send (or press Enter) to save & encrypt instantly.',
      proTip: 'In a rush? Just press Enter on your keyboard — your thought is encrypted in under 5 milliseconds without lifting a finger.',
      actionLabel: 'Try Idea Capture 💡',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/ideas');
      },
    ),
    FeatureItem(
      title: 'AI Smart Triage & Categorizer ✨',
      category: 'Idea Vault',
      tag: 'AI ASSIST',
      icon: Icons.auto_awesome,
      color: VelvetColors.periwinkle,
      summary: 'Not sure where an idea belongs? Tap the Sparkle button. AI reads your note, figures out if it is a Project, Research topic, or Job task, and tags it automatically.',
      howToUse: '1. Type any rough thought in the Vault\n2. Tap the Sparkle ✨ icon on the capture bar\n3. Watch AI assign the right category, priority, and tags for you.',
      proTip: 'Works completely offline or with your custom AI keys for lightning-fast zero-latency sorting.',
      actionLabel: 'Try AI Smart Triage ✨',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/ideas');
      },
    ),
    FeatureItem(
      title: 'Hands-Free Voice AI Notes 🎙️',
      category: 'Idea Vault',
      tag: 'VOICE RECORDER',
      icon: Icons.mic_rounded,
      color: VelvetColors.coralPeach,
      summary: 'Walking, driving, or cooking? Speak your mind out loud. Real-time speech recognition turns your voice into clean, structured written notes with zero typing.',
      howToUse: '1. Tap the Microphone 🎙️ button in Idea Vault\n2. Speak naturally — watch live waveform animations\n3. Tap Done to save your voice note to your encrypted vault.',
      proTip: 'You can pause and resume recording whenever you need a moment to collect your thoughts.',
      actionLabel: 'Record a Voice Note 🎙️',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/ideas');
      },
    ),
    FeatureItem(
      title: 'Encrypted Photo & Diagram Notes 📷',
      category: 'Idea Vault',
      tag: 'PHOTO VAULT',
      icon: Icons.camera_alt_outlined,
      color: VelvetColors.mint,
      summary: 'Snapped a photo of a whiteboard, book page, or handwritten diagram? Attach photos directly to your notes. Photos stay safely inside the app and never leak to your public phone gallery.',
      howToUse: '1. Tap the Camera 📷 icon in the capture bar\n2. Snap a photo or choose an existing picture\n3. Add notes and save with AES-256 encryption.',
      proTip: 'Perfect for keeping confidential sketches, contracts, and design mockups completely private.',
      actionLabel: 'Attach a Photo Note 📷',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/ideas');
      },
    ),
    FeatureItem(
      title: 'Gentle Chime Reminders & Alarms 🔔',
      category: 'Idea Vault',
      tag: 'REMINDERS',
      icon: Icons.notifications_active_rounded,
      color: Colors.teal,
      summary: 'Need a nudge to review an idea later? Schedule reminders with soothing acoustic tones (Tibetan Singing Bowl, Temple Bell, Harp) instead of jarring harsh alarm buzzers.',
      howToUse: '1. Tap the Bell 🔔 icon on any idea card\n2. Pick quick presets (In 1 Hour, Tomorrow Morning) or pick a custom date\n3. Get a peaceful, high-priority reminder.',
      proTip: 'Your reminders trigger reliably on time even when your phone is locked or on do-not-disturb mode.',
      actionLabel: 'Set a Reminder 🔔',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/ideas');
      },
    ),
    FeatureItem(
      title: 'Biometric Fingerprint Vault 🔒',
      category: 'Idea Vault',
      tag: 'HARDWARE LOCK',
      icon: Icons.fingerprint_rounded,
      color: Colors.indigo,
      summary: 'Have private thoughts, business secrets, or passwords? Lock individual ideas behind your phone\'s hardware fingerprint scanner so only you can unlock them.',
      howToUse: '1. Tap the Lock 🔒 icon on any idea card\n2. It moves into the secure Biometric Vault\n3. Touch your fingerprint sensor to view it anytime.',
      proTip: 'Backed directly by Android\'s hardware security chip (TEE Keystore) — even if someone steals your phone, they cannot read your locked notes.',
      actionLabel: 'Open Fingerprint Vault 🔒',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/biometric_vault');
      },
    ),

    // ── 2. Projects ──────────────────────────────────────────────────────────
    FeatureItem(
      title: 'Visual 6-Stage Project Board (Kanban) 📊',
      category: 'Projects',
      tag: 'KANBAN BOARD',
      icon: Icons.view_kanban_rounded,
      color: VelvetColors.coralPeach,
      summary: 'Never wonder what to work on next. Move your projects smoothly across 6 clear stages: Backlog → Sprint → In Progress → Review/QA → Security Audit → Done & Shipped.',
      howToUse: '1. Open the Projects tab 📁\n2. Toggle between the Kanban columns and List view\n3. Tap a project\'s stage badge to advance it to the next step.',
      proTip: 'Tap the circular pie chart in the top deck to see an instant summary of your active vs completed sprints.',
      actionLabel: 'Open Project Board 📁',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/projects');
      },
    ),
    FeatureItem(
      title: '7-Layer Tech Stack Picker 🛠️',
      category: 'Projects',
      tag: 'TECH PICKER',
      icon: Icons.construction_rounded,
      color: Colors.deepOrange,
      summary: 'Building a new app? Choose your dream tech stack from 7 curated layers: Desktop GUI (Tkinter, PyQt, JavaFX), Web, Backend, Database, Auth, AI & Cloud with zero guesswork.',
      howToUse: '1. Tap "+ New Project" in the Projects tab\n2. Tap through the 7 tech layers to pick your tools\n3. Save to get a tailor-made project blueprint.',
      proTip: 'Great for both simple Python scripts and full-blown production systems — helps you stay organized before writing a single line of code.',
      actionLabel: 'Pick a Tech Stack 🛠️',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/projects');
      },
    ),
    FeatureItem(
      title: 'Architecture Compatibility AI Score 🧠',
      category: 'Projects',
      tag: 'AI ADVISOR',
      icon: Icons.hub_rounded,
      color: VelvetColors.periwinkle,
      summary: 'Wondering if React works well with FastAPI or PostgreSQL? Our built-in AI evaluates your chosen stack, gives you a synergy score (e.g. 96%), and warns you about potential pitfalls.',
      howToUse: '1. Choose your frontend, backend, and database in Project Creator\n2. Look at the live Compatibility Score indicator\n3. Read the AI\'s recommendations to fine-tune your stack.',
      proTip: 'Aim for an 85%+ score to guarantee smooth library support and easy deployment down the road.',
      actionLabel: 'Check Stack Score 🧠',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/projects');
      },
    ),
    FeatureItem(
      title: '1-Tap GitHub Repository Creator & Sync 🐙',
      category: 'Projects',
      tag: 'GITHUB SYNC',
      icon: Icons.code_rounded,
      color: Colors.blueGrey,
      summary: 'Create a remote private GitHub repository for your project and copy its clone URL to your clipboard in a single tap without opening your browser.',
      howToUse: '1. Add your GitHub token once in Settings ⚙️\n2. Tap the GitHub icon on any project card\n3. Your repo is created on GitHub with a README and clone command ready!',
      proTip: 'You can also import all your existing public & private GitHub repositories into Pariyojana with 1 tap.',
      actionLabel: 'Connect GitHub 🐙',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.push('/settings');
      },
    ),
    FeatureItem(
      title: 'Target Deadlines & Urgency Radars 🏁',
      category: 'Projects',
      tag: 'DEADLINE TRACKER',
      icon: Icons.flag_rounded,
      color: Colors.redAccent,
      summary: 'Set target completion dates and urgency priority levels (Critical, High, Medium, Low). The app visually highlights projects nearing their deadlines so you never miss a launch.',
      howToUse: '1. Pick a deadline date when creating or editing a project\n2. Watch the card display a dynamic remaining-day countdown\n3. Filter by urgency to tackle what matters most first.',
      proTip: 'Projects due in the next 3 days automatically receive a glowing orange beacon to keep you focused.',
      actionLabel: 'View Deadlines 🏁',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/projects');
      },
    ),

    // ── 3. Research ──────────────────────────────────────────────────────────
    FeatureItem(
      title: 'Distraction-Free Research Writer 📝',
      category: 'Research',
      tag: 'WRITER VAULT',
      icon: Icons.article_rounded,
      color: VelvetColors.periwinkle,
      summary: 'Write research papers, study notes, technical RFCs, or book summaries with clean Markdown formatting, mathematical formulas, and beautiful code blocks.',
      howToUse: '1. Open the Research tab 📚\n2. Tap "+ New Paper"\n3. Write your thoughts and tap Preview to see the formatted document.',
      proTip: 'Supports math formulas (E=mc²) and code syntax highlighting in Python, Dart, JavaScript, Rust, and SQL.',
      actionLabel: 'Start Writing Notes 📝',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/research');
      },
    ),
    FeatureItem(
      title: '1-Tap Citation & Reference Formatter 📚',
      category: 'Research',
      tag: 'BIBTEX & DOI',
      icon: Icons.format_quote_rounded,
      color: Colors.teal,
      summary: 'Tired of manually typing citations? Paste any DOI, BibTeX snippet, or paper link — Pariyojana instantly formats it into standard IEEE, APA, or ACM bibliography format.',
      howToUse: '1. Inside any research document, tap "Citations"\n2. Paste a BibTeX string or DOI URL\n3. Tap Format to generate a publication-ready citation.',
      proTip: 'You can export all your citations together at the end of your document in 1 tap.',
      actionLabel: 'Format a Citation 📚',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/research');
      },
    ),
    FeatureItem(
      title: 'Instant Cross-Document Deep Search 🔍',
      category: 'Research',
      tag: 'FAST SEARCH',
      icon: Icons.travel_explore_rounded,
      color: Colors.cyan.shade700,
      summary: 'Remember a specific formula, algorithm, or note from months ago? Search any keyword across all your research files with instantaneous zero-lag highlighting.',
      howToUse: '1. Tap the search bar in the Research tab\n2. Type any term or snippet\n3. Matched articles appear instantly with exact paragraph previews.',
      proTip: 'Powered by local SQLite indexes — works 100% offline at 0ms latency with zero internet required.',
      actionLabel: 'Search Research Vault 🔍',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/research');
      },
    ),
    FeatureItem(
      title: 'One-Click PDF Document Export 📄',
      category: 'Research',
      tag: 'PDF EXPORT',
      icon: Icons.picture_as_pdf_rounded,
      color: Colors.red.shade700,
      summary: 'Turn your research notes and papers into gorgeous, publication-ready PDF documents formatted with headers, clean typography, and page numbers.',
      howToUse: '1. Open any research document\n2. Tap the Export / Share 📄 icon in the top bar\n3. Choose "Export as PDF" and share or print immediately.',
      proTip: 'PDFs automatically include professional cover headers and clean font layouts suitable for submitting to mentors or colleagues.',
      actionLabel: 'Export to PDF 📄',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/research');
      },
    ),

    // ── 4. Job Tracker ───────────────────────────────────────────────────────
    FeatureItem(
      title: '5-Stage Career Application Pipeline 💼',
      category: 'Job Tracker',
      tag: 'CAREER TRACKER',
      icon: Icons.view_column_rounded,
      color: VelvetColors.mint,
      summary: 'Take the chaos out of your job search. Track every application from initial Bookmark to Applied, Shortlisted, Interview rounds, and Final Offer.',
      howToUse: '1. Open the Jobs tab 💼\n2. Tap "+ Add Job"\n3. Advance cards as you hear back from recruiters.',
      proTip: 'Tap the stage filter pills at the top to instantly view upcoming interviews or pending offers.',
      actionLabel: 'Open Job Tracker 💼',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/jobs');
      },
    ),
    FeatureItem(
      title: 'In-Hand Salary & Tax Take-Home Calculator 💰',
      category: 'Job Tracker',
      tag: 'IN-HAND CASH',
      icon: Icons.calculate_rounded,
      color: VelvetColors.coralPeach,
      summary: 'Don\'t be fooled by inflated CTC numbers! Enter your LPA or salary — get your exact monthly bank deposit cash, PF deductions, and income tax breakdown (New & Old Indian Tax Regimes + 7 Global Countries).',
      howToUse: '1. Tap the Calculator 🧮 icon on any job card\n2. Enter your annual salary (LPA)\n3. Instantly see your real monthly in-hand cash and exact tax deductions.',
      proTip: 'Use this to compare two competing job offers side-by-side to see which one actually puts more cash in your bank account every month.',
      actionLabel: 'Calculate In-Hand Cash 💰',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/jobs');
      },
    ),
    FeatureItem(
      title: 'ATS Resume Keyword Scanner & Matcher 📊',
      category: 'Job Tracker',
      tag: 'BEAT THE ATS',
      icon: Icons.analytics_outlined,
      color: VelvetColors.periwinkle,
      summary: 'Will your resume pass automated company filters? Compare your resume against the job description to find missing keywords and boost your interview call rate.',
      howToUse: '1. Open any job card and tap "ATS Match"\n2. Paste your resume text or upload\n3. Review your match percentage and add the highlighted missing keywords.',
      proTip: 'Adding just 3–4 missing technical keywords from the job description can boost your ATS match score above the 80% interview threshold.',
      actionLabel: 'Scan Resume Match 📊',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/jobs');
      },
    ),
    FeatureItem(
      title: 'AI Mock Interview Simulator 🎯',
      category: 'Job Tracker',
      tag: 'INTERVIEW COACH',
      icon: Icons.psychology_rounded,
      color: Colors.deepOrange,
      summary: 'Practice real technical, coding, and behavioral interview questions customized specifically for the role and company you are applying to.',
      howToUse: '1. Open any job card\n2. Tap "Mock Interview 🎯"\n3. Answer practice questions and receive constructive AI feedback on your answers.',
      proTip: 'Practice behavioral questions using the STAR framework (Situation, Task, Action, Result) for the highest interview ratings.',
      actionLabel: 'Start Practice Interview 🎯',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/jobs');
      },
    ),
    FeatureItem(
      title: 'Recruiter Contact CRM & Follow-Up Reminders 📬',
      category: 'Job Tracker',
      tag: 'OUTREACH CRM',
      icon: Icons.connect_without_contact_rounded,
      color: Colors.cyan.shade700,
      summary: 'Never forget to follow up with a recruiter or LinkedIn referral. Log contacts, messages sent, and set automatic reminders for when to check back in.',
      howToUse: '1. Log recruiter name & channel (LinkedIn/Email) in job details\n2. Pick a follow-up reminder date (e.g. 3 days)\n3. Receive a gentle alert when it is time to follow up.',
      proTip: 'Polite follow-ups 3–5 days after an application or interview increase recruiter response rates by over 40%.',
      actionLabel: 'Log Recruiter Contact 📬',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.go('/jobs');
      },
    ),

    // ── 5. Power & AI ────────────────────────────────────────────────────────
    FeatureItem(
      title: 'Mitnick AI Workspace Co-Pilot 🧠⚡',
      category: 'Power & AI',
      tag: 'AI CO-PILOT',
      icon: Icons.hub_rounded,
      color: VelvetColors.coralPeach,
      summary: 'Your intelligent 24/7 technical partner. Ask Mitnick to brainstorm system architectures, summarize long notes, draft research sections, or polish resume bullets.',
      howToUse: '1. Tap the Mitnick AI icon in the top header bar or cockpit\n2. Ask any question or give an instruction\n3. Mitnick analyzes your workspace and delivers actionable answers.',
      proTip: 'Supports Bring-Your-Own-Key (BYOK) for OpenRouter (free models!), Claude, ChatGPT, Gemini, and Groq.',
      actionLabel: 'Chat with Mitnick AI ⚡',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.push('/mitnick');
      },
    ),
    FeatureItem(
      title: 'Deep Work Focus Shield & Vadya Music 🛡️🎵',
      category: 'Power & AI',
      tag: 'FLOW STATE',
      icon: Icons.shield_outlined,
      color: VelvetColors.periwinkle,
      summary: 'Lock out distractions and enter deep flow state with an uncluttered Pomodoro sprint timer and relaxing instrumental background music.',
      howToUse: '1. Tap FAB (+) → Focus Shield 🛡️\n2. Choose sprint length (e.g. 25 minutes)\n3. Enter full-screen deep work mode with optional soothing ambient sound.',
      proTip: 'Pairing 25-minute deep focus sprints with 5-minute breathers prevents burnout and doubles daily productivity.',
      actionLabel: 'Launch Focus Shield 🛡️',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        FocusShieldLauncher.show(ctx);
      },
    ),
    FeatureItem(
      title: '1-Tap Quick Thought Capture ⚡',
      category: 'Power & AI',
      tag: 'QUICK CAPTURE',
      icon: Icons.flash_on_rounded,
      color: Colors.amber.shade800,
      summary: 'Reading an article or working and had a sudden spark? Capture thoughts in 2 seconds without switching screens or losing your train of thought.',
      howToUse: '1. Tap the Floating (+) Button → Quick Thought ⚡\n2. Jot your thought and tap a tag (Project / Study / Idea)\n3. Saves immediately to your encrypted vault.',
      proTip: 'Accessible from anywhere in the app so you never lose context while researching.',
      actionLabel: 'Open Quick Thought ⚡',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        QuickThoughtCaptureSheet.show(ctx);
      },
    ),
    FeatureItem(
      title: 'Bhagavad Gita Wisdom & Daily Focus 🕉️',
      category: 'Power & AI',
      tag: 'MIND RESET',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFD4AF37),
      summary: 'Timeless Sanskrit wisdom and practical philosophical reflections delivered on app launch to calm your mind, dissolve anxiety, and focus on excellence in action.',
      howToUse: '1. App displays a inspiring shloka on startup with translation\n2. Read the practical real-life reflection\n3. Re-open anytime from the Wisdom section.',
      proTip: 'Based on the timeless teaching "Yoga is excellence in action" (BG 2.50) — keeping your mind steady and purposeful.',
      actionLabel: 'Read Today\'s Wisdom 🕉️',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        GitaStartupDialog.showManual(ctx);
      },
    ),
    FeatureItem(
      title: 'Cyber Command Terminal Guard 💻',
      category: 'Power & AI',
      tag: 'COMMAND CENTER',
      icon: Icons.terminal_rounded,
      color: Colors.greenAccent.shade700,
      summary: 'Your master shortcut launcher. Quickly search everything, jump between screens, check database stats, and trigger actions with zero clicking around.',
      howToUse: '1. Tap the Dynamic Island header or open Terminal from Settings\n2. Type what you want to do (e.g. `salary`, `kanban`, `notes`)\n3. Tap any command to jump directly there in 0 seconds.',
      proTip: 'Tap the Dynamic Island pill at the top of your screen anytime for 1-tap outside access to the Terminal!',
      actionLabel: 'Open Command Terminal 💻',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        CyberCommandLauncher.show(ctx);
      },
    ),
    FeatureItem(
      title: '100% Offline Sovereign Privacy Vault 🔒',
      category: 'Power & AI',
      tag: 'ZERO TRACKING',
      icon: Icons.security_rounded,
      color: VelvetColors.mint,
      summary: 'Zero advertisements, zero analytics tracking, zero corporate cloud servers. All your ideas, projects, notes, and jobs live 100% encrypted on your physical phone.',
      howToUse: '1. Open Settings ⚙️ → Privacy & Security Architecture\n2. View your SQLCipher AES-256 encryption status\n3. Export or backup your data on your own terms.',
      proTip: 'Your phone is your sovereign fortress — no company or server can ever view your personal intelligence.',
      actionLabel: 'View Privacy Architecture 🛡️',
      onAction: (ctx, ref) {
        Navigator.pop(ctx);
        ctx.push('/settings');
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    int initialIdx = widget.initialTabIndex.clamp(0, _categoryNames.length - 1);
    _tabController = TabController(
      length: _categoryNames.length,
      vsync: this,
      initialIndex: initialIdx,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FeatureItem> _getFilteredFeatures() {
    final currentCat = _categoryNames[_tabController.index];
    return _allFeatures.where((f) {
      final matchesCategory = currentCat == 'All Features' || f.category == currentCat;
      if (_searchQuery.isEmpty) return matchesCategory;

      final query = _searchQuery.toLowerCase();
      final matchesQuery = f.title.toLowerCase().contains(query) ||
          f.summary.toLowerCase().contains(query) ||
          f.tag.toLowerCase().contains(query) ||
          f.howToUse.toLowerCase().contains(query) ||
          f.proTip.toLowerCase().contains(query) ||
          f.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredFeatures = _getFilteredFeatures();
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.92,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBF7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 48,
              height: 4.5,
              decoration: BoxDecoration(
                color: VelvetColors.border(context),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelvetColors.coralPeach.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: VelvetColors.coralPeach, width: 1.5),
                  ),
                  child: const Icon(Icons.explore_rounded, color: VelvetColors.coralPeach, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pariyojana Feature Compass 🧭',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: VelvetColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Tap any card to see step-by-step guidance',
                        style: TextStyle(
                          fontSize: 11,
                          color: VelvetColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Onboarding Banner (shows until search active) ──────────────────
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [VelvetColors.coralPeach.withValues(alpha: 0.1), const Color(0xFFFFF0EC)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 11.5, color: VelvetColors.textPrimary(context), height: 1.4),
                          children: const [
                            TextSpan(text: 'New here? ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'Pick a '),
                            TextSpan(text: 'tab below', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFF7043))),
                            TextSpan(text: ' or search. Tap a card → '),
                            TextSpan(text: 'see exact steps', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6C63FF))),
                            TextSpan(text: ' & jump straight there. ⚡'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),

          // ── Search Field ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: VelvetColors.cardSurface(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.35), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 19, color: VelvetColors.coralPeach),
                  const SizedBox(width: 9),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        fontSize: 13,
                        color: VelvetColors.textPrimary(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search features (e.g. salary, voice, git, ats)...',
                        hintStyle: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 14, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Quick Goal Shortcut Chips (1-Tap Filters) ─────────────────────
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildGoalChip('🎙️ Voice Note', 'voice'),
                _buildGoalChip('📊 Kanban Board', 'kanban'),
                _buildGoalChip('🐙 GitHub Sync', 'github'),
                _buildGoalChip('💼 ATS Resume', 'ats'),
                _buildGoalChip('💰 Salary Converter', 'salary'),
                _buildGoalChip('💻 Cyber Terminal', 'terminal'),
                _buildGoalChip('🕉️ Gita Timer', 'gita'),
                _buildGoalChip('🔒 Hardware Lock', 'lock'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Category Tabs ───────────────────────────────────────────────────
          SizedBox(
            height: 38,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: VelvetColors.coralPeach,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: VelvetColors.coralPeach.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: VelvetColors.textSecondary(context),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11.5),
              dividerColor: Colors.transparent,
              tabs: _categoryNames.map((name) => Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(name),
                ),
              )).toList(),
              onTap: (_) => setState(() {}),
            ),
          ),

          // ── Feature count badge ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: VelvetColors.coralPeach.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${filteredFeatures.length} feature${filteredFeatures.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: VelvetColors.coralPeach,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _searchQuery.isNotEmpty ? 'for "$_searchQuery"' : 'in this category',
                    style: TextStyle(fontSize: 10.5, color: VelvetColors.textSecondary(context)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Features List ───────────────────────────────────────────────────
          Expanded(
            child: filteredFeatures.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text(
                          'No features match "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: VelvetColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try: salary, voice, git, shloka, ats, lock',
                          style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredFeatures.length,
                    itemBuilder: (ctx, index) {
                      final item = filteredFeatures[index];
                      return _buildFeatureCard(ctx, item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Track expanded card
  int? _expandedIndex;

  Widget _buildFeatureCard(BuildContext context, FeatureItem item, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpanded = _expandedIndex == index;

    // Complexity from howToUse steps count
    final stepCount = '\n'.allMatches(item.howToUse).length + 1;
    final String difficulty = stepCount <= 2 ? 'Quick' : stepCount <= 3 ? 'Easy' : 'Guided';
    final Color diffColor = stepCount <= 2
        ? Colors.green.shade600
        : stepCount <= 3
            ? Colors.orange.shade700
            : VelvetColors.periwinkle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isExpanded
                ? (isDark
                    ? item.color.withValues(alpha: 0.08)
                    : item.color.withValues(alpha: 0.05))
                : VelvetColors.surface(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExpanded
                  ? item.color.withValues(alpha: 0.5)
                  : VelvetColors.border(context),
              width: isExpanded ? 1.5 : 1,
            ),
            boxShadow: isExpanded
                ? [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Collapsed header row: always visible ───────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: item.color.withValues(alpha: 0.35), width: 1.2),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 11),

                    // Title + category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: isExpanded ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: VelvetColors.coralPeach,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Difficulty badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: diffColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  difficulty,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: diffColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Tag + expand chevron
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: item.color.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            item.tag,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: item.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: VelvetColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Quick-glance summary (always visible, 2 lines max) ──────
                const SizedBox(height: 8),
                Text(
                  item.summary,
                  maxLines: isExpanded ? 10 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: VelvetColors.textSecondary(context),
                  ),
                ),

                // ── Expanded section ────────────────────────────────────────
                if (isExpanded) ...[
                  const SizedBox(height: 12),

                  // HOW TO USE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : VelvetColors.cardSurface(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VelvetColors.border(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.format_list_numbered_rounded,
                                size: 14, color: item.color),
                            const SizedBox(width: 5),
                            Text(
                              'HOW TO USE (3 QUICK STEPS)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                                color: item.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...item.howToUse.split('\n').asMap().entries.map((entry) {
                          final stepIdx = entry.key + 1;
                          final stepText = entry.value.replaceFirst(RegExp(r'^\d+\.\s*'), '');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: item.color.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: item.color.withValues(alpha: 0.5), width: 1),
                                  ),
                                  child: Text(
                                    '$stepIdx',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: item.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    stepText,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.4,
                                      color: VelvetColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PRO TIP
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: isDark ? 0.1 : 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PRO TIP: ${item.proTip}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFFDE68A) : Colors.amber.shade900,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(hapticServiceProvider).lightTap();
                        item.onAction(context, ref);
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        '🚀 ${item.actionLabel}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.color.withValues(alpha: isDark ? 0.3 : 0.18),
                        foregroundColor: isDark ? Colors.white : item.color,
                        elevation: 0,
                        side: BorderSide(color: item.color.withValues(alpha: 0.6), width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalChip(String label, String queryKeyword) {
    final isSelected = _searchQuery.toLowerCase() == queryKeyword.toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          ref.read(hapticServiceProvider).lightTap();
          setState(() {
            if (isSelected) {
              _searchQuery = '';
              _searchController.clear();
            } else {
              _searchQuery = queryKeyword;
              _searchController.text = queryKeyword;
              _expandedIndex = 0; // Auto expand matching result for instant answer
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? VelvetColors.coralPeach
                : VelvetColors.cardSurface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? VelvetColors.coralPeach
                  : VelvetColors.border(context),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : VelvetColors.textPrimary(context),
            ),
          ),
        ),
      ),
    );
  }
}


