import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_container.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../domain/agent_gateway.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

enum AgentPersona { mitnick, newton, jobs }

class MitnickChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AgentGateway _gateway;
  bool _isLoading = false;
  AgentPersona _currentPersona = AgentPersona.mitnick;

  MitnickChatNotifier(this._gateway) : super([]) {
    _resetWelcomeMessage();
  }

  AgentPersona get currentPersona => _currentPersona;
  bool get isLoading => _isLoading;

  void setPersona(AgentPersona newPersona) {
    _currentPersona = newPersona;
    _resetWelcomeMessage();
  }

  void _resetWelcomeMessage() {
    String welcomeText;
    switch (_currentPersona) {
      case AgentPersona.mitnick:
        welcomeText = 'System initialized. Zero-Trust Security Enclave online. I\'m Kevin Mitnick. If you need me to audit your project vault, test encryption resilience, or analyze security vectors, throw a packet my way. Just don\'t ask me to clone your proximity badge... unless you really want to. 🕵️‍♂️⚡';
        break;
      case AgentPersona.newton:
        welcomeText = 'Greetings, scholar. I am Sir Isaac Newton. Let us explore the fundamental hypotheses, mathematical proofs, and scientific literature of your research papers. What shall we scrutinize today? 🔬📜';
        break;
      case AgentPersona.jobs:
        welcomeText = 'Hey. I\'m Steve. We are here to make a dent in the universe. Let\'s make your job search, pitch, or product architecture insanely great. What role or product are we crafting today? 💼✨';
        break;
    }
    state = [
      ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    final textTrim = text.trim();
    if (textTrim.isEmpty) return;

    final userMessage = ChatMessage(
      text: textTrim,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _isLoading = true;
    state = [...state, userMessage];

    try {
      final payloadMessages = _buildStructuredPrompt(state);
      final response = await _gateway
          .dispatchPrompt(userMessage.text, messages: payloadMessages)
          .timeout(const Duration(seconds: 25), onTimeout: () {
        return '⏳ The AI is taking longer than usual (network latency). Please try again in a moment.';
      });

      final responseMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, responseMessage];
    } catch (e) {
      final errorMessage = ChatMessage(
        text: '⚠️ Could not reach AI: $e. Check your internet connection or API key in Settings.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    } finally {
      _isLoading = false;
      state = [...state];
    }
  }

  List<Map<String, String>> _buildStructuredPrompt(List<ChatMessage> history) {
    final list = <Map<String, String>>[];
    String systemPrompt;

    switch (_currentPersona) {
      case AgentPersona.mitnick:
        systemPrompt = 'You are Kevin Mitnick, the legendary hacker and security pioneer. '
            'CRITICAL RULES — follow these absolutely:\n'
            '1. ALWAYS answer the user\'s question DIRECTLY and ACCURATELY first.\n'
            '2. If the user asks a factual question (coding, security, systems, architecture), answer it completely and correctly.\n'
            '3. After answering, you MAY add a brief Mitnick persona comment (zero-day, firewall, social engineering metaphor) — 1 sentence max.\n'
            '4. Format code in markdown blocks with language identifiers.';
        break;
      case AgentPersona.newton:
        systemPrompt = 'You are Sir Isaac Newton, the legendary physicist and mathematician. '
            'CRITICAL RULES — follow these absolutely:\n'
            '1. ALWAYS answer the user\'s question DIRECTLY and ACCURATELY first.\n'
            '2. Assist with scientific research papers, hypotheses, mathematics, and literature review.\n'
            '3. Maintain an intellectual, dignified, and clear tone with structured steps.';
        break;
      case AgentPersona.jobs:
        systemPrompt = 'You are Steve Jobs, Apple co-founder and visionary designer. '
            'CRITICAL RULES — follow these absolutely:\n'
            '1. ALWAYS answer the user\'s question DIRECTLY and ACCURATELY first.\n'
            '2. Help refine outreach messages, interview pitches, resume positioning, and product elegance.\n'
            '3. Focus on simplicity, clarity, and insanely great execution.';
        break;
    }

    list.add({
      'role': 'system',
      'content': systemPrompt,
    });

    // Send up to 10 history turns with token compression for older turns
    final lastMessages = history.length > 10 ? history.sublist(history.length - 10) : history;
    final total = lastMessages.length;

    for (int i = 0; i < total; i++) {
      final msg = lastMessages[i];
      String text = msg.text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

      if (!msg.isUser && i < total - 2 && text.length > 260) {
        text = '${text.substring(0, 250)}... [context compressed]';
      }

      list.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': text,
      });
    }
    return list;
  }
}

