import 'dart:core';

import './api.dart';
import 'models/models.dart';

final keyLength = BigInt.from(4096);
final publicExponent = BigInt.from(0x10001);

class ArweaveWallets {
  final ArweaveApi _api;

  ArweaveWallets(ArweaveApi api) : this._api = api;

  /// Get the balance for a given wallet.
  /// Unknown wallet addresses will simply return 0.
  Future<String> getBalance(String address) =>
      this._api.get('wallet/$address/balance').then((res) => res.body);

  /// Get the last outgoing transaction for the given wallet address.
  Future<String> getLastTransactionId(String address) =>
      this._api.get('wallet/$address/last_tx').then((res) => res.body);

  Future<Wallet> generate() async {
    throw UnimplementedError();
  }

  String ownerToAddress(String owner) {
    throw UnimplementedError();
  }
}
