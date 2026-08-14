import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../../../core/security/auth_service.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../providers/project_provider.dart';

class GitHubRepoImportSheet extends ConsumerStatefulWidget {
  const GitHubRepoImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GitHubRepoImportSheet(),
    );
  }

  @override
  ConsumerState<GitHubRepoImportSheet> createState() =>
      _GitHubRepoImportSheetState();
}

class _GitHubRepoImportSheetState
    extends ConsumerState<GitHubRepoImportSheet> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _repos = [];
  final Set<int> _importedRepoIds = {};

  @override
  void initState() {
    super.initState();
    _fetchRepos();
  }

  Future<void> _fetchRepos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final storage = ref.read(secureStorageProvider);
    final pat = await storage.readSetting('velvet_github_pat');

    if (pat == null || pat.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'No GitHub PAT configured. Go to Settings → Integrations to link your GitHub account.';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user/repos?sort=updated&per_page=30'),
        headers: {
          'Authorization': 'token $pat',
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        setState(() {
          _repos = list.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'GitHub API Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Network error fetching repos: ${e.toString().split(':').first}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importRepo(Map<String, dynamic> repoData) async {
    final int repoId = repoData['id'] as int;
    final String name = repoData['name'] as String? ?? 'Untitled Repo';
    final String? description = repoData['description'] as String?;
    final String? language = repoData['language'] as String?;
    final String htmlUrl = repoData['html_url'] as String? ?? '';

    final projectRepo = ref.read(projectRepositoryProvider);

    await projectRepo.insertProject(
      ProjectsCompanion.insert(
        name: name,
        description: drift.Value(description ?? 'Imported from GitHub remote repository.'),
        status: 'Active',
        priority: 'MEDIUM',
        techStack: drift.Value(language),
        notes: drift.Value('GitHub URL: $htmlUrl'),
      ),
    );

    setState(() {
      _importedRepoIds.add(repoId);
    });

    if (mounted) {
      GlassSnackBar.show(context, '⚡ Imported "$name" as an active project!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: VelvetColors.border(context)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: VelvetColors.textSecondary(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Repositories from GitHub 🐙',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: VelvetColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Select any remote repository to import as an active project',
                        style: TextStyle(
                          fontSize: 11,
                          color: VelvetColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: VelvetColors.textSecondary(context)),
                  onPressed: _fetchRepos,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(VelvetColors.coralPeach),
            ),
            const SizedBox(height: 12),
            Text(
              'Fetching repositories from GitHub...',
              style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.amber),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelvetColors.coralPeach,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _fetchRepos,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_repos.isEmpty) {
      return Center(
        child: Text(
          'No repositories found on this account.',
          style: TextStyle(color: VelvetColors.textSecondary(context)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _repos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final repo = _repos[index];
        final int id = repo['id'] as int;
        final String name = repo['name'] as String? ?? 'Repo';
        final String? desc = repo['description'] as String?;
        final String? lang = repo['language'] as String?;
        final int stars = (repo['stargazers_count'] as int?) ?? 0;
        final bool isPrivate = repo['private'] as bool? ?? false;
        final bool isImported = _importedRepoIds.contains(id);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: VelvetColors.cardSurface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VelvetColors.border(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: VelvetColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (isPrivate) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 10, color: Colors.amber.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  'Private',
                                  style: TextStyle(fontSize: 9, color: Colors.amber.shade700, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (desc != null && desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (lang != null) ...[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lang,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: VelvetColors.coralPeach),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(Icons.star_rounded, size: 13, color: Colors.amber.shade600),
                        const SizedBox(width: 3),
                        Text(
                          '$stars',
                          style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isImported ? Colors.green : VelvetColors.coralPeach,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: isImported ? null : () => _importRepo(repo),
                icon: Icon(isImported ? Icons.check_rounded : Icons.add_rounded, size: 16),
                label: Text(
                  isImported ? 'Imported' : 'Import',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
