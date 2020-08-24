import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'api/api.dart';
import 'models/models.dart';
import 'utils.dart';

class ArweaveWalletsApi {
  final ArweaveApi _api;

  ArweaveWalletsApi(ArweaveApi api) : this._api = api;

  /// Get the balance for a given wallet.
  /// Unknown wallet addresses will simply return 0.
  Future<String> getBalance(String address) =>
      this._api.get('wallet/$address/balance').then((res) => res.body);

  /// Get the last outgoing transaction for the given wallet address.
  Future<String> getLastTransactionId(String address) =>
      this._api.get('wallet/$address/last_tx').then((res) => res.body);

  Future<Wallet> generate() async {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
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
    return Wallet(
      publicKey: pair.publicKey,
      privateKey: pair.privateKey,
    );
  }
}
