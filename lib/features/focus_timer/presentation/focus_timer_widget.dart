import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/velvet_colors.dart';
import 'package:velvet/core/sounds/sound_service.dart';
import '../../../shared_widgets/clay_card.dart';

final focusTimerMinutesProvider = StateProvider<int>((ref) => 25);

class FocusTimerWidget extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectTitle;
  const FocusTimerWidget({super.key, this.projectId, this.projectTitle});

  @override
  ConsumerState<FocusTimerWidget> createState() => _FocusTimerWidgetState();
}

class _FocusTimerWidgetState extends ConsumerState<FocusTimerWidget> {
  Timer? _timer;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  bool _isCollapsed = true;
  bool _isCustomTime = false;
  int _completedSessions = 0;
  int _shlokaIndex = 0;
  final TextEditingController _customCtrl = TextEditingController();

  static const List<Map<String, String>> _gitaShlokas = [
    {'s': 'योगः कर्मसु कौशलम्', 'e': 'Excellence in action is true Yoga. — BG 2.50'},
    {'s': 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन', 'e': 'You have a right to perform your duty, but never to its fruits. — BG 2.47'},
    {'s': 'उद्धरेदात्मनात्मानं नात्मानमवसादयेत्', 'e': 'Elevate yourself by your own mind; do not degrade yourself. — BG 6.5'},
    {'s': 'हतो वा प्राप्स्यसि स्वर्गं जित्वा वा भोक्ष्यसे महीम्', 'e': 'Either slain you reach heaven, or victorious you enjoy the earth. — BG 2.37'},
    {'s': 'यद्यदाचरति श्रेष्ठस्तत्तदेवेतरो जनः', 'e': 'Whatever action a leader performs, others follow. Set the standard! — BG 3.21'},
    {'s': 'युक्तः कर्मफलं त्यक्त्वा शान्तिमामोति नैष्ठिकीम्', 'e': 'The focused worker abandons attachment to results and attains peace. — BG 5.12'},
    {'s': 'युक्ताहारविहारस्य युक्तचेष्टस्य कर्मसु', 'e': 'Moderation in food, work, sleep and wakefulness removes all sorrow. — BG 6.17'},
    {'s': 'नैनं छिन्दन्ति शस्त्राणि नैनं दहति पावकः', 'e': 'The soul is unbreakable. Stay resilient in your mission. — BG 2.23'},
    {'s': 'काङ्क्षन्तः कर्मणां सिद्धिं यजन्त इह देवताः', 'e': 'Longing for completion, act with unwavering dedication. — BG 4.12'},
    {'s': 'तेषां सततयुक्तानां भजतां प्रीतिपूर्वकम्', 'e': 'To those ever devoted to focused action, wisdom is granted. — BG 10.10'},
    {'s': 'निःश्रेयसकरावुभौ तयोस्तु कर्मसंन्यासात्कर्मयोगो विशिष्यते', 'e': 'Work in devotion is superior to passive contemplation. — BG 5.2'},
    {'s': 'अशोच्यानन्वशोचस्त्वं प्रज्ञावादांश्च भाषसे', 'e': 'Do not grieve over what is past; press forward with wisdom. — BG 2.11'},
    {'s': 'मन्मना भव मद्भक्तो मद्याजी मां नमस्कुरु', 'e': 'Fix your mind with steady determination on your purpose. — BG 18.65'},
    {'s': 'विद्याविनयसंपन्ने ब्राह्मणे गवि हस्तिनि', 'e': 'The wise look upon all with equal vision and serene intellect. — BG 5.18'},
    {'s': 'सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज', 'e': 'Surrender doubt and step forward courageously without fear. — BG 18.66'},
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = ref.read(focusTimerMinutesProvider) * 60;
    _shuffleShloka();
  }

  void _shuffleShloka() {
    setState(() {
      _shlokaIndex = Random.secure().nextInt(_gitaShlokas.length);
    });
  }

  void _updateDuration(int mins) {
    if (_isRunning) return;
    ref.read(focusTimerMinutesProvider.notifier).state = mins;
    setState(() {
      _remainingSeconds = mins * 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _customCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _shuffleShloka();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _shuffleShloka();
    final mins = ref.read(focusTimerMinutesProvider);
    setState(() {
      _isRunning = false;
      _remainingSeconds = mins * 60;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _shuffleShloka();
    ref.read(soundServiceProvider).playSuccess();
    setState(() {
      _isRunning = false;
      if (!_isBreak) {
        _completedSessions++;
        _isBreak = true;
        _remainingSeconds = 5 * 60;
      } else {
        _isBreak = false;
        _remainingSeconds = ref.read(focusTimerMinutesProvider) * 60;
      }
    });
  }

  String get _timeString {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalMins = _isBreak ? 5 : ref.watch(focusTimerMinutesProvider);
    final progress = (totalMins * 60 - _remainingSeconds) / (totalMins * 60);
    final shloka = _gitaShlokas[_shlokaIndex];

    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Header Row with Collapse Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_isBreak ? Icons.free_breakfast_outlined : Icons.timer_outlined, color: VelvetColors.coralPeach, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isBreak ? 'Short Break ☕' : 'Focus Session 🎯 (${ref.watch(focusTimerMinutesProvider)}m)',
                    style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily, fontWeight: FontWeight.bold, fontSize: 13.5, color: VelvetColors.textPrimary(context)),
                  ),
                ],
              ),
              Row(
                children: [
                  Chip(
                    padding: EdgeInsets.zero,
                    label: Text('$_completedSessions •  Done', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                    backgroundColor: VelvetColors.mint.withValues(alpha: 0.2),
                  ),
                  IconButton(
                    icon: Icon(_isCollapsed ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: VelvetColors.coralPeach),
                    onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                    tooltip: _isCollapsed ? 'Expand Focus Timer' : 'Collapse Focus Timer',
                  ),
                ],
              ),
            ],
          ),

          if (!_isCollapsed) ...[
            if (widget.projectTitle != null) ...[
              const SizedBox(height: 2),
              Text('Target: ${widget.projectTitle}', style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context), fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 10),

            // Duration Selector Chips & Stepper (when not running)
            if (!_isRunning && !_isBreak) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Set: ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  ...[15, 25, 45, 60].map((m) {
                    final isSel = totalMins == m && !_isCustomTime;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ChoiceChip(
                        label: Text('${m}m', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : VelvetColors.textPrimary(context))),
                        selected: isSel,
                        selectedColor: VelvetColors.coralPeach,
                        backgroundColor: VelvetColors.surface(context),
                        padding: EdgeInsets.zero,
                        onSelected: (_) {
                          _isCustomTime = false;
                          _customCtrl.clear();
                          _updateDuration(m);
                        },
                      ),
                    );
                  }),
                  const SizedBox(width: 6),
                  // Custom time input
                  SizedBox(
                    width: 52,
                    height: 32,
                    child: TextField(
                      controller: _customCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '?m',
                        hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _isCustomTime ? VelvetColors.coralPeach : VelvetColors.clayTan,
                            width: _isCustomTime ? 2 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2),
                        ),
                      ),
                      onSubmitted: (val) {
                        final mins = int.tryParse(val.trim()) ?? 0;
                        if (mins >= 1 && mins <= 180) {
                          setState(() => _isCustomTime = true);
                          _updateDuration(mins);
                        }
                      },
                      onChanged: (val) {
                        final mins = int.tryParse(val.trim()) ?? 0;
                        if (mins >= 1 && mins <= 180) {
                          setState(() => _isCustomTime = true);
                          _updateDuration(mins);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Gita Shloka Banner
            GestureDetector(
              onTap: _shuffleShloka,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Text('📜', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shloka['s']!, style: TextStyle(fontFamily: GoogleFonts.notoSans().fontFamily, fontWeight: FontWeight.bold, fontSize: 11.5, color: VelvetColors.textPrimary(context))),
                          Text(shloka['e']!, style: TextStyle(fontSize: 9.5, fontStyle: FontStyle.italic, color: VelvetColors.textSecondary(context))),
                        ],
                      ),
                    ),
                    const Icon(Icons.shuffle_rounded, size: 14, color: VelvetColors.coralPeach),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Timer Dial
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110, height: 110,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 7,
                    backgroundColor: VelvetColors.border(context),
                    color: _isBreak ? VelvetColors.mint : VelvetColors.coralPeach,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timeString,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.jetBrainsMono().fontFamily, color: VelvetColors.textPrimary(context)),
                    ),
                    Text(_isBreak ? 'RELAX' : 'FOCUS (${ref.watch(focusTimerMinutesProvider)}M)', style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: VelvetColors.textSecondary(context))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: IconButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 12),
                IconButton.outlined(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
