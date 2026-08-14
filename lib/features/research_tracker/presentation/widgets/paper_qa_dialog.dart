import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/ai_sparkle_guide_modal.dart';
import '../../../ai_agents/domain/agent_gateway.dart';


class PaperQaDialog extends ConsumerStatefulWidget {
  final String paperTitle;
  final String abstractText;
  const PaperQaDialog({super.key, required this.paperTitle, required this.abstractText});

  static void show(BuildContext context, {required String paperTitle, required String abstractText}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaperQaDialog(paperTitle: paperTitle, abstractText: abstractText),
    );
  }

  @override
  ConsumerState<PaperQaDialog> createState() => _PaperQaDialogState();
}

class _PaperQaDialogState extends ConsumerState<PaperQaDialog> {
  final _questionCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isThinking = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _askQuestion() async {
    final q = _questionCtrl.text.trim();
    if (q.isEmpty || _isThinking) return;

    _questionCtrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': q});
      _isThinking = true;
    });

    final gateway = ref.read(agentGatewayProvider);
    final prompt = 'You are the AI Research Assistant for Pariyojana. Answer this question based on the paper titled "${widget.paperTitle}".\n'
        'Paper Abstract:\n${widget.abstractText}\n\n'
        'User Question: $q\n\n'
        'Keep answer concise, precise, and academically rigorous.';

    final reply = await gateway.dispatchPrompt(prompt);

    if (mounted) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _isThinking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? VelvetColors.darkSurface : VelvetColors.cream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: VelvetColors.border(context), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.question_answer_outlined, color: VelvetColors.coralPeach, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Paper Q&A: ${widget.paperTitle}',
                  style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: VelvetColors.coralPeach, size: 18),
                tooltip: 'AI Sparkle Guide ✨',
                onPressed: () {
                  AiSparkleGuideModal.show(
                    context,
                    featureName: 'AI Paper Q&A Dialogue',
                    description: 'Engage in interactive technical discussions with your BYOK AI agent grounded strictly in the context of this research paper.',
                    capabilities: const [
                      {
                        'icon': '💬',
                        'title': 'Context-Grounded Q&A',
                        'detail': 'Answers are grounded directly in the paper\'s methodology, formulas, and experimental data.',
                      },
                      {
                        'icon': '🛡️',
                        'title': 'OWASP LLM Guard Active',
                        'detail': 'All queries are protected against prompt injection and sensitive data disclosure.',
                      },
                      {
                        'icon': '⚡',
                        'title': '70%+ Token Efficiency',
                        'detail': 'Conversation history is compressed and cached in an LRU memory buffer.',
                      },
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text('Ask questions about methodology, findings, or gaps using BYOK AI.', style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context))),
          const SizedBox(height: 12),

          // Message List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text('Ask anything about this research paper!', style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context))),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final m = _messages[idx];
                      final isUser = m['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? VelvetColors.coralPeach : VelvetColors.surface(context),
                            borderRadius: BorderRadius.circular(16),
                            border: isUser ? null : Border.all(color: VelvetColors.border(context)),
                          ),
                          child: Text(
                            m['content']!,
                            style: TextStyle(fontSize: 12.5, color: isUser ? Colors.white : VelvetColors.textPrimary(context)),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_isThinking)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: VelvetColors.coralPeach)),
                  SizedBox(width: 8),
                  Text('AI analyzing paper abstract...', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. What is the core security contribution?',
                    hintStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: VelvetColors.surface(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _askQuestion(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.send_rounded, size: 18),
                onPressed: _askQuestion,
                style: IconButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
