import 'dart:core';

import './api.dart';
import 'models/models.dart';

final keyLength = BigInt.from(4096);
final publicExponent = BigInt.from(0x10001);

class ArweaveWallets {
  final ArweaveApi _api;

  ArweaveWallets(ArweaveApi api) : this._api = api;

  Future<String> getBalance(String address) =>
      this._api.get('wallet/$address/balance').then((res) => res.body);

  Future<String> getLastTransactionId(String address) =>
      this._api.get('wallet/$address/last_tx').then((res) => res.body);

  Future<Wallet> generate() async {}

  String ownerToAddress(String owner) {}
  //base64Url.encode(sha256.convert(utf8.encode(owner)).bytes);
}
