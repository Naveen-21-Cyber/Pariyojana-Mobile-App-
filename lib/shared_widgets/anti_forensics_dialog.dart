import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/velvet_colors.dart';
import '../core/haptics/haptic_service.dart';
import '../core/security/anti_forensics_service.dart';

/// Interactive Anti-Forensic Diagnostics & Threat Vector Inspection Modal
class AntiForensicsDialog extends ConsumerStatefulWidget {
  const AntiForensicsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AntiForensicsDialog(),
    );
  }

  @override
  ConsumerState<AntiForensicsDialog> createState() => _AntiForensicsDialogState();
}

class _AntiForensicsDialogState extends ConsumerState<AntiForensicsDialog> {
  bool _isScanning = true;
  AntiForensicsReport? _report;

  @override
  void initState() {
    super.initState();
    _executeScan();
  }

  Future<void> _executeScan() async {
    setState(() => _isScanning = true);
    final service = ref.read(antiForensicsServiceProvider);
    final report = await service.runComprehensiveScan();
    if (mounted) {
      setState(() {
        _report = report;
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final haptic = ref.read(hapticServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: VelvetColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.security_rounded, color: VelvetColors.coralPeach, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anti-Forensic Defense',
                        style: TextStyle(
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: VelvetColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'RSA-2048+ Integrity & Reverse Engineering Shield',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: VelvetColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Rescan System',
                  color: VelvetColors.coralPeach,
                  onPressed: () async {
                    await haptic.lightTap();
                    await _executeScan();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: VelvetColors.border(context)),

          // Body
          Flexible(
            child: _isScanning
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: VelvetColors.coralPeach),
                        const SizedBox(height: 18),
                        Text(
                          'Executing Anti-Forensics & Hook Detection Scan...',
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: VelvetColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : _report == null
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Banner
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _report!.isTampered
                                    ? Colors.red.shade900.withValues(alpha: 0.2)
                                    : VelvetColors.mint.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _report!.isTampered ? Colors.red : VelvetColors.mint,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _report!.isTampered ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                                    color: _report!.isTampered ? Colors.red : VelvetColors.mint,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _report!.isTampered ? 'TAMPER RISK DETECTED' : 'SYSTEM FULLY SECURED',
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.outfit().fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                            color: _report!.isTampered ? Colors.red : VelvetColors.mint,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _report!.isTampered
                                              ? 'Anti-forensic lockdown active. RAM session keys scrubbed.'
                                              : 'Hardware encryption locked. Zero plaintext keys in storage.',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: VelvetColors.textPrimary(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // RSA-2048 Cryptographic Challenge Seal Card
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: VelvetColors.cardSurface(context),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: VelvetColors.border(context)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.vpn_key_rounded, size: 16, color: VelvetColors.coralPeach),
                                      const SizedBox(width: 8),
                                      Text(
                                        'RSA-2048 Challenge Integrity Seal',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: GoogleFonts.outfit().fontFamily,
                                          color: VelvetColors.textPrimary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    _report!.rsaChallengeFingerprint,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: VelvetColors.coralPeach,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    'HMAC-SHA256: ${_report!.hmacIntegritySeal.substring(0, 24)}...',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                                      fontSize: 9.5,
                                      color: VelvetColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Threat Vectors List
                            Text(
                              'Security Vector Diagnostics',
                              style: TextStyle(
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: VelvetColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._report!.vectors.map((vec) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: VelvetColors.cardSurface(context),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: vec.detected ? Colors.red.withValues(alpha: 0.5) : VelvetColors.border(context),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      vec.detected ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                                      color: vec.detected ? Colors.red : VelvetColors.mint,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                vec.vectorName,
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: VelvetColors.textPrimary(context),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: (vec.detected ? Colors.red : VelvetColors.mint).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  vec.detected ? 'DETECTED' : 'SECURE',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w900,
                                                    color: vec.detected ? Colors.red : VelvetColors.mint,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            vec.details,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: VelvetColors.textSecondary(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
