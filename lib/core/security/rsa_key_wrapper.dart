import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class RsaKeyWrapper {
  /// Wraps (encrypts) the AES database key hex using the user's RSA Public Key PEM.
  static String wrapKey({required String aesKeyHex, required String publicPem}) {
    try {
      final parser = RSAKeyParser();
      final publicKey = parser.parse(publicPem) as RSAPublicKey;
      
      final encrypter = Encrypter(RSA(publicKey: publicKey));
      final encrypted = encrypter.encrypt(aesKeyHex);
      return encrypted.base64;
    } catch (e) {
      throw FormatException('Failed to wrap key. Ensure the RSA Public Key PEM is valid: $e');
    }
  }

  /// Unwraps (decrypts) the wrapped AES key Base64 using the user's RSA Private Key PEM.
  static String unwrapKey({required String wrappedKeyBase64, required String privatePem}) {
    try {
      final parser = RSAKeyParser();
      final privateKey = parser.parse(privatePem) as RSAPrivateKey;
      
      final encrypter = Encrypter(RSA(privateKey: privateKey));
      final decrypted = encrypter.decrypt(Encrypted.fromBase64(wrappedKeyBase64));
      return decrypted;
    } catch (e) {
      throw FormatException('Failed to unwrap key. Ensure the RSA Private Key PEM and wrapped key are valid: $e');
    }
  }
}
