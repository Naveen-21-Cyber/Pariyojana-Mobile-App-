import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../core/providers/feature_toggles_provider.dart';

class GitaShlokaNotifier extends StateNotifier<bool> {
  final SharedPreferences? _prefs;

  GitaShlokaNotifier(this._prefs)
      : super(_prefs?.getBool('gita_shloka_startup_enabled') ?? false);

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _prefs?.setBool('gita_shloka_startup_enabled', enabled);
  }
}

final gitaShlokaEnabledProvider =
    StateNotifierProvider<GitaShlokaNotifier, bool>((ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return GitaShlokaNotifier(prefs);
  } catch (_) {
    return GitaShlokaNotifier(null);
  }
});

/// Curated authentic Bhagavad Gita shlokas shown on startup (shuffled each session).
const _kGitaShlokas = [
  GitaShloka(
    chapter: 'Subhashita • Kannada',
    sanskrit: 'ಪ್ರಯತ್ನಂ ಸರ್ವ ಸಿದ್ಧಿ ಸಾಧನಂ',
    english: '"Effort is the ultimate key to achieve all success in life."',
  ),
  GitaShloka(
    chapter: 'Subhashita • Sanskrit',
    sanskrit: 'शीघ्रतायां सत्यां केचित् दह्यन्ते, परन्तु समयेन सह अपरे श्रेष्ठाः भवन्ति।',
    english: '"When there is rush, some things burn; but with patience and time, excellence emerges."',
  ),
  GitaShloka(
    chapter: 'BG 4.7–4.8',
    sanskrit:
        'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम्॥\n\nपरित्राणाय साधूनां विनाशाय च दुष्कृताम्।\nधर्मसंस्थापनार्थाय सम्भवामि युगे युगे॥',
    english:
        '"Whenever there is a decline in righteousness and an increase in unrighteousness, O Arjuna, at that time I manifest myself. For the protection of the good, for the destruction of the wicked, and for the establishment of righteousness, I appear in every age."',
  ),
  GitaShloka(
    chapter: 'BG 2.47',
    sanskrit:
        'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
    english:
        '"You have a right to perform your prescribed duties, but you are not entitled to the results of your actions. Never consider yourself the cause of the results of your activities, and never be attached to not doing your duty."',
  ),
  GitaShloka(
    chapter: 'BG 2.20',
    sanskrit:
        'न जायते म्रियते वा कदाचि-\nन्नायं भूत्वा भविता वा न भूयः।\nअजो नित्यः शाश्वतोऽयं पुराणो\nन हन्यते हन्यमाने शरीरे॥',
    english:
        '"The soul is never born nor dies at any time. It has not come into being, does not come into being, and will not come into being. It is unborn, eternal, ever-existing, and primeval. It is not slain when the body is slain."',
  ),
  GitaShloka(
    chapter: 'BG 2.14',
    sanskrit:
        'मात्रास्पर्शास्तु कौन्तेय शीतोष्णसुखदुःखदाः।\nआगमापायिनोऽनित्यास्तांस्तितिक्षस्व भारत॥',
    english:
        '"O son of Kuntī, the nonpermanent appearance of happiness and distress, and their disappearance in due course, are like the appearance and disappearance of winter and summer seasons. They arise from sense perception, O scion of Bharata, and one must learn to tolerate them without being disturbed."',
  ),
  GitaShloka(
    chapter: 'BG 6.5',
    sanskrit:
        'उद्धरेदात्मनात्मानं नात्मानमवसादयेत्।\nआत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः॥',
    english:
        '"Let a man lift himself by his own Self alone, and let him not lower himself; for this self alone is the friend of oneself, and this self alone is the enemy of oneself."',
  ),
  GitaShloka(
    chapter: 'BG 9.22',
    sanskrit:
        'अनन्याश्चिन्तयन्तो मां ये जनाः पर्युपासते।\nतेषां नित्याभियुक्तानां योगक्षेमं वहाम्यहम्॥',
    english:
        '"But those who always worship Me with exclusive devotion, meditating on My transcendental form — to them, I carry what they lack, and I preserve what they have."',
  ),
  GitaShloka(
    chapter: 'BG 18.66',
    sanskrit:
        'सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज।\nअहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥',
    english:
        '"Abandon all varieties of dharma and simply surrender unto Me. I shall liberate you from all sinful reactions; do not fear."',
  ),
  GitaShloka(
    chapter: 'BG 4.38',
    sanskrit:
        'न हि ज्ञानेन सदृशं पवित्रमिह विद्यते।\nतत्स्वयं योगसंसिद्धः कालेनात्मनि विन्दति॥',
    english:
        '"In this world, there is nothing so sublime and pure as transcendental knowledge. Such knowledge is the mature fruit of all mysticism. And one who has become accomplished in the practice of devotional service enjoys this knowledge within himself in due course of time."',
  ),
  GitaShloka(
    chapter: 'BG 2.50',
    sanskrit:
        'बुद्धियुक्तो जहातीह उभे सुकृतदुष्कृते।\nतस्माद्योगाय युज्यस्व योगः कर्मसु कौशलम्॥',
    english:
        '"A person engaged in devotional service rids himself of both good and bad actions even in this life. Therefore, strive for Yoga, which is the art of all work."',
  ),
  GitaShloka(
    chapter: 'BG 2.70',
    sanskrit:
        'आपूर्यमाणमचलप्रतिष्ठं\nसमुद्रमापः प्रविशन्ति यद्वत्।\nतद्वत्कामा यं प्रविशन्ति सर्वे\nस शान्तिमाप्नोति न कामकामी॥',
    english:
        '"A person who is not disturbed by the incessant flow of desires — that enter like rivers into the ocean, which is ever being filled but always remains still — can alone achieve peace, and not the person who strives to satisfy such desires."',
  ),
  GitaShloka(
    chapter: 'BG 3.21',
    sanskrit:
        'यद्यदाचरति श्रेष्ठस्तत्तदेवेतरो जनः।\nस यत्प्रमाणं कुरुते लोकस्तदनुवर्तते॥',
    english:
        '"Whatever action a great man performs, common men follow. Whatever standards he sets by exemplary acts, all the world pursues."',
  ),
  GitaShloka(
    chapter: 'BG 4.24',
    sanskrit:
        'ब्रह्मार्पणं ब्रह्म हविर्ब्रह्माग्नौ ब्रह्मणा हुतम्।\nब्रह्मैव तेन गन्तव्यं ब्रह्मकर्मसमाधिना॥',
    english:
        '"A person who is fully absorbed in God consciousness is sure to attain the ultimate spiritual goal because of his complete contribution to spiritual activities."',
  ),
  GitaShloka(
    chapter: 'BG 5.18',
    sanskrit:
        'विद्याविनयसम्पन्ने ब्राह्मणे गवि हस्तिनि।\nशुनि चैव श्वपाके च पण्डिताः समदर्शिनः॥',
    english:
        '"The humble sages, by virtue of true knowledge, see with equal vision a learned and gentle brāhmaṇa, a cow, an elephant, a dog and a dog-eater."',
  ),
  GitaShloka(
    chapter: 'BG 6.6',
    sanskrit:
        'बन्धुरात्मात्मनस्तस्य येनात्मैवात्मना जितः।\nअनात्मनस्तु शत्रुत्वे वर्तेतात्मैव शत्रुवत्॥',
    english:
        '"For him who has conquered the mind, the mind is the best of friends; but for one who has failed to do so, his mind will remain the greatest enemy."',
  ),
  GitaShloka(
    chapter: 'BG 10.8',
    sanskrit:
        'अहं सर्वस्य प्रभवो मत्तः सर्वं प्रवर्तते।\nइति मत्वा भजन्ते मां बुधा भावसमन्विताः॥',
    english:
        '"I am the source of all spiritual and material worlds. Everything emanates from Me. The wise who perfectly know this engage in My devotional service and worship Me with all their hearts."',
  ),
  GitaShloka(
    chapter: 'BG 11.33',
    sanskrit:
        'तस्मात्त्वमुत्तिष्ठ यशो लभस्व\nजित्वा शत्रून्भुङ्क्ष्व राज्यं समृद्धम्।\nमयैवैते निहताः पूर्वमेव\nनिमित्तमात्रं भव सव्यसाचिन्॥',
    english:
        '"Therefore get up! Prepare to fight and win glory. Conquer your enemies and enjoy a flourishing kingdom. They are already slain by My dispensation, and you, O Savyasācin, can be but an instrument in the fight."',
  ),
  GitaShloka(
    chapter: 'BG 12.15',
    sanskrit:
        'यस्मान्नोद्विजते लोको लोकान्नोद्विजते च यः।\nहर्षामर्षभयोद्वेगैर्मुक्तो यः स च मे प्रियः॥',
    english:
        '"He by whom no one is put into difficulty and who is not disturbed by anyone, who is liberated from happiness, distress, fear and anxiety, is very dear to Me."',
  ),
  GitaShloka(
    chapter: 'BG 16.1–3',
    sanskrit:
        'अभयं सत्त्वसंशुद्धिर्ज्ञानयोगव्यवस्थितिः।\nदानं दमश्च यज्ञश्च स्वाध्यायस्तप आर्जवम्॥',
    english:
        '"Fearlessness, purification of one’s existence, cultivation of spiritual knowledge, charity, self-control, performance of sacrifice, study of the Vedas, austerity, and simplicity — these are the divine qualities of a purified soul."',
  ),
  GitaShloka(
    chapter: 'BG 18.61',
    sanskrit:
        'ईश्वरः सर्वभूतानां हृद्देशेऽर्जुन तिष्ठति।\nभ्रामयन्सर्वभूतानि यन्त्रारूढानि मायया॥',
    english:
        '"The Supreme Lord resides in the hearts of all living beings, O Arjuna, directing their wanderings as if seated on a machine made of material energy."',
  ),
  GitaShloka(
    chapter: 'BG 18.78',
    sanskrit:
        'यत्र योगेश्वरः कृष्णो यत्र पार्थो धनुर्धरः।\nतत्र श्रीर्विजयो भूतिर्ध्रुवा नीतिर्मतिर्मम॥',
    english:
        '"Wherever there is Krishna, the Lord of all yoga, and wherever there is Arjuna, the supreme archer, there will also certainly be opulence, victory, extraordinary power, and morality. That is my firm conviction."',
  ),
];

