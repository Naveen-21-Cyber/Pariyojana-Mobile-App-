import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';
import '../core/database/database.dart';
import '../core/security/credential_scanner.dart';
import '../features/idea_vault/presentation/providers/idea_provider.dart';
import 'glass_snackbar.dart';

class QuickThoughtCaptureSheet extends ConsumerStatefulWidget {
  const QuickThoughtCaptureSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const QuickThoughtCaptureSheet(),
      ),
    );
  }

  @override
  ConsumerState<QuickThoughtCaptureSheet> createState() => _QuickThoughtCaptureSheetState();
}

class _QuickThoughtCaptureSheetState extends ConsumerState<QuickThoughtCaptureSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedCategory = 'Quick Thought';
  bool _isSaving = false;

  final List<String> _categories = [
    'Quick Thought',
    'Innovation',
    'Research',
    'Project',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus text input for 0-click typing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveThought() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final haptic = ref.read(hapticServiceProvider);

    // Security check: Guard against exposed secrets
    final hasSecret = CredentialScanner.scanAndAlert(context, text, fieldName: 'Quick Thought');
    if (hasSecret) return;

    setState(() => _isSaving = true);
    await haptic.lightTap();

    try {
      final companion = IdeasCompanion.insert(
        content: text,
        category: _selectedCategory,
      );

      await ref.read(ideaRepositoryProvider).insertIdea(companion);

      if (mounted) {
        Navigator.pop(context);
        GlassSnackBar.show(context, '⚡ Thought vaulted securely in SQLCipher');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        GlassSnackBar.show(context, 'Failed to save thought: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: VelvetColors.border(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('⚡', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Thought Capture',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Encrypted instant idea vaulting in < 3s',
                      style: TextStyle(
                        fontSize: 11,
                        color: VelvetColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 20, color: VelvetColors.iconColor(context)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : VelvetColors.textPrimary(context),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: VelvetColors.coralPeach,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Thought Input Field
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.4 : 0.3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 2,
              style: TextStyle(
                fontSize: 14,
                color: VelvetColors.textPrimary(context),
              ),
              decoration: InputDecoration(
                hintText: 'What\'s on your mind? Jot it down before it slips away...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: VelvetColors.textSecondary(context).withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _saveThought(),
            ),
          ),
          const SizedBox(height: 16),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveThought,
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Vault Thought Instantly ⚡',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
