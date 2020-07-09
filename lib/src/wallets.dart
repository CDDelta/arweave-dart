import 'dart:convert';

import 'package:crypto/crypto.dart';

import './api.dart';

class ArweaveWallets {
  final ArweaveApi _api;

  ArweaveWallets(ArweaveApi api) : this._api = api;

  Future<String> getBalance(String address) =>
      this._api.get('wallet/$address/balance').then((res) => res.body);

  Future<String> getLastTransactionId(String address) =>
      this._api.get('wallet/$address/last_tx').then((res) => res.body);

  Future<Map<String, String>> generate() {}

  String jwkToAddress(Map<String, String> jwk) => ownerToAddress(jwk['n']);

  String ownerToAddress(String owner) =>
      base64Encode(sha256.convert(base64Decode(owner)).bytes);
}
