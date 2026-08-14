import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'biometric_vault_screen.dart';
import 'package:flutter/services.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velvet/features/presentation/navigation_shell.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../presentation/providers/idea_provider.dart';
import '../../../project_tracker/presentation/providers/project_provider.dart';
import 'package:velvet/features/ai_agents/domain/agents.dart';
import '../../../../core/i18n/app_translation.dart';
import '../../../../core/security/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/security/credential_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/notifications/notification_service.dart';


class IdeaVaultScreen extends ConsumerStatefulWidget {
  const IdeaVaultScreen({super.key});

  @override
  ConsumerState<IdeaVaultScreen> createState() => _IdeaVaultScreenState();
}

class _IdeaVaultScreenState extends ConsumerState<IdeaVaultScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedCategory = 'General';
  final List<String> _categories = ['General', 'Project', 'Research', 'Job'];
  bool _isTriaging = false;
  String? _attachedImagePath;

  List<int> _secureIdeaIds = [];

  @override
  void initState() {
    super.initState();
    _loadSecureIds();
  }

  Future<void> _loadSecureIds() async {
    final secureIds = await ref.read(secureStorageProvider).getSecureIdeaIds();
    if (mounted) {
      setState(() {
        _secureIdeaIds = secureIds;
      });
    }
  }

  Future<void> _lockIdea(Idea idea) async {
    await ref.read(secureStorageProvider).setIdeaSecure(idea.id, true);
    await _loadSecureIds();
    if (mounted) {
      GlassSnackBar.show(context, 'Idea locked in secure vault 🔒');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _captureIdea() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _attachedImagePath == null) return;

    final String fullContent;
    if (_attachedImagePath != null) {
      fullContent = '[Attachment: $_attachedImagePath] $text'.trim();
    } else {
      fullContent = text;
    }

    // Security Guardrail: Scan for exposed API keys & credentials
    final hasSecret = CredentialScanner.scanAndAlert(context, fullContent, fieldName: 'Idea Note');
    if (hasSecret) return;

    final companion = IdeasCompanion.insert(
      content: fullContent,
      category: _selectedCategory,
    );

    await ref.read(ideaRepositoryProvider).insertIdea(companion);
    _textController.clear();
    setState(() {
      _attachedImagePath = null;
      _selectedCategory = 'General';
    });
  }

  Future<void> _pickImageAttachment(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: source);
      if (photo != null && mounted) {
        await HapticFeedback.mediumImpact();
        setState(() {
          _attachedImagePath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        GlassSnackBar.show(context, 'Unable to pick image: $e');
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: VelvetColors.cardSurface(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Attach Snapshot or Photo 📷',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: VelvetColors.textPrimary(ctx)),
              ),
              const SizedBox(height: 8),
              Text(
                'Capture a quick camera snapshot or select a photo from your gallery.',
                style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(ctx)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                  label: const Text(
                    'Take Snapshot with Camera 📸',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    _pickImageAttachment(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.periwinkle,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.photo_library_rounded, size: 20, color: Colors.white),
                  label: const Text(
                    'Choose from Photo Gallery 🖼️',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    _pickImageAttachment(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _autoTriageIdea() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      if (context.mounted) {
        GlassSnackBar.show(context, 'Please type a quick idea first to auto-triage! 💡');
      }
      return;
    }

    setState(() {
      _isTriaging = true;
    });

    try {
      final triageAgent = ref.read(triageAgentProvider);
      final result = await triageAgent.triage(text);

      if (mounted) {
        setState(() {
          _selectedCategory = result.category;
          if (result.tags.isNotEmpty) {
            // Append tags to prompt text field if not already present
            final tagsStr = result.tags.map((t) => '#$t').join(' ');
            if (!text.contains('#')) {
              _textController.text = '$text $tagsStr';
            }
          }
        });
        if (context.mounted) {
          GlassSnackBar.show(context, 'Auto-triaged to category: ${result.category} 🤖');
        }
      }
    } catch (e) {
      if (mounted) {
        if (context.mounted) {
          GlassSnackBar.show(context, 'Triage failed: $e ⚠️');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTriaging = false;
        });
      }
    }
  }


  Future<void> _showVoiceRecordingSheet() async {
    try {
      if (await Vibration.hasVibrator() == true) {
        unawaited(Vibration.vibrate(duration: 60, amplitude: 255));
      }
    } catch (_) {}

    if (!mounted) return;

    final status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        GlassSnackBar.show(context, '⚠️ Microphone permission is required to record voice notes.');
      }
      return;
    }

    final stt.SpeechToText speech = stt.SpeechToText();
    bool available = await speech.initialize();
    String liveText = 'Listening... Speak into your microphone 🎙️';

    if (mounted) {
      GlassSnackBar.show(context, '🎙️ System Microphone Active & Listening!');
    }

    bool isListening = true;

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          void toggleVoice(bool turnOn) {
            setModalState(() {
              isListening = turnOn;
            });
            if (turnOn) {
              if (available && !speech.isListening) {
                unawaited(speech.listen(
                  onResult: (val) {
                    setModalState(() {
                      liveText = val.recognizedWords;
                    });
                  },
                ));
              }
            } else {
              unawaited(speech.stop());
            }
          }

          if (available && !speech.isListening && isListening) {
            unawaited(speech.listen(
              onResult: (val) {
                setModalState(() {
                  liveText = val.recognizedWords;
                });
              },
            ));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VelvetColors.surface(context),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: VelvetColors.border(context), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: VelvetColors.coralPeach.withValues(alpha: 0.4),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.mic_rounded, size: 28, color: VelvetColors.coralPeach),
                          const SizedBox(width: 8),
                          Text(
                            'Live Voice Recognition 🎙️',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(ctx)),
                          ),
                        ]),
                        IconButton(
                          icon: Icon(Icons.close, color: VelvetColors.iconColor(ctx)),
                          onPressed: () {
                            unawaited(speech.stop());
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Master ON / OFF Switch Bar ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isListening
                            ? VelvetColors.coralPeach.withValues(alpha: 0.12)
                            : VelvetColors.clayTan.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isListening ? VelvetColors.coralPeach : VelvetColors.cocoa.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isListening ? const Color(0xFF2ECC71) : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isListening ? 'VOICE AI: ON 🟢' : 'VOICE AI: OFF 🔴',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(ctx)),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: isListening,
                            activeTrackColor: VelvetColors.coralPeach,
                            onChanged: (val) => toggleVoice(val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── START / STOP Buttons ────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isListening ? VelvetColors.coralPeach : VelvetColors.periwinkle,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isListening ? null : () => toggleVoice(true),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text('START (ON)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: !isListening ? null : () => toggleVoice(false),
                            icon: const Icon(Icons.stop_rounded, size: 18),
                            label: const Text('STOP (OFF)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Pulsing Soundwave Icon Indicator
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening ? VelvetColors.coralPeach.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                        border: Border.all(color: isListening ? VelvetColors.coralPeach : Colors.grey, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          isListening ? Icons.graphic_eq_rounded : Icons.mic_off_rounded,
                          size: 28,
                          color: isListening ? VelvetColors.coralPeach : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VelvetColors.periwinkle.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        liveText.isEmpty ? '🎙️ "Optimize zero-trust mobile key wrapping module with AES-256 GCM encryption..."' : liveText,
                        style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: VelvetColors.cocoa),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelvetColors.coralPeach,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Save & AI Auto-Triage 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        unawaited(speech.stop());
                        Navigator.pop(ctx);
                        setState(() {
                          _textController.text = liveText.isEmpty || liveText.startsWith('Listening')
                              ? '🎙️ [Voice Note]: Optimize zero-trust mobile key wrapping module with AES-256 GCM encryption'
                              : '🎙️ [Voice Note]: $liveText';
                        });
                        await _autoTriageIdea();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPromoteSheet(Idea idea) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: VelvetColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: VelvetColors.border(context), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(
              'Send & Convert Idea 🚀',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
            ),
            const SizedBox(height: 4),
            Text(
              'Transfer this idea directly into your active Project or Research Paper module.',
              style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context)),
            ),
            const SizedBox(height: 16),

            ListTile(
              dense: true,
              leading: const Icon(Icons.rocket_launch_rounded, color: VelvetColors.coralPeach, size: 22),
              title: const Text('Promote to Project 🏗️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Create a new project pipeline item from this idea', style: TextStyle(fontSize: 10)),
              onTap: () {
                Navigator.pop(sheetCtx);
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _PromoteProjectSheet(idea: idea),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              dense: true,
              leading: const Icon(Icons.auto_stories_rounded, color: VelvetColors.periwinkle, size: 22),
              title: const Text('Send to Research Tracker 📄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Create a new Research Paper entry from this idea', style: TextStyle(fontSize: 10)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final db = ref.read(databaseProvider);
                await db.into(db.researchPapers).insert(ResearchPapersCompanion(
                  title: drift.Value(idea.content.split('\n').first),
                  abstractId: drift.Value(idea.content),
                  status: const drift.Value('Draft'),
                  createdAt: drift.Value(DateTime.now()),
                  updatedAt: drift.Value(DateTime.now()),
                ));
                await ref.read(ideaRepositoryProvider).updateIdea(idea.copyWith(isPromoted: true));
                if (mounted) {
                  GlassSnackBar.show(context, 'Idea sent to Research Tracker as Draft! 📄');
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showIdeaReminderSheet(Idea idea) {
    final titleController = TextEditingController(
      text: '💡 Idea Reminder: ${idea.content.split('\n').first.replaceAll(RegExp(r'^\[Attachment:.*?\]\s*'), '')}',
    );
    final bodyController = TextEditingController(
      text: 'Time to take action on your idea! Category: ${idea.category}',
    );

    int selectedPresetMinutes = 15;
    DateTime customDateTime = DateTime.now().add(const Duration(minutes: 15));
    bool isRecurringDaily = false;
    bool isCustomSelected = false;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.80,
        maxChildSize: 0.92,
        minChildSize: 0.40,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: VelvetColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: VelvetColors.coralPeach, width: 2),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: VelvetColors.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.alarm_add_rounded, color: VelvetColors.coralPeach, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Set Custom Notification Reminder 🔔',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Schedule an exact Android alarm notification for this specific thought.',
                    style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 16),

                  Text('Notification Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: VelvetColors.inputFill(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Reminder Message Notes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: bodyController,
                    style: TextStyle(fontSize: 13, color: VelvetColors.textPrimary(context)),
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: VelvetColors.inputFill(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Quick Time Delay Presets', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetChip('⚡ 15 Mins', 15, selectedPresetMinutes, isCustomSelected, (mins) {
                        setModalState(() {
                          selectedPresetMinutes = mins;
                          isCustomSelected = false;
                          customDateTime = DateTime.now().add(Duration(minutes: mins));
                        });
                      }),
                      _buildPresetChip('🕒 1 Hour', 60, selectedPresetMinutes, isCustomSelected, (mins) {
                        setModalState(() {
                          selectedPresetMinutes = mins;
                          isCustomSelected = false;
                          customDateTime = DateTime.now().add(Duration(minutes: mins));
                        });
                      }),
                      _buildPresetChip('🌙 3 Hours', 180, selectedPresetMinutes, isCustomSelected, (mins) {
                        setModalState(() {
                          selectedPresetMinutes = mins;
                          isCustomSelected = false;
                          customDateTime = DateTime.now().add(Duration(minutes: mins));
                        });
                      }),
                      _buildPresetChip('🌅 12 Hours', 720, selectedPresetMinutes, isCustomSelected, (mins) {
                        setModalState(() {
                          selectedPresetMinutes = mins;
                          isCustomSelected = false;
                          customDateTime = DateTime.now().add(Duration(minutes: mins));
                        });
                      }),
                      _buildPresetChip('📅 24 Hours', 1440, selectedPresetMinutes, isCustomSelected, (mins) {
                        setModalState(() {
                          selectedPresetMinutes = mins;
                          isCustomSelected = false;
                          customDateTime = DateTime.now().add(Duration(minutes: mins));
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VelvetColors.textPrimary(context),
                      side: BorderSide(color: isCustomSelected ? VelvetColors.coralPeach : VelvetColors.border(context), width: isCustomSelected ? 2 : 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: VelvetColors.coralPeach),
                    label: Text(
                      isCustomSelected
                          ? 'Scheduled: ${DateFormat('EEE, MMM d • h:mm a').format(customDateTime)}'
                          : 'Pick Custom Date & Exact Time 🕒',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: customDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null && context.mounted) {
                        // Custom time picker — avoids Flutter's minutes 2nd-digit bug
                        final pickedTime = await _showCustomTimePicker(
                          context,
                          TimeOfDay.fromDateTime(customDateTime),
                        );
                        if (pickedTime != null) {
                          setModalState(() {
                            isCustomSelected = true;
                            customDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: VelvetColors.clayTan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.repeat_rounded, size: 18, color: VelvetColors.coralPeach),
                            SizedBox(width: 8),
                            Text(
                              'Repeat Daily Reminder 🔁',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: VelvetColors.cocoa),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: isRecurringDaily,
                          activeTrackColor: VelvetColors.coralPeach,
                          onChanged: (val) => setModalState(() => isRecurringDaily = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final notifService = ref.read(notificationServiceProvider);
                            await notifService.cancelIdeaReminder(idea.id);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              GlassSnackBar.show(context, 'Reminder canceled for this idea 🛑');
                            }
                          },
                          child: const Text('Cancel Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VelvetColors.coralPeach,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.notifications_active_rounded, size: 18),
                          label: const Text('Schedule Reminder 🔔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () async {
                            final notifService = ref.read(notificationServiceProvider);
                            await notifService.scheduleIdeaReminder(
                              ideaId: idea.id,
                              title: titleController.text.trim().isEmpty ? '💡 Idea Reminder' : titleController.text.trim(),
                              body: bodyController.text.trim().isEmpty ? idea.content : bodyController.text.trim(),
                              scheduledDateTime: customDateTime,
                              isRecurring: isRecurringDaily,
                            );
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              GlassSnackBar.show(
                                context,
                                '🔔 Reminder scheduled for ${DateFormat('MMM d, h:mm a').format(customDateTime)}!',
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Custom time picker — shows hour & minute TextFields with AM/PM toggle.
  /// Avoids the Flutter system TimePicker dial/minute 2nd-digit bug.
  Future<TimeOfDay?> _showCustomTimePicker(
      BuildContext ctx, TimeOfDay initial) async {
    bool isPm = initial.hour >= 12;
    final hourCtrl = TextEditingController(
        text: (initial.hour % 12 == 0 ? 12 : initial.hour % 12).toString());
    final minCtrl = TextEditingController(
        text: initial.minute.toString().padLeft(2, '0'));

    return showDialog<TimeOfDay>(
      context: ctx,
      builder: (dlgCtx) {
        return StatefulBuilder(builder: (dlgCtx, setDlgState) {
          return AlertDialog(
            backgroundColor: VelvetColors.surface(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Set Time 🕒',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour field
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: hourCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 2,
                    autofocus: true,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'HH',
                      labelStyle: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: VelvetColors.border(context)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(':', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
                ),
                // Minute field
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: minCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 2,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'MM',
                      labelStyle: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: VelvetColors.border(context)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // AM / PM toggle
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _amPmBtn('AM', !isPm, () => setDlgState(() => isPm = false)),
                    const SizedBox(height: 6),
                    _amPmBtn('PM', isPm, () => setDlgState(() => isPm = true)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dlgCtx),
                child: Text('Cancel', style: TextStyle(color: VelvetColors.textSecondary(context))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelvetColors.coralPeach,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final h = int.tryParse(hourCtrl.text.trim()) ?? 12;
                  final m = int.tryParse(minCtrl.text.trim()) ?? 0;
                  final clampedH = h.clamp(1, 12);
                  final clampedM = m.clamp(0, 59);
                  int hour24 = isPm
                      ? (clampedH == 12 ? 12 : clampedH + 12)
                      : (clampedH == 12 ? 0 : clampedH);
                  Navigator.pop(dlgCtx, TimeOfDay(hour: hour24, minute: clampedM));
                },
                child: const Text('Set', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _amPmBtn(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? VelvetColors.coralPeach : VelvetColors.clayTan.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : VelvetColors.cocoa,
            )),
      ),
    );
  }

  Widget _buildPresetChip(String label, int mins, int selectedMins, bool isCustom, Function(int) onSelect) {
    final isSelected = !isCustom && selectedMins == mins;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : VelvetColors.cocoa,
        ),
      ),
      selected: isSelected,
      selectedColor: VelvetColors.coralPeach,
      backgroundColor: VelvetColors.surface(context),
      side: BorderSide(color: isSelected ? VelvetColors.coralPeach : VelvetColors.clayTan),
      showCheckmark: false,
      onSelected: (_) => onSelect(mins),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(quickCaptureTriggerProvider, (previous, next) {
      if (next == 0) {
        _focusNode.requestFocus();
        ref.read(quickCaptureTriggerProvider.notifier).state = null;
      }
    });

    final ideasAsync = ref.watch(ideasStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // 1. Idea Vault Title & Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TranslatedText(
                        'Idea Vault',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: VelvetColors.textPrimary(context),
                              letterSpacing: -0.5,
                            ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.lock_outline_rounded, color: VelvetColors.coralPeach, size: 20),
                            tooltip: 'Secure Vault',
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const BiometricVaultScreen(),
                                ),
                              );
                              await _loadSecureIds();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.newspaper_rounded, color: VelvetColors.iconColor(context), size: 22),
                            tooltip: 'Hacker News Feed',
                            onPressed: () => context.push('/hn'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  TranslatedText(
                    'Capture every fleeting thought before it escapes.',
                    style: TextStyle(
                      color: VelvetColors.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Quick Capture input card matching reference screenshot
                  ClayCard(
                    color: VelvetColors.cardSurface(context),
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_attachedImagePath != null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_attachedImagePath!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '📷 Attached Photo Snapshot',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VelvetColors.textPrimary(context)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _attachedImagePath!.split('/').last,
                                        style: TextStyle(fontSize: 10, color: VelvetColors.textSecondary(context)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                                  tooltip: 'Remove Attachment',
                                  onPressed: () {
                                    setState(() => _attachedImagePath = null);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: VelvetColors.inputFill(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: VelvetColors.border(context),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  style: TextStyle(
                                    color: VelvetColors.textPrimary(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: _attachedImagePath != null
                                        ? 'Add supporting notes for this photo...'
                                        : 'Type a quick idea...',
                                    hintStyle: TextStyle(
                                      color: VelvetColors.textSecondary(context).withValues(alpha: 0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onSubmitted: (_) => _captureIdea(),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _isTriaging
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: VelvetColors.periwinkle),
                                          ),
                                        )
                                      : IconButton(
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.auto_awesome, color: VelvetColors.periwinkle, size: 20),
                                          tooltip: 'Auto-Triage with AI ✨',
                                          onPressed: () async {
                                            await HapticFeedback.selectionClick();
                                            await _autoTriageIdea();
                                          },
                                        ),
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.mic_none_rounded, color: VelvetColors.coralPeach, size: 20),
                                    tooltip: 'Voice Note 🎙️',
                                    onPressed: _showVoiceRecordingSheet,
                                  ),
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      _attachedImagePath != null ? Icons.photo_size_select_actual_rounded : Icons.camera_alt_outlined,
                                      color: _attachedImagePath != null ? VelvetColors.mint : VelvetColors.iconColor(context),
                                      size: 20,
                                    ),
                                    tooltip: 'Attach Photo 📷',
                                    onPressed: _showImageSourceSheet,
                                  ),
                                  const SizedBox(width: 2),
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.send_rounded, color: VelvetColors.coralPeach, size: 20),
                                    tooltip: 'Record Idea',
                                    onPressed: () async {
                                      await HapticFeedback.heavyImpact();
                                      unawaited(_captureIdea());
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            TranslatedText(
                              'Category:',
                              style: TextStyle(
                                fontSize: 12,
                                color: VelvetColors.textSecondary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _categories.map((cat) {
                                    final isSelected = _selectedCategory == cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6.0),
                                      child: ChoiceChip(
                                        label: TranslatedText(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : VelvetColors.textPrimary(context),
                                          ),
                                        ),
                                        selected: isSelected,
                                        selectedColor: VelvetColors.coralPeach,
                                        backgroundColor: VelvetColors.chipBg(context),
                                        side: BorderSide(
                                          color: isSelected ? VelvetColors.coralPeach : VelvetColors.border(context),
                                        ),
                                        showCheckmark: false,
                                        onSelected: (val) {
                                          if (val) {
                                            setState(() => _selectedCategory = cat);
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
              ideasAsync.when(
                data: (ideas) {
                  final activeIdeas = ideas.where((i) => !i.isPromoted && !_secureIdeaIds.contains(i.id)).toList();
                  if (activeIdeas.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 140),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.amber.shade100.withValues(alpha: 0.6),
                                  VelvetColors.coralPeach.withValues(alpha: 0.1),
                                  VelvetColors.surface(context),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.amber.shade600.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.shade400.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade200,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.amber.shade700, width: 1.5),
                                  ),
                                  child: Icon(Icons.lightbulb_rounded, size: 36, color: Colors.amber.shade900),
                                ),
                                const SizedBox(height: 14),
                                TranslatedText(
                                  'No Ideas Captured Yet 💡',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: VelvetColors.textPrimary(context)),
                                ),
                                const SizedBox(height: 6),
                                TranslatedText(
                                  'Type an idea in the capture bar or use voice AI to record your first thought.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11.5, color: VelvetColors.textSecondary(context)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(bottom: 140),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final idea = activeIdeas[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Dismissible(
                              key: Key('idea_${idea.id}'),
                              background: _buildDismissBg(
                                color: VelvetColors.mint,
                                icon: Icons.rocket_launch_rounded,
                                label: 'Promote 🚀',
                                alignLeft: true,
                              ),
                              secondaryBackground: _buildDismissBg(
                                color: Colors.redAccent,
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete 🗑️',
                                alignLeft: false,
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  _showPromoteSheet(idea);
                                  return false;
                                } else {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: VelvetColors.surface(context),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: TranslatedText('Delete Idea?', style: TextStyle(color: VelvetColors.textPrimary(context), fontWeight: FontWeight.bold)),
                                      content: TranslatedText('This action will permanently purge this thought from the vault.', style: TextStyle(color: VelvetColors.textPrimary(context))),
                                      actions: [
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: VelvetColors.textPrimary(context),
                                            side: BorderSide(color: VelvetColors.border(context)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const TranslatedText('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const TranslatedText('Yes, Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ref.read(ideaRepositoryProvider).deleteIdea(idea.id);
                                    return true;
                                  }
                                  return false;
                                }
                              },
                              child: Builder(
                                builder: (context) {
                                  Color catColor;
                                  switch (idea.category) {
                                    case 'Project Idea':
                                      catColor = VelvetColors.coralPeach;
                                      break;
                                    case 'Research Thought':
                                      catColor = VelvetColors.periwinkle;
                                      break;
                                    case 'Startup / Business':
                                      catColor = const Color(0xFFF59E0B);
                                      break;
                                    case 'System / Architecture':
                                      catColor = const Color(0xFF8B5CF6);
                                      break;
                                    case 'Personal':
                                      catColor = const Color(0xFFEAB308);
                                      break;
                                    default:
                                      catColor = const Color(0xFFEAB308);
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: VelvetColors.cardSurface(context),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: catColor.withValues(alpha: 0.35),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: catColor.withValues(alpha: 0.12),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            width: 8,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [catColor, catColor.withValues(alpha: 0.7)],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(18),
                                                bottomLeft: Radius.circular(18),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: catColor.withValues(alpha: 0.15),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.lightbulb_outline, color: catColor, size: 20),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Builder(
                                                          builder: (context) {
                                                            final content = idea.content;
                                                            final hasAttachment = content.startsWith('[Attachment:');
                                                            String cleanText = content;
                                                            String? attachmentPath;

                                                            if (hasAttachment) {
                                                              final match = RegExp(r'^\[Attachment:\s*(.*?)\]\s*(.*)$', dotAll: true).firstMatch(content);
                                                              if (match != null) {
                                                                attachmentPath = match.group(1);
                                                                cleanText = match.group(2) ?? '';
                                                              }
                                                            }

                                                            return Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                if (attachmentPath != null) ...[
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    child: Image.file(
                                                                      File(attachmentPath),
                                                                      width: double.infinity,
                                                                      height: 140,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 6),
                                                                ],
                                                                if (cleanText.trim().isNotEmpty)
                                                                  Text(
                                                                    cleanText,
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: VelvetColors.textPrimary(context),
                                                                    ),
                                                                    maxLines: 4,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Wrap(
                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                          spacing: 6,
                                                          runSpacing: 4,
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                              decoration: BoxDecoration(
                                                                color: catColor.withValues(alpha: 0.15),
                                                                borderRadius: BorderRadius.circular(12),
                                                                border: Border.all(color: catColor.withValues(alpha: 0.3)),
                                                              ),
                                                              child: Text(
                                                                idea.category,
                                                                style: TextStyle(fontSize: 9.5, color: catColor, fontWeight: FontWeight.bold),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            Text(
                                                              DateFormat('yMMMd').format(idea.createdAt),
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: VelvetColors.textSecondary(context),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  IconButton(
                                                    icon: const Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 20),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                    onPressed: () => _showIdeaReminderSheet(idea),
                                                    tooltip: 'Set Custom Idea Reminder 🔔',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.lock_outline_rounded, color: VelvetColors.coralPeach, size: 20),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                    onPressed: () => _lockIdea(idea),
                                                    tooltip: 'Lock in Secure Vault',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.rocket_launch_rounded, color: VelvetColors.periwinkle, size: 20),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                    onPressed: () => _showPromoteSheet(idea),
                                                    tooltip: 'Promote to Project 🚀',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        childCount: activeIdeas.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator(color: VelvetColors.coralPeach)),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error loading ideas: $err')),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildDismissBg({
    required Color color,
    required IconData icon,
    required String label,
    required bool alignLeft,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignLeft
            ? [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]
            : [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white),
              ],
      ),
    );
  }
}

class _PromoteProjectSheet extends ConsumerStatefulWidget {
  final Idea idea;

  const _PromoteProjectSheet({required this.idea});

  @override
  ConsumerState<_PromoteProjectSheet> createState() => _PromoteProjectSheetState();
}

class _PromoteProjectSheetState extends ConsumerState<_PromoteProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _tagsController;
  late TextEditingController _driveController;
  late TextEditingController _pathController;
  
  String _selectedStatus = 'Active Development 🏗️';
  String _selectedPriority = 'Medium';
  String _selectedOs = 'Windows';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.idea.content);
    _tagsController = TextEditingController(text: widget.idea.category.toLowerCase());
    _driveController = TextEditingController(text: 'E:');
    _pathController = TextEditingController(text: '\\Projects\\');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    _driveController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _submitPromotion() async {
    if (!_formKey.currentState!.validate()) return;

    final projectCompanion = ProjectsCompanion.insert(
      name: _nameController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      tags: drift.Value(_tagsController.text.trim().isEmpty ? null : _tagsController.text.trim()),
      originIdeaId: drift.Value(widget.idea.id),
      storageOs: drift.Value(_selectedOs),
      storageDrive: drift.Value(_driveController.text.trim()),
      storagePath: drift.Value(_pathController.text.trim()),
    );

    // 1. Insert Project
    await ref.read(projectRepositoryProvider).insertProject(projectCompanion);

    // 2. Mark Idea as promoted
    final updatedIdea = widget.idea.copyWith(isPromoted: true);
    await ref.read(ideaRepositoryProvider).updateIdea(updatedIdea);

    if (mounted) {
      Navigator.of(context).pop(); // Close bottom sheet
      if (context.mounted) {
        GlassSnackBar.show(context, 'Idea promoted to Project: ${_nameController.text.trim()} 🚀');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: VelvetColors.clayTan.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: VelvetColors.cocoa.withValues(alpha: 0.20),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: VelvetColors.border(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promote to Project',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context), size: 24),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close sheet',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onPressed: _submitPromotion,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Create Project (Quick Save)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter project name' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: 'Mobile App (Android & iOS) 📱',
                  decoration: const InputDecoration(labelText: 'Application Platform Type'),
                  dropdownColor: VelvetColors.dropdownFill(context),
                  items: [
                    'Web Application 🌐',
                    'Mobile App (Android & iOS) 📱',
                    'Mobile App (Android Only) 🤖',
                    'Mobile App (iOS Only) 🍏',
                    'Desktop App (Windows/Mac/Linux) 💻',
                    'Other / API / Microservice ⚙️',
                  ]
                      .map((plat) => DropdownMenuItem(
                            value: plat,
                            child: Text(
                              plat,
                              style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 12),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _tagsController.text = _tagsController.text.isEmpty
                          ? val
                          : '${_tagsController.text}, $val';
                    }
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status / Stage'),
                        dropdownColor: VelvetColors.dropdownFill(context),
                        menuMaxHeight: 220,
                        isExpanded: true,
                        items: [
                          'Concept & Spec 💡',
                          'Active Development 🏗️',
                          'QA & Security Audit 🧪',
                          'Staging & Release 🚀',
                          'Maintained & Live ✅',
                        ]
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedStatus = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        dropdownColor: VelvetColors.dropdownFill(context),
                        menuMaxHeight: 220,
                        isExpanded: true,
                        items: ['Low', 'Medium', 'High']
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority, style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedPriority = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 16),

                Text(
                  'Storage Asset Location',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedOs,
                        decoration: const InputDecoration(labelText: 'OS'),
                        dropdownColor: VelvetColors.dropdownFill(context),
                        menuMaxHeight: 220,
                        isExpanded: true,
                        items: ['Windows', 'Linux', 'macOS', 'Cloud']
                            .map((os) => DropdownMenuItem(
                                  value: os,
                                  child: Text(os, style: TextStyle(color: VelvetColors.textPrimary(context), fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedOs = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _driveController,
                        decoration: const InputDecoration(labelText: 'Drive/Mount'),
                        style: TextStyle(color: VelvetColors.textPrimary(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _pathController,
                  decoration: const InputDecoration(labelText: 'Folder Path'),
                  style: TextStyle(color: VelvetColors.textPrimary(context)),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 140),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
