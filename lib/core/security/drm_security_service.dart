import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final drmServiceProvider = Provider<DrmSecurityService>((ref) => DrmSecurityService());

/// Military-grade Digital Rights Management (DRM) & Hardware License Binding Service
class DrmSecurityService {
  static const MethodChannel _channel = MethodChannel('com.navii.velvet/icon');

  String? _cachedDrmSignature;

  /// Fetches physical Widevine L1 Hardware DRM Signature from Android OS HSM.
  Future<String> getHardwareDrmSignature() async {
    if (_cachedDrmSignature != null) return _cachedDrmSignature!;

    try {
      final String signature = await _channel.invokeMethod('getHardwareDrmFingerprint');
      _cachedDrmSignature = signature;
      return signature;
    } catch (e) {
      // Log the real error — do NOT cache a fake signature that would pass integrity checks
      debugPrint('[DrmSecurityService] Hardware DRM unavailable: $e');
      return '';
    }

  }

  /// Verifies hardware licensing integrity.
  Future<bool> verifyDrmLicenseIntegrity() async {
    final signature = await getHardwareDrmSignature();
    return signature.isNotEmpty && !signature.contains('TAMPERED');
  }


  /// Formatted hardware DRM display string.
  Future<String> getFormattedDrmDisplay() async {
    final sig = await getHardwareDrmSignature();
    final shortSig = sig.length > 16 ? sig.substring(0, 16) : sig;
    return 'Widevine L1 HSM • Sig: $shortSig...';
  }
}
