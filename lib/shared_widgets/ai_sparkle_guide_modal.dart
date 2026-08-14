import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/velvet_colors.dart';
import 'clay_card.dart';

class AiSparkleGuideModal extends StatelessWidget {
  final String featureName;
  final String description;
  final List<Map<String, String>> capabilities;

  const AiSparkleGuideModal({
    super.key,
    required this.featureName,
    required this.description,
    required this.capabilities,
  });

  static void show(
    BuildContext context, {
    required String featureName,
    required String description,
    required List<Map<String, String>> capabilities,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiSparkleGuideModal(
        featureName: featureName,
        description: description,
        capabilities: capabilities,
      ),
    );
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
        border: Border(
          top: BorderSide(
            color: VelvetColors.coralPeach.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: VelvetColors.cocoa.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: VelvetColors.cocoa.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: VelvetColors.coralPeach,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              featureName,
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: VelvetColors.textPrimary(context),
                              ),
                            ),
                            const Text(
                              'AI Sparkle Feature Guide ✨',
                              style: TextStyle(
                                fontSize: 11,
                                color: VelvetColors.coralPeach,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: VelvetColors.textSecondary(context),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VelvetColors.clayTan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: VelvetColors.clayTan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: VelvetColors.textPrimary(context),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'What this AI Sparkle does:',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 10),

                ...capabilities.map((cap) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ClayCard(
                      color: VelvetColors.surface(context),
                      padding: const EdgeInsets.all(12),
                      borderRadius: 16,
                      depth: 4,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cap['icon'] ?? '⚡',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cap['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: VelvetColors.cocoa,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cap['detail'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: VelvetColors.textSecondary(context),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Token Efficiency Note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: VelvetColors.mint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: VelvetColors.mint.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 18, color: Color(0xFF16A34A)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚡ 70%+ Token Efficiency Active: All prompts are compressed, deduplicated, and cached locally to maximize your AI quota.',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Got It! Let\'s Build 🚀',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
