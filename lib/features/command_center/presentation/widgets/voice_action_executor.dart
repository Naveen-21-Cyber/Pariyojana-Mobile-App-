import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/theme/velvet_colors.dart';
import '../../../../core/database/database.dart';
import '../../../../shared_widgets/glass_snackbar.dart';

class VoiceActionExecutorSheet extends ConsumerStatefulWidget {
  const VoiceActionExecutorSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const VoiceActionExecutorSheet(),
    );
  }

  @override
  ConsumerState<VoiceActionExecutorSheet> createState() =>
      _VoiceActionExecutorSheetState();
}

class _VoiceActionExecutorSheetState
    extends ConsumerState<VoiceActionExecutorSheet>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';
  String _parsedAction = 'Tap the mic below to start voice AI...';
  bool _isExecuting = false;
  bool _isInitialising = false;

  // ── 5 independent equalizer bar controllers ────────────────────────────
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;

  static const List<int> _barDurations = [300, 480, 360, 540, 320];
  static const List<int> _barDelays    = [  0, 120, 240,  60, 180];
  static const List<double> _barMinH   = [ 6.0,  5.0,  8.0,  6.0,  7.0];
  static const List<double> _barMaxH   = [48.0, 52.0, 44.0, 56.0, 46.0];

  @override
  void initState() {
    super.initState();
    _barControllers = List.generate(5, (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _barDurations[i]),
    ));
    _barAnimations = List.generate(5, (i) =>
      Tween<double>(begin: _barMinH[i], end: _barMaxH[i]).animate(
        CurvedAnimation(parent: _barControllers[i], curve: Curves.easeInOut),
      ),
    );
  }

  void _startBarAnimations() {
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: _barDelays[i]), () {
        if (mounted) _barControllers[i].repeat(reverse: true);
      });
    }
  }

  void _stopBarAnimations() {
    for (final c in _barControllers) {
      c.stop();
      c.animateBack(0.0, duration: const Duration(milliseconds: 250));
    }
  }

  Future<void> _startVoiceListening() async {
    if (_isInitialising) return;
    setState(() => _isInitialising = true);

    final status = await Permission.microphone.request();
    if (!mounted) return;

    if (!status.isGranted) {
      setState(() => _isInitialising = false);
      GlassSnackBar.show(context, '⚠️ Microphone permission is required!');
      return;
    }

    bool available = false;
    try {
      available = await _speech.initialize(
        onError: (e) {
          if (mounted) {
            setState(() { _isListening = false; _isInitialising = false; });
            _stopBarAnimations();
          }
        },
      );
    } catch (_) {
      available = false;
    }

    if (!mounted) return;

    if (!available) {
      setState(() => _isInitialising = false);
      GlassSnackBar.show(context, '⚠️ Speech recognition not available on this device.');
      return;
    }

    setState(() {
      _isListening = true;
      _isInitialising = false;
      _parsedAction = 'Listening... say a command 🎙️';
    });

    _startBarAnimations();

    try {
      if (await Vibration.hasVibrator() == true) {
        unawaited(Vibration.vibrate(duration: 30));
      }
    } catch (_) {}

    unawaited(_speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _spokenText = result.recognizedWords;
            _analyzeIntent(_spokenText);
          });
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      ),
    ));
  }

  void _stopVoiceListening() {
    unawaited(_speech.stop());
    _stopBarAnimations();
    if (mounted) {
      setState(() {
        _isListening = false;
        _isInitialising = false;
        if (_spokenText.isEmpty) {
          _parsedAction = 'Tap the mic below to start voice AI...';
        }
      });
    }
  }

  Future<void> _handleMicTap() async {
    if (_isListening) {
      _stopVoiceListening();
    } else {
      await _startVoiceListening();
    }
  }

  void _analyzeIntent(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('create project') || lower.contains('new project')) {
      final name = text.replaceAll(RegExp(r'(create|new|project)', caseSensitive: false), '').trim();
      _parsedAction = '🚀 Action: Create Project "${name.isEmpty ? "New Venture" : name}"';
    } else if (lower.contains('save idea') || lower.contains('new idea') || lower.contains('quick idea')) {
      final idea = text.replaceAll(RegExp(r'(save|new|quick|idea)', caseSensitive: false), '').trim();
      _parsedAction = '💡 Action: Save Idea "${idea.isEmpty ? "Voice Capture" : idea}"';
    } else if (lower.contains('search') || lower.contains('find')) {
      final query = text.replaceAll(RegExp(r'(search|find)', caseSensitive: false), '').trim();
      _parsedAction = '🔍 Action: Search Workspace for "$query"';
    } else if (lower.contains('job') || lower.contains('resume')) {
      _parsedAction = '💼 Action: Open Job Applications & Resume Builder';
    } else if (lower.contains('research') || lower.contains('paper')) {
      _parsedAction = '📚 Action: Open Research Tracker';
    } else {
      _parsedAction = '🔎 Try: "Create project Security Vault" or "Save idea OAuth2"';
    }
  }

  Future<void> _executeVoiceAction() async {
    if (_spokenText.isEmpty) return;
    setState(() => _isExecuting = true);

    try {
      if (await Vibration.hasVibrator() == true) unawaited(Vibration.vibrate(duration: 40));
    } catch (_) {}

    final lower = _spokenText.toLowerCase();
    final db = ref.read(databaseProvider);

    if (lower.contains('create project') || lower.contains('new project')) {
      final name = _spokenText.replaceAll(RegExp(r'(create|new|project)', caseSensitive: false), '').trim();
      final projectName = name.isEmpty ? 'New Voice Project' : name;
      await db.into(db.projects).insert(
        ProjectsCompanion.insert(
          name: projectName,
          priority: 'HIGH',
          description: const Value('Created via Voice AI Action Execution'),
          status: 'BACKLOG',
          techStack: const Value('Flutter, SQLCipher'),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      GlassSnackBar.show(context, '🚀 Project "$projectName" created!');
      unawaited(GoRouter.of(context).push('/projects'));
    } else if (lower.contains('save idea') || lower.contains('new idea') || lower.contains('quick idea')) {
      final ideaText = _spokenText.replaceAll(RegExp(r'(save|new|quick|idea)', caseSensitive: false), '').trim();
      final ideaContent = ideaText.isEmpty ? 'Voice captured idea' : ideaText;
      await db.into(db.ideas).insert(IdeasCompanion.insert(content: ideaContent, category: 'Voice AI Triage'));
      if (!mounted) return;
      Navigator.of(context).pop();
      GlassSnackBar.show(context, '💡 Idea saved to vault!');
      unawaited(GoRouter.of(context).push('/ideas'));
    } else if (lower.contains('job') || lower.contains('resume')) {
      if (!mounted) return;
      Navigator.of(context).pop();
      unawaited(GoRouter.of(context).push('/jobs'));
    } else if (lower.contains('research') || lower.contains('paper')) {
      if (!mounted) return;
      Navigator.of(context).pop();
      unawaited(GoRouter.of(context).push('/research'));
    } else {
      if (!mounted) return;
      Navigator.of(context).pop();
      GlassSnackBar.show(context, '🎙️ Voice command: "$_spokenText"');
    }
  }

  @override
  void dispose() {
    unawaited(_speech.stop());
    for (final c in _barControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VelvetColors.cream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq_rounded, color: VelvetColors.coralPeach, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Voice AI Action Hub 🎙️',
                    style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: VelvetColors.cocoa),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Listening Mode Toggle Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isListening
                  ? VelvetColors.coralPeach.withValues(alpha: 0.1)
                  : VelvetColors.periwinkle.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isListening
                    ? VelvetColors.coralPeach.withValues(alpha: 0.4)
                    : VelvetColors.periwinkle.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                      color: _isListening ? VelvetColors.coralPeach : VelvetColors.cocoa,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isListening ? 'Voice AI Listening...' : 'Mic Ready',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _isListening ? VelvetColors.coralPeach : VelvetColors.cocoa,
                          ),
                        ),
                        Text(
                          _isListening ? 'Speak your command naturally' : 'Tap mic below to speak',
                          style: const TextStyle(fontSize: 10.5, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _isListening,
                  activeTrackColor: VelvetColors.coralPeach,
                  onChanged: _isInitialising
                      ? null
                      : (val) {
                          if (val) {
                            unawaited(_startVoiceListening());
                          } else {
                            _stopVoiceListening();
                          }
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),


          // ── Explicit ON / OFF Action Buttons ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? VelvetColors.coralPeach : VelvetColors.periwinkle,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isListening || _isInitialising ? null : () => unawaited(_startVoiceListening()),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    'START (ON)',
                    style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: !_isListening ? null : _stopVoiceListening,
                  icon: const Icon(Icons.stop_rounded, size: 20),
                  label: Text(
                    'STOP (OFF)',
                    style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

            // ── Central Mic Touch Sphere ─────────────────────────────────────
            ElevatedButton(
              onPressed: _isInitialising ? null : _handleMicTap,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: _isListening
                    ? VelvetColors.coralPeach
                    : VelvetColors.periwinkle,
                disabledBackgroundColor: VelvetColors.clayTan,
                padding: const EdgeInsets.all(20),
                elevation: _isListening ? 12 : 4,
                shadowColor: (_isListening
                    ? VelvetColors.coralPeach
                    : VelvetColors.periwinkle)
                    .withValues(alpha: 0.55),
              ),
              child: _isInitialising
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
            ),
            const SizedBox(height: 6),

            // ── Tap hint ────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isInitialising
                    ? 'Initialising...'
                    : (_isListening ? '● Voice active — Listening' : 'Voice inactive — Tap ON or mic to start'),
                key: ValueKey(_isListening || _isInitialising),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: _isListening
                      ? VelvetColors.coralPeach
                      : VelvetColors.cocoa.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 5-Bar Waving Equalizer ───────────────────────────────
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (i) {
                  final colors = [
                    VelvetColors.coralPeach,
                    VelvetColors.periwinkle,
                    VelvetColors.coralPeach,
                    VelvetColors.periwinkle,
                    VelvetColors.coralPeach,
                  ];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: AnimatedBuilder(
                      animation: _barControllers[i],
                      builder: (_, __) {
                        final h = _isListening
                            ? _barAnimations[i].value
                            : _barMinH[i];
                        return Container(
                          width: 10,
                          height: h.clamp(_barMinH[i], _barMaxH[i]),
                          decoration: BoxDecoration(
                            color: colors[i],
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: _isListening
                                ? [BoxShadow(color: colors[i].withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)]
                                : [],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ── Spoken text ─────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _spokenText.isEmpty
                    ? (_isListening ? 'Speak now...' : 'Say a command out loud...')
                    : '"$_spokenText"',
                key: ValueKey(_spokenText),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VelvetColors.cocoa,
                  fontStyle: _spokenText.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            // ── Parsed action badge ─────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: VelvetColors.periwinkle.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _parsedAction,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: VelvetColors.cocoa,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // ── Execute button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelvetColors.coralPeach,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _spokenText.isEmpty || _isExecuting ? null : _executeVoiceAction,
                icon: _isExecuting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.bolt),
                label: Text(
                  _isExecuting ? 'Executing Action...' : 'Execute Voice Command ⚡',
                  style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
