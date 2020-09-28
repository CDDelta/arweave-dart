import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/src/utils.dart';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart';

final rsaPss = RsaPss(sha256, nonceLength: 0);

class Wallet {
  String get owner => encodeBigIntToBase64(_publicKey.n);
  String get address => ownerToAddress(owner);

  RSAPublicKey _publicKey;
  RSAPrivateKey _privateKey;

  KeyPair _cryptoKeyPair;

  Wallet({RSAPublicKey publicKey, RSAPrivateKey privateKey})
      : _publicKey = publicKey,
        _privateKey = privateKey;

  Future<Uint8List> sign(Uint8List message) async {
    if (_cryptoKeyPair == null) {
      final jwk = toJwk().map((key, value) =>
          MapEntry(key, key != 'kty' ? base64Url.normalize(value) : value));

      _cryptoKeyPair = KeyPair(
        privateKey: JwkPrivateKey.fromJson(jwk),
        publicKey: JwkPublicKey.fromJson(jwk),
      );
    }

    try {
      final signature = await rsaPss.sign(
        message,
        _cryptoKeyPair,
      );

      return signature.bytes;
    } catch (err) {
      if (err is UnimplementedError) {
        final signer = PSSSigner(RSAEngine(), SHA256Digest(), SHA256Digest())
          ..init(
            true,
            ParametersWithSalt(
              PrivateKeyParameter<RSAPrivateKey>(_privateKey),
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
    final modulus = decodeBase64ToBigInt(jwk['n']);

    return Wallet(
      publicKey: RSAPublicKey(
        modulus,
        decodeBase64ToBigInt(jwk['e']),
      ),
      privateKey: RSAPrivateKey(
        modulus,
        decodeBase64ToBigInt(jwk['d']),
        decodeBase64ToBigInt(jwk['p']),
        decodeBase64ToBigInt(jwk['q']),
      ),
    );
  }

  Map<String, dynamic> toJwk() => {
        'kty': 'RSA',
        'e': encodeBigIntToBase64(_publicKey.publicExponent),
        'n': encodeBigIntToBase64(_publicKey.n),
        'd': encodeBigIntToBase64(_privateKey.privateExponent),
        'p': encodeBigIntToBase64(_privateKey.p),
        'q': encodeBigIntToBase64(_privateKey.q),
        'dp': encodeBigIntToBase64(
            _privateKey.privateExponent % (_privateKey.p - BigInt.from(1))),
        'dq': encodeBigIntToBase64(
            _privateKey.privateExponent % (_privateKey.q - BigInt.from(1))),
        'qi': encodeBigIntToBase64(_privateKey.q.modInverse(_privateKey.p)),
      };
}