class GitaShloka {
  final String chapter;
  final String sanskrit;
  final String english;
  const GitaShloka({
    required this.chapter,
    required this.sanskrit,
    required this.english,
  });
}

class GitaStartupDialog extends ConsumerWidget {
  const GitaStartupDialog({super.key, required this.shloka});

  final GitaShloka shloka;

  /// Pick a random shloka and show it, if the feature is enabled.
  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref) async {
    final enabled = ref.read(gitaShlokaEnabledProvider);
    if (!enabled) return;

    final shloka = _kGitaShlokas[Random().nextInt(_kGitaShlokas.length)];

    await showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context) => GitaStartupDialog(shloka: shloka),
    );
  }

  /// Show a random shloka manually on-demand.
  static Future<void> showManual(BuildContext context) async {
    final shloka = _kGitaShlokas[Random().nextInt(_kGitaShlokas.length)];
    await showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) => GitaStartupDialog(shloka: shloka),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(gitaShlokaEnabledProvider);
    final haptic = ref.read(hapticServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFFFFBF7),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.6 : 0.9),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.6) : VelvetColors.cocoa.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sacred Om Symbol Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.22 : 0.15),
                  border: Border.all(color: VelvetColors.coralPeach, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '🕉️',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'BHAGAVAD GITA — SACRED INVOCATION',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: VelvetColors.coralPeach,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              Text(
                shloka.chapter,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : VelvetColors.cocoa.withValues(alpha: 0.75),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // Sanskrit / Kannada Shloka Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF9F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.5 : 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.3) : VelvetColors.cocoa.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  shloka.sanskrit,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF2C1E1E),
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),

              // English Translation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                      : VelvetColors.coralPeach.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: VelvetColors.coralPeach.withValues(alpha: isDark ? 0.45 : 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 16,
                          color: isDark ? VelvetColors.coralPeach : VelvetColors.cocoa,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'English Translation',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? VelvetColors.coralPeach : VelvetColors.cocoa,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shloka.english,
                      style: GoogleFonts.outfit(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFFE2E8F0) : VelvetColors.cocoa,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Toggle Row: On / Off Startup Shloka
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : VelvetColors.clayTan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, size: 18, color: VelvetColors.coralPeach),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Show Shloka on App Startup',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : VelvetColors.cocoa,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: isEnabled,
                      activeTrackColor: VelvetColors.coralPeach,
                      onChanged: (val) {
                        ref.read(gitaShlokaEnabledProvider.notifier).toggle(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Enter App Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelvetColors.coralPeach,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: VelvetColors.coralPeach.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await haptic.lightTap();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enter Pariyojana 🕉️',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
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
}
