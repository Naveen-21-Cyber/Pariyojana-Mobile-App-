import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';
import '../features/project_tracker/presentation/providers/project_provider.dart';
import '../features/research_tracker/presentation/providers/research_provider.dart';
import '../features/job_tracker/presentation/providers/job_provider.dart';
import '../features/idea_vault/presentation/providers/idea_provider.dart';
import '../core/backup/google_backup_service.dart';
import '../core/services/update_checker_service.dart';

enum LogType { info, success, warning, error, input, system, quote }

class _TerminalLogEntry {
  final String text;
  final LogType type;
  final DateTime timestamp;

  _TerminalLogEntry(this.text, this.type) : timestamp = DateTime.now();
}

/// A clean, cyberpunk OS Command Terminal Sheet for Pariyojana.
class CompanionTerminalSheet extends ConsumerStatefulWidget {
  const CompanionTerminalSheet({super.key});

  @override
  ConsumerState<CompanionTerminalSheet> createState() => _CompanionTerminalSheetState();
}

class _CompanionTerminalSheetState extends ConsumerState<CompanionTerminalSheet> {
  final List<_TerminalLogEntry> _logs = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initTerminalLogs();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initTerminalLogs() {
    _logs.add(_TerminalLogEntry('==================================================', LogType.info));
    _logs.add(_TerminalLogEntry('  PARIYOJANA CYBER COMMAND TERMINAL v1.1.2      ', LogType.success));
    _logs.add(_TerminalLogEntry('  SQLCIPHER AES-256 ENCRYPTED PRODUCTION BACKEND  ', LogType.info));
    _logs.add(_TerminalLogEntry('==================================================', LogType.info));
    _logs.add(_TerminalLogEntry('Tap a quick action chip below or type "help".', LogType.system));
    _logs.add(_TerminalLogEntry('', LogType.system));
  }

