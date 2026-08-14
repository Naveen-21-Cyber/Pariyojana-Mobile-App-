import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';

class SecurityHardeningScanner extends StatefulWidget {
  final Project project;

  const SecurityHardeningScanner({
    super.key,
    required this.project,
  });

  @override
  State<SecurityHardeningScanner> createState() => _SecurityHardeningScannerState();
}

class _SecurityHardeningScannerState extends State<SecurityHardeningScanner> {
  late List<Map<String, dynamic>> _checkpoints;
  final Set<int> _completed = {};

  @override
  void initState() {
    super.initState();
    _generateCheckpoints();
  }

  void _generateCheckpoints() {
    final stack = (widget.project.techStack ?? '').toLowerCase();
    final items = <Map<String, dynamic>>[];

    // Baseline Security Rules
    items.add({
      'title': 'Environment Key Isolation',
      'desc': 'Never commit API keys or secrets to Git repository. Use .env or flutter_dotenv.',
      'category': 'General',
    });
    items.add({
      'title': 'Encrypted Storage Baseline',
      'desc': 'Ensure all sensitive offline user data is encrypted with SQLCipher or AES-256-GCM.',
      'category': 'Crypto',
    });

    if (stack.contains('sqlcipher') || stack.contains('sqlite')) {
      items.add({
        'title': 'DB PRAGMA Cipher Configuration',
        'desc': 'Enforce key derivation iterations >= 64,000 and zero out page buffers on close.',
        'category': 'Database',
      });
    }

    if (stack.contains('node') || stack.contains('fastapi') || stack.contains('express') || stack.contains('backend')) {
      items.add({
        'title': 'HTTP Rate-Limiting & Helmet Middleware',
        'desc': 'Implement IP rate-limiting (e.g. express-rate-limit) and Security Headers (CSP, HSTS).',
        'category': 'Backend',
      });
      items.add({
        'title': 'CORS Whitelist Scoping',
        'desc': 'Disable wildcard CORS (*) and allow requests only from verified client origins.',
        'category': 'Network',
      });
    }

    if (stack.contains('infinityfree') || stack.contains('hosting') || stack.contains('php')) {
      items.add({
        'title': 'InfinityFree / Shared Host Hardening',
        'desc': 'Disable Directory Indexing (.htaccess Options -Indexes) and enforce HTTPS redirect.',
        'category': 'Hosting',
      });
    }

    if (stack.contains('jwt') || stack.contains('auth')) {
      items.add({
        'title': 'Short-lived JWT & HttpOnly Refresh Tokens',
        'desc': 'Set access token expiry <= 15m and store refresh tokens in secure HttpOnly cookies.',
        'category': 'Auth',
      });
    }

    if (stack.contains('ai') || stack.contains('openai') || stack.contains('gemini')) {
      items.add({
        'title': 'LLM Prompt Injection Sanitization',
        'desc': 'Sanitize untrusted user inputs before appending to system prompts.',
        'category': 'AI/ML Security',
      });
    }

    _checkpoints = items;
  }

  void _copyChecklist() {
    final buffer = StringBuffer();
    buffer.writeln('🛡️ SECURITY HARDENING AUDIT CHECKLIST FOR ${widget.project.name.toUpperCase()}');
    buffer.writeln('Tech Stack: ${widget.project.techStack ?? "Standard"}\n');
    for (int i = 0; i < _checkpoints.length; i++) {
      final isDone = _completed.contains(i);
      buffer.writeln('${isDone ? "[✔]" : "[ ]"} ${_checkpoints[i]['title']} (${_checkpoints[i]['category']})');
      buffer.writeln('    └─ ${_checkpoints[i]['desc']}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    GlassSnackBar.show(context, 'Security Audit Checklist copied to clipboard! 📋🛡️');
  }

  @override
  Widget build(BuildContext context) {
    final total = _checkpoints.length;
    final done = _completed.length;
    final percent = total == 0 ? 100 : ((done / total) * 100).toInt();

    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: VelvetColors.coralPeach, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Security Hardening & Zero-Trust Audit',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18, color: VelvetColors.periwinkle),
                onPressed: _copyChecklist,
                tooltip: 'Copy Security Audit',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 1.0 : done / total,
                    minHeight: 8,
                    backgroundColor: VelvetColors.border(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percent == 100 ? VelvetColors.mint : VelvetColors.coralPeach,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent% Hardened',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _checkpoints.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isChecked = _completed.contains(idx);

              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: VelvetColors.mint,
                title: Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  item['desc'],
                  style: TextStyle(fontSize: 10.5, color: VelvetColors.textSecondary(context)),
                ),
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _completed.add(idx);
                    } else {
                      _completed.remove(idx);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
