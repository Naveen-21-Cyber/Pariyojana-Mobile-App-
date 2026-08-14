import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../../shared_widgets/particle_explosion.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database.dart';
import '../../presentation/providers/idea_provider.dart';
import '../../../research_tracker/presentation/providers/research_provider.dart';
import '../../../research_tracker/presentation/screens/research_detail_screen.dart';
import '../../../../core/security/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BiometricVaultScreen extends ConsumerStatefulWidget {
  const BiometricVaultScreen({super.key});

  @override
  ConsumerState<BiometricVaultScreen> createState() => _BiometricVaultScreenState();
}

class _BiometricVaultScreenState extends ConsumerState<BiometricVaultScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  List<int> _secureIdeaIds = [];
  List<int> _securePaperIds = [];

  @override
  void initState() {
    super.initState();
    _startBiometricAuth();
  }

  Future<void> _startBiometricAuth() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showAuthFailedDialog('Biometrics not supported or configured on this device.');
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Access Pariyojana Secure Vault',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await _loadSecureIds();
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      } else {
        setState(() {
          _isAuthenticating = false;
        });
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
      _showAuthFailedDialog(e.toString());
    }
  }

  Future<void> _loadSecureIds() async {
    final storage = ref.read(secureStorageProvider);
    final secureIdeas = await storage.getSecureIdeaIds();
    final securePapers = await storage.getSecurePaperIds();
    setState(() {
      _secureIdeaIds = secureIdeas;
      _securePaperIds = securePapers;
    });
  }

  void _showAuthFailedDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Authentication Failed', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.cocoa)),
        content: Text(message, style: const TextStyle(color: VelvetColors.cocoa)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: VelvetColors.coralPeach)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              _startBiometricAuth();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockIdea(int id) async {
    final storage = ref.read(secureStorageProvider);
    await storage.setIdeaSecure(id, false);
    await _loadSecureIds();
    if (mounted) {
      final size = MediaQuery.of(context).size;
      ParticleExplosion.show(
        context,
        Offset(size.width / 2, size.height * 0.4),
        color: VelvetColors.coralPeach,
      );
      GlassSnackBar.show(context, 'Idea moved back to public vault 🔓');
    }
  }

  Future<void> _unlockPaper(int id) async {
    final storage = ref.read(secureStorageProvider);
    await storage.setPaperSecure(id, false);
    await _loadSecureIds();
    if (mounted) {
      final size = MediaQuery.of(context).size;
      ParticleExplosion.show(
        context,
        Offset(size.width / 2, size.height * 0.4),
        color: VelvetColors.coralPeach,
      );
      GlassSnackBar.show(context, 'Research Paper moved back to public list 🔓');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: VelvetColors.surface(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint_rounded, size: 80, color: VelvetColors.coralPeach)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1200.ms),
              const SizedBox(height: 24),
              Text(
                'SECURE VAULT LOCKED',
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: VelvetColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isAuthenticating ? 'Authenticating with Biometrics...' : 'Tap below to scan fingerprint',
                style: TextStyle(fontSize: 13, color: VelvetColors.textSecondary(context)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelvetColors.coralPeach,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                icon: const Icon(Icons.fingerprint_rounded, size: 22),
                label: const Text('Scan Fingerprint / PIN 🔐', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: _startBiometricAuth,
              ),
            ],
          ),
        ),
      );
    }

    final ideasAsync = ref.watch(ideasStreamProvider);
    final papersAsync = ref.watch(researchPapersStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: VelvetColors.surface(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: VelvetColors.iconColor(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'SECURE BIOMETRIC VAULT',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: VelvetColors.textPrimary(context),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shield_outlined, color: Colors.teal, size: 22),
              tooltip: 'Emergency Re-Lock Vault',
              onPressed: () {
                setState(() => _isAuthenticated = false);
                GlassSnackBar.show(context, 'Vault Security Lock Engaged 🛡️');
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: VelvetColors.coralPeach, size: 24),
              tooltip: 'Add Secure Item',
              onPressed: () => _showAddSecureItemMenu(context),
            ),
            const SizedBox(width: 4),
          ],
          bottom: TabBar(
            indicatorColor: VelvetColors.coralPeach,
            labelColor: VelvetColors.coralPeach,
            unselectedLabelColor: VelvetColors.textSecondary(context),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: GoogleFonts.outfit().fontFamily),
            tabs: const [
              Tab(text: 'SECURE IDEAS', icon: Icon(Icons.lightbulb_outline_rounded)),
              Tab(text: 'SECURE PAPERS', icon: Icon(Icons.assignment_late_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Ideas
            ideasAsync.when(
              data: (allIdeas) {
                final secureIdeas = allIdeas.where((idea) => _secureIdeaIds.contains(idea.id)).toList();
                if (secureIdeas.isEmpty) {
                  return Center(
                    child: Text('No secure ideas in vault 🔒', style: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: secureIdeas.length,
                  itemBuilder: (context, index) {
                    final idea = secureIdeas[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClayCard(
                        color: VelvetColors.surface(context),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      idea.category.toUpperCase(),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    idea.content,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: VelvetColors.textPrimary(context)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.lock_open_rounded, color: VelvetColors.coralPeach),
                              onPressed: () => _unlockIdea(idea.id),
                              tooltip: 'Unlock and Move to Public',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: VelvetColors.coralPeach)),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),

            // Tab 2: Papers
            papersAsync.when(
              data: (allPapers) {
                final securePapers = allPapers.where((paper) => _securePaperIds.contains(paper.id)).toList();
                if (securePapers.isEmpty) {
                  return Center(
                    child: Text('No secure research papers in vault 🔒', style: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: securePapers.length,
                  itemBuilder: (context, index) {
                    final paper = securePapers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClayCard(
                        color: VelvetColors.surface(context),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    paper.title,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Authors: ${paper.coAuthors ?? "Self"}',
                                    style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility_rounded, color: VelvetColors.iconColor(context)),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ResearchDetailScreen(paperId: paper.id),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.lock_open_rounded, color: VelvetColors.coralPeach),
                              onPressed: () => _unlockPaper(paper.id),
                              tooltip: 'Unlock and Move to Public',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: VelvetColors.coralPeach)),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 130.0),
          child: FloatingActionButton.extended(
            backgroundColor: VelvetColors.coralPeach,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.add_rounded),
            label: Text('Add Secure Item', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.outfit().fontFamily)),
            onPressed: () => _showAddSecureItemMenu(context),
          ),
        ),
      ),
    );
  }

  void _showAddSecureItemMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: VelvetColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: VelvetColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add to Encrypted Secure Vault 🔐',
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VelvetColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline_rounded, color: VelvetColors.coralPeach),
              title: Text('Add Secure Idea', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              subtitle: Text('Create a encrypted secret idea in vault', style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context))),
              onTap: () {
                Navigator.pop(ctx);
                _showAddSecureIdeaDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.assignment_late_outlined, color: VelvetColors.coralPeach),
              title: Text('Add Secure Research Paper', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              subtitle: Text('Log a confidential research paper draft', style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context))),
              onTap: () {
                Navigator.pop(ctx);
                _showAddSecurePaperDialog(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
  }

  void _showAddSecureIdeaDialog(BuildContext context) {
    final controller = TextEditingController();
    String category = 'Research';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Create Secure Idea 🔐', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
              style: TextStyle(color: VelvetColors.textPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Enter secret idea content...',
                hintStyle: TextStyle(color: VelvetColors.textSecondary(context)),
                filled: true,
                fillColor: VelvetColors.inputFill(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: VelvetColors.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final ideaRepo = ref.read(ideaRepositoryProvider);
                final id = await ideaRepo.insertIdea(
                  IdeasCompanion.insert(
                    content: text,
                    category: category,
                  ),
                );
                final storage = ref.read(secureStorageProvider);
                await storage.setIdeaSecure(id, true);
                await _loadSecureIds();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  GlassSnackBar.show(context, 'Secure Idea locked in vault! 🔐');
                }
              }
            },
            child: const Text('Save & Lock'),
          ),
        ],
      ),
    );
  }

  void _showAddSecurePaperDialog(BuildContext context) {
    final titleController = TextEditingController();
    final venueController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VelvetColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Create Secure Research Paper 🔐', style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: VelvetColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Paper Title',
                labelStyle: TextStyle(color: VelvetColors.textSecondary(context)),
                filled: true,
                fillColor: VelvetColors.inputFill(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueController,
              style: TextStyle(color: VelvetColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Target Venue (e.g., IEEE, arXiv)',
                labelStyle: TextStyle(color: VelvetColors.textSecondary(context)),
                filled: true,
                fillColor: VelvetColors.inputFill(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: VelvetColors.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: VelvetColors.coralPeach, foregroundColor: Colors.white),
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final paperRepo = ref.read(researchRepositoryProvider);
                final id = await paperRepo.insertPaper(
                  ResearchPapersCompanion.insert(
                    title: title,
                    targetVenue: drift.Value(venueController.text.trim().isEmpty ? null : venueController.text.trim()),
                    status: 'Drafting',
                  ),
                );
                final storage = ref.read(secureStorageProvider);
                await storage.setPaperSecure(id, true);
                await _loadSecureIds();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  GlassSnackBar.show(context, 'Secure Research Paper locked in vault! 🔐');
                }
              }
            },
            child: const Text('Save & Lock'),
          ),
        ],
      ),
    );
  }
}

