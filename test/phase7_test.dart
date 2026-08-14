import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:velvet/core/security/rsa_key_wrapper.dart';
import 'package:velvet/core/backup/google_backup_service.dart';

SecureRandom getSecureRandom() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();
  final seeds = List<int>.generate(32, (_) => random.nextInt(256));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeyPair() {
  final rsaParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 1024, 64);
  final params = ParametersWithRandom(rsaParams, getSecureRandom());
  final generator = RSAKeyGenerator();
  generator.init(params);
  final pair = generator.generateKeyPair();
  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
    pair.publicKey as RSAPublicKey,
    pair.privateKey as RSAPrivateKey,
  );
}

String rsaPublicKeyToPem(RSAPublicKey key) {
  final asn1Seq = ASN1Sequence();
  asn1Seq.add(ASN1Integer(key.modulus));
  asn1Seq.add(ASN1Integer(key.exponent));
  final bytes = asn1Seq.encode();
  return '-----BEGIN RSA PUBLIC KEY-----\n${base64.encode(bytes)}\n-----END RSA PUBLIC KEY-----';
}

String rsaPrivateKeyToPem(RSAPrivateKey key) {
  final asn1Seq = ASN1Sequence();
  asn1Seq.add(ASN1Integer(BigInt.zero));
  asn1Seq.add(ASN1Integer(key.modulus));
  asn1Seq.add(ASN1Integer(key.publicExponent));
  asn1Seq.add(ASN1Integer(key.privateExponent));
  asn1Seq.add(ASN1Integer(key.p));
  asn1Seq.add(ASN1Integer(key.q));
  asn1Seq.add(ASN1Integer(key.privateExponent! % (key.p! - BigInt.one)));
  asn1Seq.add(ASN1Integer(key.privateExponent! % (key.q! - BigInt.one)));
  asn1Seq.add(ASN1Integer(key.q!.modInverse(key.p!)));
  final bytes = asn1Seq.encode();
  return '-----BEGIN RSA PRIVATE KEY-----\n${base64.encode(bytes)}\n-----END RSA PRIVATE KEY-----';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (methodCall) async => null,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      (methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      },
    );
  });

  group('Phase 7 - RSA Key Wrapping and Backup Tests', () {
    test('RsaKeyWrapper wraps and unwraps AES key correctly using PEM strings', () {
      final pair = generateKeyPair();
      final publicPem = rsaPublicKeyToPem(pair.publicKey);
      final privatePem = rsaPrivateKeyToPem(pair.privateKey);

      const aesKeyHex = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      final wrapped = RsaKeyWrapper.wrapKey(aesKeyHex: aesKeyHex, publicPem: publicPem);
      expect(wrapped.isNotEmpty, true);

      final unwrapped = RsaKeyWrapper.unwrapKey(wrappedKeyBase64: wrapped, privatePem: privatePem);
      expect(unwrapped, aesKeyHex);
    });

    test('RsaKeyWrapper throws FormatException on invalid inputs', () {
      expect(
        () => RsaKeyWrapper.wrapKey(aesKeyHex: 'aesKey', publicPem: 'invalid_pem'),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => RsaKeyWrapper.unwrapKey(wrappedKeyBase64: 'wrappedKey', privatePem: 'invalid_pem'),
        throwsA(isA<FormatException>()),
      );
    });

    test('GoogleBackupService simulated backup fallback executes successfully', () async {
      final file = File('./velvet.db');
      await file.writeAsString('dummy db content');

      final backupService = GoogleBackupServiceImpl();
      final success = await backupService.backupDatabaseToDrive();
      expect(success, true);

      if (await file.exists()) {
        await file.delete();
      }
    });
  });
}
