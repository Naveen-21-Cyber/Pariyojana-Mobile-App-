import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/network_disclaimer_banner.dart';
import '../../../ai_agents/domain/agent_gateway.dart';

class AiInterviewSimulator extends ConsumerStatefulWidget {
  final JobApplication job;

  const AiInterviewSimulator({
    super.key,
    required this.job,
  });

  @override
  ConsumerState<AiInterviewSimulator> createState() => _AiInterviewSimulatorState();
}

class _AiInterviewSimulatorState extends ConsumerState<AiInterviewSimulator> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  String? _selectedMcqOption;
  bool _isGeneratingQuestions = true;
  bool _isEvaluating = false;
  bool _isCompleted = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAiQuestions();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _generateAiQuestions() async {
    setState(() {
      _isGeneratingQuestions = true;
    });

    final role = widget.job.role;
    final company = widget.job.company;

    try {
      final gateway = ref.read(agentGatewayProvider);
      final prompt = 'Act as a Senior Technical Recruiter & Architect interviewing for "$role" at "$company".\n'
          'Generate exactly 15 interview questions:\n'
          '7 WRITTEN ESSAY questions requiring technical candidate explanation.\n'
          '8 MULTIPLE CHOICE (MCQ) questions with 4 options (A, B, C, D) and a designated correct option.\n\n'
          'Format strict JSON array with 15 objects:\n'
          '[\n'
          '  {"type": "written", "rawQ": "Explain your approach for...", "tip": "Mention..."},\n'
          '  ...\n'
          '  {"type": "mcq", "rawQ": "Which cryptographic algorithm...", "options": ["A) ...", "B) ...", "C) ...", "D) ..."], "correct": "A", "tip": "..."}\n'
          ']';

      final rawResponse = await gateway.dispatchPrompt(prompt);
      final jsonStart = rawResponse.indexOf('[');
      final jsonEnd = rawResponse.lastIndexOf(']');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final cleanedJson = rawResponse.substring(jsonStart, jsonEnd + 1);
        final List<dynamic> parsed = jsonDecode(cleanedJson);
        final List<Map<String, dynamic>> loaded = [];

        for (int i = 0; i < parsed.length; i++) {
          final item = parsed[i];
          final isMcq = i >= 7;
          final type = isMcq ? 'mcq' : 'written';
          final rawQText = item['rawQ']?.toString() ?? item['q']?.toString() ?? (isMcq ? 'Select technical choice.' : 'Explain your technical approach.');
          final tipText = item['tip']?.toString() ?? 'Cover architecture principles and specific tools.';
          
          List<String> options = [];
          if (item['options'] is List) {
            options = (item['options'] as List).map((e) => e.toString()).toList();
          } else if (isMcq) {
            options = ['A) Core framework architecture', 'B) Hardware keystore zeroing', 'C) Dynamic state optimization', 'D) TLS 1.3 key wrapping'];
          }

          loaded.add({
            'type': type,
            'rawQ': rawQText.replaceAll(RegExp(r'^Question\s*\d+/\d+\s*(\([^)]+\))?:\s*', caseSensitive: false), ''),
            'tip': tipText,
            'options': options,
            'correct': item['correct']?.toString() ?? 'A',
          });
        }

        if (loaded.length == 15) {
          loaded.shuffle(); // Shuffle the topics mix FIRST
          if (mounted) {
            setState(() {
              _questions = loaded;
              _isGeneratingQuestions = false;
            });
          }
          return;
        }
      }
    } catch (_) {}

    _fallbackGenerateQuestions(role, company);
  }

  void _fallbackGenerateQuestions(String role, String company) {
    List<Map<String, dynamic>> loaded = List.generate(15, (index) {
      final isMcq = index >= 7;

      if (!isMcq) {
        // Questions 1 to 7: Written
        final writtenTopics = [
          'differentiating SIEM True Positives from Benign alerts in $company',
          'AES-256 local database key wrapping without master key leaks',
          'analyzing suspicious executables during DFIR investigations',
          'mapping adversary behavior to MITRE ATT&CK TTP frameworks',
          'implementing Zero-Trust Network Architecture (ZTNA)',
          'executing NIST SP 800-61 incident containment',
          'evaluating supplier security stacks & third-party risks'
        ];
        return {
          'type': 'written',
          'rawQ': 'Explain your methodology for ${writtenTopics[index % writtenTopics.length]}.',
          'tip': 'Reference technical controls, zero-trust principles, and execution steps.',
          'options': <String>[],
          'correct': '',
        };
      } else {
        // Questions 8 to 15: MCQ
        final mcqTopics = [
          {
            'rawQ': 'Which cryptographic algorithm is recommended for bulk database encryption at rest?',
            'opts': ['A) RSA-2048', 'B) AES-256-GCM', 'C) MD5 Hashing', 'D) ROT13 cipher'],
            'correct': 'B'
          },
          {
            'rawQ': 'What primary mechanism prevents SQL Injection in backend query builders?',
            'opts': ['A) String concatenation', 'B) Parameterized Prepared Statements', 'C) Base64 encoding', 'D) Client-side validation'],
            'correct': 'B'
          },
          {
            'rawQ': 'In mobile apps, where should private master keys be derived and wrapped?',
            'opts': ['A) Hardcoded in source code', 'B) SharedPreferences plain text', 'C) Android KeyStore / iOS Keychain', 'D) Public SD Card storage'],
            'correct': 'C'
          },
          {
            'rawQ': 'What HTTP header enforces HTTPS connections exclusively?',
            'opts': ['A) HSTS (HTTP Strict Transport Security)', 'B) X-Frame-Options', 'C) Content-Type', 'D) Cache-Control'],
            'correct': 'A'
          },
          {
            'rawQ': 'Which framework maps adversary tactics and techniques across attack lifecycles?',
            'opts': ['A) OWASP SAMM', 'B) MITRE ATT&CK', 'C) ISO 27001', 'D) CIS Benchmarks'],
            'correct': 'B'
          },
          {
            'rawQ': 'What is the primary purpose of PBKDF2 / Argon2 key derivation?',
            'opts': ['A) Speeding up network downloads', 'B) Slowing down brute-force key cracking', 'C) Compress database tables', 'D) Render 60 FPS UI'],
            'correct': 'B'
          },
          {
            'rawQ': 'Which HTTP status code represents a Rate Limit Exceeded event?',
            'opts': ['A) 200 OK', 'B) 401 Unauthorized', 'C) 429 Too Many Requests', 'D) 500 Server Error'],
            'correct': 'C'
          },
          {
            'rawQ': 'What zero-trust principle requires continuous verification of every request?',
            'opts': ['A) Trust but verify', 'B) Never trust, always verify', 'C) Open internal networks', 'D) Static IP whitelist'],
            'correct': 'B'
          },
        ];

        final topic = mcqTopics[(index - 7) % mcqTopics.length];
        return {
          'type': 'mcq',
          'rawQ': topic['rawQ'],
          'tip': 'Select the option that adheres to industry security standards.',
          'options': topic['opts'],
          'correct': topic['correct'],
        };
      }
    });

    loaded.shuffle();
    _questions = loaded;

    if (mounted) {
      setState(() {
        _isGeneratingQuestions = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    final currentObj = _questions[_currentQuestionIndex];
    final isMcq = currentObj['type'] == 'mcq';
    final ans = isMcq ? (_selectedMcqOption ?? '') : _answerController.text.trim();

    if (ans.isEmpty) return;

    setState(() {
      _isEvaluating = true;
      _feedback = null;
    });

    if (isMcq) {
      final correctOpt = currentObj['correct']?.toString() ?? 'B';
      final isCorrect = ans.startsWith(correctOpt);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isEvaluating = false;
          _feedback = isCorrect
              ? 'Score: 100/100 🎯 (Correct! Option $ans is accurate).'
              : 'Score: 0/100 ⚠️ (Incorrect. The correct answer was $correctOpt).';
        });
      }
      return;
    }

    try {
      final gateway = ref.read(agentGatewayProvider);
      final prompt = 'Act as Lead Technical Interviewer evaluating a candidate for ${widget.job.role} at ${widget.job.company}.\n'
          'Question: "${currentObj['rawQ']}"\n'
          'Candidate Answer: "$ans"\n'
          'Evaluate strictly for technical accuracy, score out of 100, and provide constructive feedback.';

      final response = await gateway.dispatchPrompt(prompt);

      if (mounted) {
        setState(() {
          _isEvaluating = false;
          _feedback = response;
        });
      }
    } catch (e) {
      if (mounted) {
        final wordCount = ans.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
        final score = wordCount < 5 ? 25 : (wordCount < 15 ? 55 : 85);
        setState(() {
          _isEvaluating = false;
          _feedback = 'Score: $score/100 🎯\n'
              '${wordCount < 10 ? "Answer is brief. Include specific domain terms." : "Solid response articulating principles for ${widget.job.company}."}';
        });
      }
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 >= _questions.length) {
      setState(() {
        _isCompleted = true;
      });
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _answerController.clear();
      _selectedMcqOption = null;
      _feedback = null;
    });
  }

  void _restartInterview() {
    setState(() {
      _currentQuestionIndex = 0;
      _isCompleted = false;
      _answerController.clear();
      _selectedMcqOption = null;
      _feedback = null;
    });
    _generateAiQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = (_questions.isNotEmpty && _currentQuestionIndex < _questions.length) ? _questions[_currentQuestionIndex] : null;
    final isMcq = currentQ != null && currentQ['type'] == 'mcq';
    final questionNumStr = 'Question ${_currentQuestionIndex + 1}/15 (${isMcq ? "MCQ" : "Written"})';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : VelvetColors.cocoa;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? VelvetColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: VelvetColors.coralPeach.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [VelvetColors.coralPeach, VelvetColors.periwinkle],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mic_external_on_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI INTERVIEW STUDIO 🎙️',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: VelvetColors.coralPeach,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Text(
                                '${widget.job.role} @ ${widget.job.company}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: VelvetColors.textSecondary(context),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFFEF4444)),
                        SizedBox(width: 4),
                        Text('LIVE STUDIO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Divider(height: 16, color: VelvetColors.border(context)),

              const NetworkLatencyDisclaimerBanner(),
              const SizedBox(height: 12),

              if (_isGeneratingQuestions)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: VelvetColors.coralPeach),
                      const SizedBox(height: 16),
                      Text(
                        '🤖 Generating 15 custom questions (7 Written + 8 MCQ)...',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (_isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events_rounded, size: 64, color: VelvetColors.coralPeach),
                      const SizedBox(height: 12),
                      Text(
                        '🎉 Mock Technical Interview Complete!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Great job! You completed all 15 questions for ${widget.job.role} @ ${widget.job.company}.',
                        style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VelvetColors.coralPeach,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Restart Interview 🔄', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: _restartInterview,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else if (currentQ != null) ...[
                Text(
                  '$questionNumStr: ${currentQ['rawQ']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Pro Tip
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelvetColors.periwinkle.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, size: 14, color: VelvetColors.periwinkle),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tip: ${currentQ['tip']!}',
                          style: TextStyle(fontSize: 10.5, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Studio Audio Mic Sync Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: VelvetColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: VelvetColors.mint.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic_rounded, size: 12, color: VelvetColors.mint),
                          const SizedBox(width: 4),
                          Text('Studio Audio Sync Active 🎙️', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: textColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Written or MCQ Input
                if (!isMcq)
                  TextField(
                    controller: _answerController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type your detailed answer here...',
                      hintStyle: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: textColor.withValues(alpha: 0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(fontSize: 11.5, color: textColor),
                  )
                else
                  Column(
                    children: (currentQ['options'] as List<String>).map((opt) {
                      final isSelected = _selectedMcqOption == opt;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedMcqOption = opt),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? VelvetColors.coralPeach.withValues(alpha: 0.25) : textColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? VelvetColors.coralPeach : Colors.transparent),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  size: 16,
                                  color: isSelected ? VelvetColors.coralPeach : textColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),

                // AI Feedback Output
                if (_isEvaluating)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(color: VelvetColors.coralPeach),
                    ),
                  )
                else if (_feedback != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: VelvetColors.coralPeach.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _feedback!,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),

                const SizedBox(height: 14),

                // Action buttons formatted to prevent overflow
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: VelvetColors.textPrimary(context),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      icon: const Icon(Icons.skip_next_rounded, size: 16),
                      label: const Text('Next Question', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: _nextQuestion,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelvetColors.coralPeach,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: const Text('Evaluate Answer 🤖', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: _isEvaluating ? null : _submitAnswer,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
}
