import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/database/database.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/network_disclaimer_banner.dart';
import '../../../idea_vault/presentation/providers/idea_provider.dart';
import '../../data/repositories/hn_repository.dart';

final hnSecurityFeedProvider = FutureProvider<List<HnStory>>((ref) async {
  return ref.read(hnRepositoryProvider).fetchSecurityFeed();
});

final hnFeedProvider = FutureProvider.family<List<HnStory>, String>((ref, type) async {
  final allStories = await ref.read(hnRepositoryProvider).fetchFeed(type);
  try {
    final securityStories = await ref.watch(hnSecurityFeedProvider.future);
    final securityUrls = securityStories.map((s) => (s.url ?? s.title).toLowerCase()).toSet();
    final securityTitles = securityStories.map((s) => s.title.toLowerCase()).toSet();

    return allStories.where((s) {
      final keyUrl = (s.url ?? s.title).toLowerCase();
      final keyTitle = s.title.toLowerCase();
      return !securityUrls.contains(keyUrl) && !securityTitles.contains(keyTitle);
    }).toList();
  } catch (_) {
    return allStories;
  }
});

final hnGamingFeedProvider = FutureProvider<List<HnStory>>((ref) async {
  final gamingStories = await ref.read(hnRepositoryProvider).fetchGamingFeed();
  try {
    final securityStories = await ref.watch(hnSecurityFeedProvider.future);
    final securityUrls = securityStories.map((s) => (s.url ?? s.title).toLowerCase()).toSet();
    final securityTitles = securityStories.map((s) => s.title.toLowerCase()).toSet();

    return gamingStories.where((s) {
      final keyUrl = (s.url ?? s.title).toLowerCase();
      final keyTitle = s.title.toLowerCase();
      return !securityUrls.contains(keyUrl) && !securityTitles.contains(keyTitle);
    }).toList();
  } catch (_) {
    return gamingStories;
  }
});

class HnFeedScreen extends ConsumerStatefulWidget {
  const HnFeedScreen({super.key});

  @override
  ConsumerState<HnFeedScreen> createState() => _HnFeedScreenState();
}

class _HnFeedScreenState extends ConsumerState<HnFeedScreen> {
  String _selectedTab = 'security';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _autoRefreshTimer;

  final List<Map<String, String>> _tabs = [
    {'id': 'security', 'label': '🛡️ Cyber Security'},
    {'id': 'all', 'label': '🌐 All Tech News'},
    {'id': 'gaming', 'label': '🎮 Gaming Tech & Esport Radar'},
  ];

