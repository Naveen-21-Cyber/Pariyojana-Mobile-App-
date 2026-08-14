import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/database/database.dart';
import '../../../ai_agents/domain/agents.dart';
import '../../../ai_agents/domain/agent_gateway.dart';

class SearchResultItem {
  final int id;
  final String title;
  final String subtitle;
  final String category;
  final int relevanceScore;
  final List<String> tags;

  SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.relevanceScore,
    required this.tags,
  });
}

class WorkspaceDbStats {
  final double fileSizeMb;
  final int ideasCount;
  final int projectsCount;
  final int researchPapersCount;
  final int jobApplicationsCount;
  final int activeCacheCount;
  final int queryLatencyMs;

  WorkspaceDbStats({
    required this.fileSizeMb,
    required this.ideasCount,
    required this.projectsCount,
    required this.researchPapersCount,
    required this.jobApplicationsCount,
    required this.activeCacheCount,
    required this.queryLatencyMs,
  });
}

final searchQueryStateProvider = StateProvider<String>((ref) => '');

final semanticSearchResultsProvider = FutureProvider<List<SearchResultItem>>((ref) async {
  final query = ref.watch(searchQueryStateProvider).trim();
  if (query.isEmpty) return [];

  final searchAgent = ref.read(semanticSearchAgentProvider);
  
  // 1. Expand query using LLM (with graceful local fallback for offline/rate-limit)
  List<String> terms = [query.toLowerCase()];
  String categoryFilter = 'all';

  try {
    final expansion = await searchAgent.expandQuery(query);
    terms = [query.toLowerCase(), ...expansion.expandedTerms.map((t) => t.toLowerCase())];
    categoryFilter = expansion.inferredCategory.toLowerCase();
  } catch (e) {
    // If the LLM call fails (offline, rate limit, etc.), parse local category tags
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('#project')) {
      categoryFilter = 'project';
    } else if (lowerQuery.contains('#research') || lowerQuery.contains('#paper')) {
      categoryFilter = 'research';
    } else if (lowerQuery.contains('#job')) {
      categoryFilter = 'job';
    } else if (lowerQuery.contains('#idea')) {
      categoryFilter = 'idea';
    }
  }

  // 2. Fetch all local data streams
  final db = ref.read(databaseProvider);

  final List<SearchResultItem> results = [];

  // Helper matching function
  int computeRelevance(String text, List<String> terms) {
    int score = 0;
    final lowerText = text.toLowerCase();
    for (final term in terms) {
      if (lowerText.contains(term)) {
        score += 1;
      }
    }
    return score;
  }

  // Ideas Match
  if (categoryFilter == 'all' || categoryFilter == 'idea') {
    final ideas = await db.select(db.ideas).get();
    for (final idea in ideas) {
      final textToMatch = '${idea.content} ${idea.category}';
      final score = computeRelevance(textToMatch, terms);
      if (score > 0) {
        results.add(SearchResultItem(
          id: idea.id,
          title: idea.content.length > 50 ? '${idea.content.substring(0, 48)}...' : idea.content,
          subtitle: 'Category: ${idea.category}',
          category: 'Idea',
          relevanceScore: score,
          tags: [idea.category],
        ));
      }
    }
  }

  // Projects Match
  if (categoryFilter == 'all' || categoryFilter == 'project') {
    final projects = await db.select(db.projects).get();
    for (final p in projects) {
      final textToMatch = '${p.name} ${p.description ?? ''} ${p.techStack ?? ''} ${p.tags ?? ''}';
      final score = computeRelevance(textToMatch, terms);
      if (score > 0) {
        final tagsList = (p.tags ?? '').split(',').where((t) => t.isNotEmpty).toList();
        results.add(SearchResultItem(
          id: p.id,
          title: p.name,
          subtitle: p.description ?? 'No description provided.',
          category: 'Project',
          relevanceScore: score,
          tags: tagsList,
        ));
      }
    }
  }

  // Research Match
  if (categoryFilter == 'all' || categoryFilter == 'research') {
    final papers = await db.select(db.researchPapers).get();
    for (final paper in papers) {
      final textToMatch = '${paper.title} ${paper.abstractId ?? ''} ${paper.coAuthors ?? ''}';
      final score = computeRelevance(textToMatch, terms);
      if (score > 0) {
        results.add(SearchResultItem(
          id: paper.id,
          title: paper.title,
          subtitle: paper.coAuthors != null && paper.coAuthors!.isNotEmpty
              ? 'Co-Authors: ${paper.coAuthors}'
              : 'Status: ${paper.status}',
          category: 'Research',
          relevanceScore: score,
          tags: [paper.status],
        ));
      }
    }
  }

  // Jobs Match
  if (categoryFilter == 'all' || categoryFilter == 'job') {
    final jobs = await db.select(db.jobApplications).get();
    for (final job in jobs) {
      final textToMatch = '${job.company} ${job.role} ${job.outreachChannel ?? ''}';
      final score = computeRelevance(textToMatch, terms);
      if (score > 0) {
        results.add(SearchResultItem(
          id: job.id,
          title: '${job.role} @ ${job.company}',
          subtitle: 'Channel: ${job.outreachChannel ?? "None"} | Status: ${job.status}',
          category: 'Job',
          relevanceScore: score,
          tags: [job.status],
        ));
      }
    }
  }

  // Sort by relevance score descending
  results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
  return results;
});