final mitnickChatProvider = StateNotifierProvider<MitnickChatNotifier, List<ChatMessage>>((ref) {
  final gateway = ref.read(agentGatewayProvider);
  return MitnickChatNotifier(gateway);
});

class MitnickChatScreen extends ConsumerStatefulWidget {
  const MitnickChatScreen({super.key});

  @override
  ConsumerState<MitnickChatScreen> createState() => _MitnickChatScreenState();
}

class _MitnickChatScreenState extends ConsumerState<MitnickChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(mitnickChatProvider);
    final notifier = ref.read(mitnickChatProvider.notifier);
    
    _scrollToBottom();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? VelvetColors.darkBg : VelvetColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: VelvetColors.textPrimary(context), size: 19),
          onPressed: () => context.pop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.terminal_rounded, color: VelvetColors.coralPeach, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                notifier.currentPersona == AgentPersona.mitnick
                    ? 'MITNICK AI // ZERO-TRUST'
                    : notifier.currentPersona == AgentPersona.newton
                        ? 'NEWTON AI // SCHOLAR'
                        : 'STEVE JOBS AI // VISION',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  letterSpacing: 0.8,
                  color: VelvetColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: VelvetColors.coralPeach),
            tooltip: 'Clear / Reset Session',
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.setPersona(notifier.currentPersona);
              GlassSnackBar.show(context, 'Chat session reset to initial state 🔄');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    VelvetColors.darkBg,
                    VelvetColors.darkSurface,
                    Color(0xFF0F172A),
                  ]
                : const [
                    VelvetColors.cream,
                    Color(0xFFF9EFE7),
                    Color(0xFFFFF2EE),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Persona Switcher Bar (Horizontally scrollable to eliminate all chip overflow)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildPersonaChip(ref, notifier, AgentPersona.mitnick, '🕵️‍♂️ Kevin Mitnick', VelvetColors.coralPeach),
                    const SizedBox(width: 8),
                    _buildPersonaChip(ref, notifier, AgentPersona.newton, '🔬 Isaac Newton', VelvetColors.periwinkle),
                    const SizedBox(width: 8),
                    _buildPersonaChip(ref, notifier, AgentPersona.jobs, '💼 Steve Jobs', VelvetColors.mint),
                  ],
                ),
              ),
              
              // Prompt Templates Horizontal Bar
              _buildPromptTemplatesRow(notifier),
              const SizedBox(height: 8),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: messages.length + (notifier.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(VelvetColors.coralPeach),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  notifier.currentPersona == AgentPersona.mitnick
                                      ? 'Mitnick is auditing firewall bypasses...'
                                      : notifier.currentPersona == AgentPersona.newton
                                          ? 'Newton is evaluating hypothesis...'
                                          : 'Steve is refining the architecture...',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: VelvetColors.textSecondary(context),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Align(
                        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: message.isUser
                            ? ClayCard(
                                color: VelvetColors.cardSurface(context),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                borderRadius: 18,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                  child: Text(
                                    message.text,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: VelvetColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1717) : const Color(0xFF2C2222),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: notifier.currentPersona == AgentPersona.mitnick
                                        ? VelvetColors.coralPeach.withValues(alpha: 0.4)
                                        : notifier.currentPersona == AgentPersona.newton
                                            ? VelvetColors.periwinkle.withValues(alpha: 0.4)
                                            : VelvetColors.mint.withValues(alpha: 0.4),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.shield_outlined,
                                                color: notifier.currentPersona == AgentPersona.mitnick
                                                    ? VelvetColors.coralPeach
                                                    : notifier.currentPersona == AgentPersona.newton
                                                        ? VelvetColors.periwinkle
                                                        : VelvetColors.mint,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                notifier.currentPersona == AgentPersona.mitnick
                                                    ? 'MITNICK // AUDITOR'
                                                    : notifier.currentPersona == AgentPersona.newton
                                                        ? 'NEWTON // SCHOLAR'
                                                        : 'STEVE // VISIONARY',
                                                style: TextStyle(
                                                  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                  color: notifier.currentPersona == AgentPersona.mitnick
                                                      ? VelvetColors.coralPeach
                                                      : notifier.currentPersona == AgentPersona.newton
                                                          ? VelvetColors.periwinkle
                                                          : VelvetColors.mint,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 15),
                                            tooltip: 'Copy Response',
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: message.text));
                                              GlassSnackBar.show(context, 'Copied AI response to clipboard! 📋');
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                          fontFamily: notifier.currentPersona == AgentPersona.mitnick
                                              ? GoogleFonts.jetBrainsMono().fontFamily
                                              : GoogleFonts.inter().fontFamily,
                                          fontSize: notifier.currentPersona == AgentPersona.mitnick ? 12.5 : 13.5,
                                          color: notifier.currentPersona == AgentPersona.mitnick
                                              ? const Color(0xFF7FE7C4)
                                              : Colors.white,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),

              // Input Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: notifier.currentPersona == AgentPersona.mitnick
                                ? 'Ask Mitnick to audit or test vectors...'
                                : notifier.currentPersona == AgentPersona.newton
                                    ? 'Ask Newton to review research...'
                                    : 'Ask Steve to coach your pitch...',
                            hintStyle: TextStyle(color: VelvetColors.textSecondary(context).withValues(alpha: 0.6), fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                          onSubmitted: (val) {
                            final text = val.trim();
                            if (text.isNotEmpty) {
                              _textController.clear();
                              notifier.sendMessage(text);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: VelvetColors.coralPeach),
                        onPressed: () {
                          final text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            _textController.clear();
                            notifier.sendMessage(text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptTemplatesRow(MitnickChatNotifier notifier) {
    final List<String> templates;
    switch (notifier.currentPersona) {
      case AgentPersona.mitnick:
        templates = [
          '🔒 Run Security Audit',
          '👾 Analyze Zero-Day Vector',
          '🔑 Review AES-256 Vault',
        ];
        break;
      case AgentPersona.newton:
        templates = [
          '🔬 Formulate Hypothesis',
          '📚 Review Research Abstract',
          '📐 Scrutinize Math Equations',
        ];
        break;
      case AgentPersona.jobs:
        templates = [
          '💼 Refine Job Pitch',
          '✉️ Outreach Message Review',
          '📱 Product Design Critique',
        ];
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: templates.length,
          itemBuilder: (context, idx) {
            final templateText = templates[idx];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  _textController.text = _getTemplatePromptBody(notifier.currentPersona, templateText);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: VelvetColors.cardSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: VelvetColors.border(context)),
                  ),
                  child: Center(
                    child: Text(
                      templateText,
                      style: TextStyle(
                        fontSize: 11,
                        color: VelvetColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTemplatePromptBody(AgentPersona persona, String template) {
    switch (persona) {
      case AgentPersona.mitnick:
        if (template.contains('Security Audit')) {
          return 'Can you perform a security audit on my project workspace and suggest where I might have potential leakage or key vulnerabilities?';
        } else if (template.contains('Zero-Day')) {
          return 'How should I protect my local-first SQLite/SQLCipher setup from common side-channel memory attacks?';
        } else {
          return 'Review my current database encryption setup: AES-256 for local at-rest and RSA for wrapping backups. Are there any weaknesses?';
        }
      case AgentPersona.newton:
        if (template.contains('Hypothesis')) {
          return 'Help me formulate a mathematical hypothesis for my current research project. How should I structure the methodology?';
        } else if (template.contains('Abstract')) {
          return 'I have a research paper draft. Suggest key gaps that a scientific peer reviewer would point out in my abstract.';
        } else {
          return 'Analyze the natural philosophy and physics equations under the Velvet system. Are my formulas mathematically sound?';
        }
      case AgentPersona.jobs:
        if (template.contains('Refine')) {
          return 'Here is my pitch for the mobile developer role. Help me make it insanely great and simplify the message.';
        } else if (template.contains('Outreach')) {
          return 'Draft an outreach message to a hiring manager at Apple. Keep it clean, simple, and direct.';
        } else {
          return 'Look at the visual elements of my project app: glassmorphism, claymorphism, and skeuomorphism. Are they too noisy or insanely clean?';
        }
    }
  }

  Widget _buildPersonaChip(WidgetRef ref, MitnickChatNotifier notifier, AgentPersona persona, String label, Color accent) {
    final isSelected = notifier.currentPersona == persona;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        notifier.setPersona(persona);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? accent.withValues(alpha: 0.18) : VelvetColors.cardSurface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accent : VelvetColors.border(context),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? accent : VelvetColors.textPrimary(context),
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
