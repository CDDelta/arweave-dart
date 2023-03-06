import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:jwk/jwk.dart';
import 'package:pointycastle/export.dart';

import '../crypto/crypto.dart';
import '../utils.dart';

class Wallet {
  RsaKeyPair? _keyPair;
  Wallet({KeyPair? keyPair}) : _keyPair = keyPair as RsaKeyPair?;

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

    final privK = pair.privateKey as RSAPrivateKey;

    return Wallet(
      keyPair: RsaKeyPairData(
        e: encodeBigIntToBytes(privK.publicExponent!),
        n: encodeBigIntToBytes(privK.modulus!),
        d: encodeBigIntToBytes(privK.privateExponent!),
        p: encodeBigIntToBytes(privK.p!),
        q: encodeBigIntToBytes(privK.q!),
      ),
    );
  }

  Future<String> getOwner() async => encodeBytesToBase64(
      await _keyPair!.extractPublicKey().then((res) => res.n));
  Future<String> getAddress() async => ownerToAddress(await getOwner());

  Future<Uint8List> sign(Uint8List message) async =>
      rsaPssSign(message: message, keyPair: _keyPair!);

  factory Wallet.fromJwk(Map<String, dynamic> jwk) {
    // Normalize the JWK so that it can be decoded by 'cryptography'.
    jwk = jwk.map((key, value) {
      if (key == 'kty' || value is! String) {
        return MapEntry(key, value);
      } else {
        return MapEntry(key, base64Url.normalize(value));
      }
    });

    return Wallet(keyPair: Jwk.fromJson(jwk).toKeyPair());
  }

  Map<String, dynamic> toJwk() => Jwk.fromKeyPair(_keyPair!).toJson().map(
      // Denormalize the JWK into the expected form.
      (key, value) => MapEntry(key, (value as String).replaceAll('=', '')));
}
