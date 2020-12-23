import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../crypto/crypto.dart';
import '../utils.dart';

class Wallet {
  String get owner =>
      encodeBytesToBase64((_keyPair.publicKey as RsaJwkPublicKey).n);
  String get address => ownerToAddress(owner);

  KeyPair _keyPair;
  Wallet({KeyPair keyPair}) : _keyPair = keyPair;

  Future<Uint8List> sign(Uint8List message) async =>
      rsaPssSign(message: message, keyPair: _keyPair);

  factory Wallet.fromJwk(Map<String, dynamic> jwk) {
    // Normalize the JWK so that it can be decoded by 'cryptography'.
    jwk = jwk.map((key, value) {
      if (key == 'kty' || value is! String) {
        return MapEntry(key, value);
      } else {
        return MapEntry(key, base64Url.normalize(value));
      }
    });

    return Wallet(
      keyPair: KeyPair(
        publicKey: RsaJwkPublicKey.fromJson(jwk),
        privateKey: RsaJwkPrivateKey.fromJson(jwk),
      ),
    );
  }

  Map<String, dynamic> toJwk() =>
      (_keyPair.privateKey as RsaJwkPrivateKey).toJson().map(
          // Denormalize the JWK into the expected form.
          (key, value) => MapEntry(key, (value as String).replaceAll('=', '')));
}