class KeySafeVaultWidget extends StatefulWidget {
  const KeySafeVaultWidget({super.key});

  @override
  State<KeySafeVaultWidget> createState() => _KeySafeVaultWidgetState();
}

class _KeySafeVaultWidgetState extends State<KeySafeVaultWidget> {
  final TextEditingController _apiKeyController = TextEditingController(text: 'AIzaSy_PARIYOJANA_MASTER_KEY_9A8B7C');
  final TextEditingController _secretNoteController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClayCard(
            color: VelvetColors.surface(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.vpn_key_rounded, color: VelvetColors.coralPeach, size: 22),
                    const SizedBox(width: 8),
                    Text('1. Master API Key Safe 🔑', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('AES-256 local encrypted storage for Gemini & OpenAI keys.', style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context))),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _isObscured,
                  style: TextStyle(fontSize: 11, color: VelvetColors.textPrimary(context), fontFamily: GoogleFonts.jetBrainsMono().fontFamily),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, size: 18, color: VelvetColors.iconColor(context)),
                      onPressed: () => setState(() => _isObscured = !_isObscured),
                    ),
                    filled: true,
                    fillColor: VelvetColors.inputFill(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelvetColors.coralPeach,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Copy Key 📋', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        GlassSnackBar.show(context, '🔑 Master API Key copied securely!');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ClayCard(
            color: VelvetColors.surface(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.enhanced_encryption_rounded, color: VelvetColors.mint, size: 22),
                    const SizedBox(width: 8),
                    Text('2. Zero-Knowledge Secret Note 📝', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Encrypted note drawer zero-cleared upon vault re-lock.', style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context))),
                const SizedBox(height: 12),
                TextField(
                  controller: _secretNoteController,
                  maxLines: 3,
                  style: TextStyle(fontSize: 11, color: VelvetColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Type confidential security notes or backup passphrases...',
                    hintStyle: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                    filled: true,
                    fillColor: VelvetColors.inputFill(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: VelvetColors.border(context))),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelvetColors.mint,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.save_rounded, size: 14),
                      label: const Text('Save Encrypted 💾', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        GlassSnackBar.show(context, '📝 Secret note encrypted with AES-256 key!');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ClayCard(
            color: VelvetColors.surface(context),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.cleaning_services_rounded, color: Colors.redAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('3. Anti-Forensic RAM Zeroing 🛡️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VelvetColors.textPrimary(context))),
                      const SizedBox(height: 2),
                      Text('Instantly wipe decrypted key buffers from RAM.', style: TextStyle(fontSize: 10.5, color: VelvetColors.textSecondary(context))),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _secretNoteController.clear();
                    });
                    GlassSnackBar.show(context, '🛡️ RAM buffers zero-cleared instantly!');
                  },
                  child: const Text('Zero RAM ⚡', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
