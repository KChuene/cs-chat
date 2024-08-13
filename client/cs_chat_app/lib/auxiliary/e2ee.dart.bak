import 'dart:convert';
import 'dart:typed_data';
import 'package:webcrypto/webcrypto.dart';

class E2EE {
  
  Future<JsonWebKeyPair> generateKeys() async {
    // STEP 1 - Generate Public-Private key pay
    final keyPair = EcdhPrivateKey.generateKey(EllipticCurve.p256) as KeyPair<EcdhPrivateKey, EcdhPublicKey>;
    final publicKeyJWK = await keyPair.publicKey.exportJsonWebKey();
    final privateKeyJWK = await keyPair.privateKey.exportJsonWebKey(); 

    return JsonWebKeyPair(
      privateKey: json.encode(privateKeyJWK), 
      publicKey: json.encode(publicKeyJWK)
    );
  }

  // senderJWK -> sender.privateKey
  // receiverJWK -> receiver.publicKey
  Future<List<int>> deriveSymKey(String senderJWK, String receiverJWK) async {
    // STEP 2 - Create symmetric Cryptographic key

    final senderPrivateKey = json.decode(senderJWK);
    final senderECDHKey = await EcdhPrivateKey.importJsonWebKey(senderPrivateKey, EllipticCurve.p256);

    final receiverPublicKey = json.decode(receiverJWK);
    final receiverECDHKey = await EcdhPublicKey.importJsonWebKey(receiverPublicKey, EllipticCurve.p256);

    final derivedBits = await senderECDHKey.deriveBits(256, receiverECDHKey);
    return derivedBits;
  }

  // Initialization Vector (IV) - To ensure the encryption's strength. 
  // IV Must be random and unique for each encryption process.
  // IV is included in the message so the decryption method ca use it.
  final Uint8List iv = Uint8List.fromList("Initialization vector".codeUnits);

  Future<String> encryptMessage(String message, List<int> derivedKey) async {
    // import crypto key
    final aesGcmSecretKey = await AesGcmSecretKey.importRawKey(derivedKey);

    // convert message to bytes
    final messageBytes = Uint8List.fromList(message.codeUnits);

    // encrypt the message
    final encryptedMsgBytes = aesGcmSecretKey.encryptBytes(messageBytes, iv) as Uint8List;

    // convert encryption output to string
    final encryptedMessage = String.fromCharCodes(encryptedMsgBytes);
    return encryptedMessage;
  }

  Future<String> decryptMessage(String encryptedMessage, List<int> derivedKey) async {
    // import crypto key
    final aesGcmSecretKey = await AesGcmSecretKey.importRawKey(derivedKey);

    // convert message to bytes
    final messageBytes = Uint8List.fromList(encryptedMessage.codeUnits);

    // encrypt the message
    final decryptedMsgBytes = aesGcmSecretKey.decryptBytes(messageBytes, iv) as Uint8List;

    // convert encryption output to string
    final decryptedMessage = String.fromCharCodes(decryptedMsgBytes);
    return decryptedMessage;
  }
}

class JsonWebKeyPair {
  final String privateKey;
  final String publicKey;

  JsonWebKeyPair({
    required this.privateKey,
    required this.publicKey
  });
}