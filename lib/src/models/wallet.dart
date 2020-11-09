import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/src/utils.dart';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart';

final rsaPss = RsaPss(sha256, nonceLength: 0);

class Wallet {
  String get owner =>
      encodeBytesToBase64((_keyPair.publicKey as RsaJwkPublicKey).n);
  String get address => ownerToAddress(owner);

  KeyPair _keyPair;
  RSAPrivateKey _pcPrivateKey;

  Wallet({KeyPair keyPair}) : _keyPair = keyPair;

  Future<Uint8List> sign(Uint8List message) async {
    try {
      final signature = await rsaPss.sign(message, _keyPair);
      return signature.bytes;
    } catch (err) {
      if (err is UnimplementedError) {
        if (_pcPrivateKey == null) {
          // Cache an instance of a `pointycastle` private key for use later.
          final pk = _keyPair.privateKey as RsaJwkPrivateKey;
          _pcPrivateKey = RSAPrivateKey(
            decodeBytesToBigInt(pk.n),
            decodeBytesToBigInt(pk.d),
            decodeBytesToBigInt(pk.p),
            decodeBytesToBigInt(pk.q),
            decodeBytesToBigInt(pk.e),
          );
        }

        final signer = PSSSigner(RSAEngine(), SHA256Digest(), SHA256Digest())
          ..init(
            true,
            ParametersWithSalt(
              PrivateKeyParameter<RSAPrivateKey>(_pcPrivateKey),
              null,
            ),
          );
        return signer.generateSignature(message).bytes;
      } else {
        rethrow;
      }
    }
  }

  factory Wallet.fromJwk(Map<String, dynamic> jwk) {
    // Normalize the JWK so that it can be decoded by 'cryptography'.
    jwk = jwk.map((key, value) =>
        MapEntry(key, key != 'kty' ? base64Url.normalize(value) : value));

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
