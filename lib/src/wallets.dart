import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart';

import 'api/api.dart';
import 'models/models.dart';
import 'utils.dart';

class ArweaveWalletsApi {
  final ArweaveApi _api;

  ArweaveWalletsApi(ArweaveApi api) : _api = api;

  /// Returns the balance for a given wallet as winston.
  ///
  /// Unknown wallet addresses will simply return 0.
  Future<BigInt> getBalance(String address) =>
      _api.get('wallet/$address/balance').then((res) => BigInt.parse(res.body));

  /// Get the last outgoing transaction for the given wallet address.
  Future<String> getLastTransactionId(String address) =>
      _api.get('wallet/$address/last_tx').then((res) => res.body);

  Future<Wallet> generate() async {
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
}