  @override
  void initState() {
    super.initState();
    // Silent 30-minute background cache refresh
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      ref.invalidate(hnFeedProvider('top'));
      ref.invalidate(hnSecurityFeedProvider);
      ref.invalidate(hnGamingFeedProvider);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveToIdeaVault(HnStory story) async {
    final ideaRepo = ref.read(ideaRepositoryProvider);
    final text = '[HN] ${story.title}${story.url != null ? ' - ${story.url}' : ''}';

    await ideaRepo.insertIdea(
      IdeasCompanion.insert(
        content: text,
        category: 'Research',
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Saved "${story.title}" to Idea Vault!', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          backgroundColor: VelvetColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _copyToClipboard(String? url) {
    if (url == null) return;
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard! 📋', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: VelvetColors.coralPeach,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchArticleUrl(String? rawUrl, int id) async {
    final target = (rawUrl != null && rawUrl.isNotEmpty)
        ? rawUrl
        : 'https://news.ycombinator.com/item?id=$id';
    final uri = Uri.parse(target);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $target'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = _selectedTab == 'security'
        ? ref.watch(hnSecurityFeedProvider)
        : (_selectedTab == 'gaming'
            ? ref.watch(hnGamingFeedProvider)
            : ref.watch(hnFeedProvider('top')));

    return Scaffold(
      backgroundColor: VelvetColors.surface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: VelvetColors.iconColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tech News & Threat Radar',
          style: TextStyle(
            color: VelvetColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 📊 Tech News Analytics Dashboard Header ───────────────────
              storiesAsync.when(
                data: (stories) => _buildAnalyticsDashboard(stories),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // ── Search & Filter Bar ──────────────────────────────────────
              TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 12.5, color: VelvetColors.textPrimary(context), fontWeight: FontWeight.w600),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search technology, CVEs, tags or domains...',
                  hintStyle: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: VelvetColors.coralPeach),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 16, color: VelvetColors.iconColor(context)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: VelvetColors.inputFill(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: VelvetColors.border(context), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2D4C3), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── 2 Main Menu Tabs: Cyber Security & All Tech News ─────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tabs.map((t) {
                    final isSelected = _selectedTab == t['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = t['id']!),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? VelvetColors.coralPeach : VelvetColors.cardSurface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? VelvetColors.coralPeach : VelvetColors.border(context),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: VelvetColors.coralPeach.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          t['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : VelvetColors.textPrimary(context),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // ── News List ────────────────────────────────────────────────
              Expanded(
                child: storiesAsync.when(
                  loading: () => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: VelvetColors.coralPeach),
                          const SizedBox(height: 12),
                          Text('Fetching latest live tech advisories...', style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const NetworkLatencyDisclaimerBanner(),
                        ],
                      ),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: ClayCard(
                      color: VelvetColors.cardSurface(context),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_outlined, size: 48, color: VelvetColors.iconColor(context)),
                          const SizedBox(height: 16),
                          Text('Failed to load feed', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                          const SizedBox(height: 8),
                          Text(err.toString(), style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VelvetColors.coralPeach,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              ref.invalidate(hnFeedProvider('top'));
                              ref.invalidate(hnSecurityFeedProvider);
                            },
                            child: const Text('Retry Feed'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (stories) {
                    var filtered = stories;
                    if (_searchQuery.isNotEmpty) {
                      filtered = filtered.where((s) {
                        return s.title.toLowerCase().contains(_searchQuery) ||
                            s.domain.toLowerCase().contains(_searchQuery) ||
                            s.author.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No stories found matching "$_searchQuery".',
                          style: const TextStyle(color: VelvetColors.cocoa, fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: VelvetColors.coralPeach,
                      onRefresh: () async {
                        ref.invalidate(hnFeedProvider('top'));
                        ref.invalidate(hnSecurityFeedProvider);
                        ref.invalidate(hnGamingFeedProvider);
                        await ref.read(hnRepositoryProvider).fetchSecurityFeed(forceRefresh: true);
                        await ref.read(hnRepositoryProvider).fetchGamingFeed(forceRefresh: true);
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final story = filtered[idx];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Material(
                              color: VelvetColors.cardSurface(context),
                              borderRadius: BorderRadius.circular(18),
                              elevation: 1,
                              shadowColor: Colors.black.withValues(alpha: 0.15),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: story.isSecurity
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                                        : VelvetColors.border(context),
                                    width: story.isSecurity ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Row(
                                    children: [
                                      if (story.isSecurity) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFFCA5A5)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.shield_rounded, size: 12, color: Color(0xFFDC2626)),
                                              SizedBox(width: 4),
                                              Text(
                                                'CYBER SECURITY',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFFDC2626),
                                                  letterSpacing: 0.6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: VelvetColors.surface(context),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          story.domain,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: VelvetColors.textPrimary(context),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${story.score}',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: VelvetColors.textPrimary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    story.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: VelvetColors.textPrimary(context),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'by @${story.author}',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: VelvetColors.textSecondary(context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '⏱️ ${story.estimatedReadMinutes}m',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: VelvetColors.textSecondary(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (story.url != null)
                                            IconButton(
                                              icon: Icon(Icons.copy_rounded, size: 15, color: VelvetColors.iconColor(context)),
                                              tooltip: 'Copy Link',
                                              onPressed: () => _copyToClipboard(story.url),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                            ),
                                          const SizedBox(width: 4),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).brightness == Brightness.dark ? VelvetColors.darkSurface : VelvetColors.cocoa,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            icon: const Icon(Icons.open_in_new_rounded, size: 12, color: Colors.white),
                                            label: const Text(
                                              'Read 🌐',
                                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () => _launchArticleUrl(story.url, story.id),
                                          ),
                                          const SizedBox(width: 4),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: VelvetColors.coralPeach,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            icon: const Icon(Icons.lightbulb_outline, size: 12, color: Colors.white),
                                            label: const Text(
                                              'Save to Vault',
                                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () => _saveToIdeaVault(story),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsDashboard(List<HnStory> stories) {
    final total = stories.length;
    final secCount = stories.where((s) => s.isSecurity).length;
    final avgScore = total > 0 ? (stories.map((s) => s.score).reduce((a, b) => a + b) / total).round() : 0;
    final secPercentage = total > 0 ? ((secCount / total) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VelvetColors.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelvetColors.border(context), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_rounded, size: 16, color: VelvetColors.coralPeach),
                  const SizedBox(width: 6),
                  Text(
                    'TECH NEWS & SECURITY METRICS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: VelvetColors.textPrimary(context),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: VelvetColors.mint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('LIVE RADAR ⚡', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: VelvetColors.mint)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricPill(context, 'Tracked', '$total', VelvetColors.periwinkle),
              const SizedBox(width: 6),
              _buildMetricPill(context, 'Threats', '$secCount ($secPercentage%)', const Color(0xFFDC2626)),
              const SizedBox(width: 6),
              _buildMetricPill(context, 'Avg Score', '$avgScore pts', Colors.amber.shade800),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTagChip(context, '#TheHackerNews'),
                _buildTagChip(context, '#CVEZeroDay'),
                _buildTagChip(context, '#RustLang'),
                _buildTagChip(context, '#KernelHardening'),
                _buildTagChip(context, '#SQLCipherE2EE'),
                _buildTagChip(context, '#AIReasoning'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(BuildContext context, String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: VelvetColors.textSecondary(context))),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: VelvetColors.border(context)),
      ),
      child: Text(tag, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: VelvetColors.textPrimary(context))),
    );
  }
}
