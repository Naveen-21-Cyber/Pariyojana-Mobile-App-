import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/security/auth_service.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/glass_snackbar.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum _GitHubConnState { idle, loading, connected, error }

class _GitHubUser {
  final String login;
  final String? avatarUrl;
  final int publicRepos;
  final int? privateRepos;

  const _GitHubUser({
    required this.login,
    this.avatarUrl,
    required this.publicRepos,
    this.privateRepos,
  });
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// Settings card that shows GitHub PAT connection status with connect/disconnect.
class GitHubConnectionCard extends ConsumerStatefulWidget {
  const GitHubConnectionCard({super.key});

  @override
  ConsumerState<GitHubConnectionCard> createState() =>
      _GitHubConnectionCardState();
}

class _GitHubConnectionCardState extends ConsumerState<GitHubConnectionCard> {
  static const _patKey = 'velvet_github_pat';

  _GitHubConnState _state = _GitHubConnState.idle;
  _GitHubUser? _user;
  String? _errorMessage;
  final _patController = TextEditingController();
  bool _obscurePat = true;

  @override
  void initState() {
    super.initState();
    _loadStoredPat();
  }

  @override
  void dispose() {
    _patController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredPat() async {
    final storage = ref.read(secureStorageProvider);
    final pat = await storage.readSetting(_patKey);
    if (pat != null && pat.isNotEmpty) {
      _patController.text = pat;
      await _validatePat(pat);
    } else {
      if (mounted) setState(() => _state = _GitHubConnState.idle);
    }
  }

  Future<void> _validatePat(String pat) async {
    if (!mounted) return;
    setState(() {
      _state = _GitHubConnState.loading;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'token $pat',
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _state = _GitHubConnState.connected;
          _user = _GitHubUser(
            login: data['login'] as String? ?? 'unknown',
            avatarUrl: data['avatar_url'] as String?,
            publicRepos: (data['public_repos'] as int?) ?? 0,
            privateRepos: data['total_private_repos'] as int?,
          );
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _state = _GitHubConnState.error;
          _errorMessage = 'Invalid PAT — token rejected by GitHub';
        });
      } else {
        setState(() {
          _state = _GitHubConnState.error;
          _errorMessage = 'GitHub API error: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _GitHubConnState.error;
          _errorMessage = 'Network error: ${e.toString().split(':').first}';
        });
      }
    }
  }

  Future<void> _connect() async {
    final pat = _patController.text.trim();
    if (pat.isEmpty) return;

    await _validatePat(pat);

    if (_state == _GitHubConnState.connected && mounted) {
      final storage = ref.read(secureStorageProvider);
      await storage.writeSetting(_patKey, pat);
      if (mounted) {
        GlassSnackBar.show(
            context, '✅ GitHub connected as @${_user?.login ?? ""}');
      }
    }
  }

  Future<void> _disconnect() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VelvetColors.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Disconnect GitHub?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: VelvetColors.textPrimary(ctx),
          ),
        ),
        content: Text(
          'This will remove your PAT from secure storage. Project sync features will stop working.',
          style: TextStyle(color: VelvetColors.textSecondary(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final storage = ref.read(secureStorageProvider);
      await storage.writeSetting(_patKey, '');
      _patController.clear();
      setState(() {
        _state = _GitHubConnState.idle;
        _user = null;
        _errorMessage = null;
      });
      if (mounted) {
        GlassSnackBar.show(context, '🔌 Disconnected from GitHub');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: switch (_state) {
        _GitHubConnState.connected => _buildConnectedCard(context),
        _GitHubConnState.loading => _buildLoadingCard(context),
        _GitHubConnState.error => _buildErrorCard(context),
        _ => _buildDisconnectedCard(context),
      },
    );
  }

  // ── Connected State ──────────────────────────────────────────────────────────
  Widget _buildConnectedCard(BuildContext context) {
    final user = _user!;
    return Container(
      key: const ValueKey('connected'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelvetColors.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: user.avatarUrl != null
                      ? Image.network(user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.code, color: Colors.white))
                      : const Icon(Icons.code, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${user.login}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Disconnect button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                onPressed: _disconnect,
                icon: const Icon(Icons.link_off_rounded, size: 14),
                label: const Text('Disconnect'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              _statChip(
                  context, Icons.folder_rounded, '${user.publicRepos}', 'public'),
              const SizedBox(width: 8),
              if (user.privateRepos != null)
                _statChip(context, Icons.lock_rounded,
                    '${user.privateRepos}', 'private'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(
      BuildContext context, IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: VelvetColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: VelvetColors.textSecondary(context)),
          const SizedBox(width: 5),
          Text(
            '$value $label',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: VelvetColors.textPrimary(context)),
          ),
        ],
      ),
    );
  }

  // ── Loading State ────────────────────────────────────────────────────────────
  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      key: const ValueKey('loading'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VelvetColors.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelvetColors.border(context)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(VelvetColors.coralPeach),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Validating GitHub token...',
            style: TextStyle(
                fontSize: 13, color: VelvetColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  // ── Error State ──────────────────────────────────────────────────────────────
  Widget _buildErrorCard(BuildContext context) {
    return Container(
      key: const ValueKey('error'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelvetColors.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage ?? 'Connection failed',
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPatField(context),
          const SizedBox(height: 10),
          _buildConnectButton(),
        ],
      ),
    );
  }

  // ── Disconnected State ───────────────────────────────────────────────────────
  Widget _buildDisconnectedCard(BuildContext context) {
    return Container(
      key: const ValueKey('disconnected'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelvetColors.cardSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelvetColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GitHub',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Not connected',
                      style: TextStyle(
                          fontSize: 11,
                          color: VelvetColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Enter a Personal Access Token (PAT) to link your GitHub account. Enables project sync, CI/CD pipeline control, and repo publishing.',
            style: TextStyle(
                fontSize: 12, color: VelvetColors.textSecondary(context)),
          ),
          const SizedBox(height: 12),
          _buildPatField(context),
          const SizedBox(height: 10),
          _buildConnectButton(),
        ],
      ),
    );
  }

  Widget _buildPatField(BuildContext context) {
    return TextField(
      controller: _patController,
      obscureText: _obscurePat,
      style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
      decoration: InputDecoration(
        labelText: 'GitHub Personal Access Token',
        hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
        hintStyle:
            TextStyle(color: VelvetColors.textSecondary(context), fontSize: 12),
        prefixIcon: const Icon(Icons.key_rounded, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
              _obscurePat ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              size: 18),
          onPressed: () => setState(() => _obscurePat = !_obscurePat),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildConnectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: _state == _GitHubConnState.loading ? null : _connect,
        icon: const Icon(Icons.link_rounded, size: 16),
        label: const Text('Connect GitHub',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