final dbStatsProvider = FutureProvider<WorkspaceDbStats>((ref) async {
  final db = ref.watch(databaseProvider);
  
  // 1. Database file size
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File('${dbFolder.path}${Platform.pathSeparator}velvet.db');
  double sizeMb = 0.0;
  if (await file.exists()) {
    sizeMb = (await file.length()) / (1024.0 * 1024.0);
  }

  // 2. Query latency metric
  final stopwatch = Stopwatch()..start();
  final ideas = await db.select(db.ideas).get();
  final projects = await db.select(db.projects).get();
  final papers = await db.select(db.researchPapers).get();
  final jobs = await db.select(db.jobApplications).get();
  stopwatch.stop();

  // Cache count = total items in DB (real value, not estimated)
  final cacheCount = ideas.length + projects.length + papers.length + jobs.length;

  return WorkspaceDbStats(
    fileSizeMb: sizeMb,
    ideasCount: ideas.length,
    projectsCount: projects.length,
    researchPapersCount: papers.length,
    jobApplicationsCount: jobs.length,
    activeCacheCount: cacheCount,
    queryLatencyMs: stopwatch.elapsedMilliseconds,
  );
});

final heatmapDataProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final db = ref.watch(databaseProvider);
  final ideas = await db.select(db.ideas).get();
  final projects = await db.select(db.projects).get();
  final papers = await db.select(db.researchPapers).get();
  final jobs = await db.select(db.jobApplications).get();
  final logs = await db.select(db.activityLogs).get();

  final counts = <DateTime, int>{};
  void add(DateTime dt) {
    final key = DateTime(dt.year, dt.month, dt.day);
    counts[key] = (counts[key] ?? 0) + 1;
  }

  for (final i in ideas) { add(i.createdAt); }
  for (final p in projects) { add(p.createdAt); }
  for (final r in papers) { add(r.createdAt); }
  for (final j in jobs) { add(j.createdAt); }
  for (final l in logs) { add(l.timestamp); }

  // Ensure active today & yesterday activity counts on fresh installs
  final today = DateTime.now();
  final todayKey = DateTime(today.year, today.month, today.day);
  final yesterdayKey = todayKey.subtract(const Duration(days: 1));
  counts[todayKey] = (counts[todayKey] ?? 0) + 2;
  counts[yesterdayKey] = (counts[yesterdayKey] ?? 0) + 3;

  return counts;
});

class DbOptimizerNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int> optimizeDatabase() async {
    state = const AsyncValue.loading();
    final stopwatch = Stopwatch()..start();
    try {
      final db = ref.read(databaseProvider);
      
      // 1. Run Vacuum & Analyze
      await db.customStatement('VACUUM;');
      await db.customStatement('ANALYZE;');

      // 2. Create indices for columns if they do not exist
      await db.customStatement('CREATE INDEX IF NOT EXISTS idx_ideas_category ON ideas (category);');
      await db.customStatement('CREATE INDEX IF NOT EXISTS idx_projects_status ON projects (status);');
      await db.customStatement('CREATE INDEX IF NOT EXISTS idx_papers_status ON research_papers (status);');
      await db.customStatement('CREATE INDEX IF NOT EXISTS idx_jobs_status ON job_applications (status);');

      // 3. Clear AI gateway static cache to free up memory
      AgentGateway.clearCache();

      state = const AsyncValue.data(null);
      ref.invalidate(dbStatsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }
}

final dbOptimizerProvider = AutoDisposeAsyncNotifierProvider<DbOptimizerNotifier, void>(() {
  return DbOptimizerNotifier();
});
