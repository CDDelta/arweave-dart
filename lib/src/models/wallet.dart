import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart';

import '../crypto/crypto.dart';
import '../utils.dart';

class Wallet {
  String get owner =>
      encodeBytesToBase64((_keyPair.publicKey as RsaJwkPublicKey).n);
  String get address => ownerToAddress(owner);

  KeyPair _keyPair;
  Wallet({KeyPair keyPair}) : _keyPair = keyPair;

  static Future<Wallet> generate() async {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (var i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(
            publicExponent,
            keyLength,
            64,
          ),
          secureRandom,
        ),
      );

    final pair = keyGen.generateKeyPair();

    final pubK = pair.publicKey as RSAPublicKey;
    final privK = pair.privateKey as RSAPrivateKey;

    return Wallet(
      keyPair: KeyPair(
        publicKey: RsaJwkPublicKey(
          e: encodeBigIntToBytes(pubK.publicExponent),
          n: encodeBigIntToBytes(pubK.modulus),
        ),
        privateKey: RsaJwkPrivateKey(
          e: encodeBigIntToBytes(privK.publicExponent),
          n: encodeBigIntToBytes(privK.modulus),
          d: encodeBigIntToBytes(privK.privateExponent),
          p: encodeBigIntToBytes(privK.p),
          q: encodeBigIntToBytes(privK.q),
          dp: encodeBigIntToBytes(
              privK.privateExponent % (privK.p - BigInt.one)),
          dq: encodeBigIntToBytes(
              privK.privateExponent % (privK.q - BigInt.one)),
          qi: encodeBigIntToBytes(privK.q.modInverse(privK.p)),
        ),
      ),
    );
  }

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