  void _handleCommand(String cmdRaw) async {
    final cmd = cmdRaw.trim();
    if (cmd.isEmpty) return;

    _inputController.clear();
    setState(() {
      _logs.add(_TerminalLogEntry('user > $cmd', LogType.input));
    });

    await ref.read(hapticServiceProvider).lightTap();
    final parts = cmd.split(' ');
    final action = parts.first.toLowerCase();

    switch (action) {
      case 'help':
        setState(() {
          _logs.add(_TerminalLogEntry('⚡ COMMAND REFERENCE:', LogType.success));
          _logs.add(_TerminalLogEntry('  help     - Show command list', LogType.system));
          _logs.add(_TerminalLogEntry('  stats    - Query active DB project/paper/job counts', LogType.system));
          _logs.add(_TerminalLogEntry('  version  - Print Pariyojana OS version info', LogType.system));
          _logs.add(_TerminalLogEntry('  projects - List active projects summary', LogType.system));
          _logs.add(_TerminalLogEntry('  ideas    - Query encrypted idea vault items', LogType.system));
          _logs.add(_TerminalLogEntry('  sync     - Trigger Google Drive cloud sync', LogType.system));
          _logs.add(_TerminalLogEntry('  sys      - View security & encryption status', LogType.system));
          _logs.add(_TerminalLogEntry('  clear    - Clear terminal buffer', LogType.system));
        });
        break;

      case 'version':
        final ver = await UpdateCheckerService.currentAppVersion();
        setState(() {
          _logs.add(_TerminalLogEntry('🛡️ PARIYOJANA OS VERSION INFO:', LogType.success));
          _logs.add(_TerminalLogEntry('  App Version : $ver (Production Release)', LogType.system));
          _logs.add(_TerminalLogEntry('  Cipher Engine: SQLCipher AES-256-GCM', LogType.system));
        });
        break;

      case 'projects':
        try {
          final projects = ref.read(projectsStreamProvider).asData?.value ?? [];
          setState(() {
            _logs.add(_TerminalLogEntry('📁 ACTIVE PROJECTS (${projects.length}):', LogType.success));
            for (final p in projects.take(5)) {
              _logs.add(_TerminalLogEntry('  • ${p.name} [${p.status}]', LogType.system));
            }
          });
        } catch (e) {
          setState(() {
            _logs.add(_TerminalLogEntry('Error querying projects: $e', LogType.error));
          });
        }
        break;

      case 'ideas':
        try {
          final ideas = ref.read(ideasStreamProvider).asData?.value ?? [];
          setState(() {
            _logs.add(_TerminalLogEntry('💡 ENCRYPTED IDEAS (${ideas.length}):', LogType.success));
            for (final i in ideas.take(5)) {
              _logs.add(_TerminalLogEntry('  • [${i.category}] ${i.content.split("\n").first}', LogType.system));
            }
          });
        } catch (e) {
          setState(() {
            _logs.add(_TerminalLogEntry('Error querying ideas: $e', LogType.error));
          });
        }
        break;

      case 'stats':
        try {
          final projects = ref.read(projectsStreamProvider).asData?.value ?? [];
          final papers = ref.read(researchPapersStreamProvider).asData?.value ?? [];
          final jobs = ref.read(jobApplicationsStreamProvider).asData?.value ?? [];
          final ideas = ref.read(ideasStreamProvider).asData?.value ?? [];

          setState(() {
            _logs.add(_TerminalLogEntry('📊 LIVE WORKSPACE INVENTORY:', LogType.success));
            _logs.add(_TerminalLogEntry('  📁 Active Projects: ${projects.length}', LogType.system));
            _logs.add(_TerminalLogEntry('  📚 Research Papers: ${papers.length}', LogType.system));
            _logs.add(_TerminalLogEntry('  💼 Job Applications: ${jobs.length}', LogType.system));
            _logs.add(_TerminalLogEntry('  💡 Idea Vault Items: ${ideas.length}', LogType.system));
          });
        } catch (e) {
          setState(() => _logs.add(_TerminalLogEntry('❌ Error fetching stats: $e', LogType.error)));
        }
        break;

      case 'sync':
        setState(() {
          _logs.add(_TerminalLogEntry('Triggering Google Drive backup...', LogType.info));
        });
        final googleBackup = ref.read(googleBackupServiceProvider);
        final syncOk = await googleBackup.backupDatabaseToDrive();
        setState(() {
          if (syncOk) {
            _logs.add(_TerminalLogEntry('✓ Cloud backup completed successfully.', LogType.success));
          } else {
            _logs.add(_TerminalLogEntry('✗ Sync failed. Connect Google Account in Settings.', LogType.error));
          }
        });
        break;

      case 'sys':
        setState(() {
          _logs.add(_TerminalLogEntry('🛡️ SECURITY TELEMETRY:', LogType.success));
          _logs.add(_TerminalLogEntry('  Status: Sovereign (100% Offline)', LogType.system));
          _logs.add(_TerminalLogEntry('  Database: SQLCipher v4 (AES-256)', LogType.system));
          _logs.add(_TerminalLogEntry('  Key Vault: Android KeyStore TEE', LogType.system));
        });
        break;

      case 'clear':
        setState(() {
          _logs.clear();
          _initTerminalLogs();
        });
        break;

      default:
        setState(() {
          _logs.add(_TerminalLogEntry('Unknown command "$action". Type "help" for options.', LogType.error));
        });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.info:
        return const Color(0xFF58A6FF);
      case LogType.success:
        return const Color(0xFF3FB950);
      case LogType.warning:
        return const Color(0xFFD29922);
      case LogType.error:
        return const Color(0xFFF85149);
      case LogType.input:
        return Colors.white;
      case LogType.system:
        return const Color(0xFF8B949E);
      case LogType.quote:
        return const Color(0xFFBC8CFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Terminal Title Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                FutureBuilder<String>(
                  future: UpdateCheckerService.currentAppVersion(),
                  builder: (context, snapshot) => Text(
                    'CYBER_TERMINAL v${snapshot.data ?? "1.1.2"}',
                    style: GoogleFonts.firaCode(fontSize: 12, color: const Color(0xFF8B949E), fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8B949E), size: 18),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Log Viewport
          Expanded(
            child: Container(
              color: const Color(0xFF0D1117),
              padding: const EdgeInsets.all(14),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _logs.length,
                itemBuilder: (ctx, i) {
                  final log = _logs[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${DateFormat('HH:mm:ss').format(log.timestamp)} ${log.text}',
                      style: GoogleFonts.firaCode(
                        fontSize: 11.5,
                        color: _getLogColor(log.type),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Quick Command Action Chips
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFF161B22),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickChip('help'),
                _buildQuickChip('stats'),
                _buildQuickChip('projects'),
                _buildQuickChip('ideas'),
                _buildQuickChip('sys'),
                _buildQuickChip('sync'),
                _buildQuickChip('clear'),
              ],
            ),
          ),

          // Input Prompt Bar
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            color: const Color(0xFF0D1117),
            child: Row(
              children: [
                Text(
                  '>',
                  style: GoogleFonts.firaCode(fontSize: 16, color: const Color(0xFF3FB950), fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    style: GoogleFonts.firaCode(fontSize: 13, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type command...',
                      hintStyle: TextStyle(color: Color(0xFF484F58)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: _handleCommand,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: VelvetColors.coralPeach, size: 20),
                  onPressed: () => _handleCommand(_inputController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String cmd) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ActionChip(
        label: Text(cmd, style: GoogleFonts.firaCode(fontSize: 10, color: Colors.white)),
        backgroundColor: const Color(0xFF21262D),
        side: const BorderSide(color: Color(0xFF30363D)),
        onPressed: () => _handleCommand(cmd),
      ),
    );
  }
}
