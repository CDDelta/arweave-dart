import 'dart:convert';

import 'package:http/http.dart';

import './api.dart';
import '../arweave.dart';
import 'models/models.dart';

class ArweaveTransactions {
  final ArweaveApi _api;

  ArweaveTransactions(ArweaveApi api) : this._api = api;

  Future<String> getTransactionAnchor() =>
      this._api.get('tx_anchor').then((res) => res.body);

  Future<String> getPrice({int byteSize, String targetAddress = null}) {
    final endpoint = targetAddress != null
        ? 'price/$byteSize/$targetAddress'
        : 'price/$byteSize';
    return this._api.get(endpoint).then((res) => res.body);
  }

  Future<Transaction> get(String id) async {
    final res = await this._api.get('tx/$id');

    if (res.statusCode == 200) {
      final transaction = Transaction.fromJson(json.decode(res.body));
      if (transaction.format >= 2 && transaction.dataSize != '0') {
        transaction.data = await getData(id);
      }

      return transaction;
    }

    // TODO: Throw on other status codes
    return null;
  }

  Future<String> getData(String id) => this._api.get('tx/$id/data').then(
        (res) {
          if (res.statusCode == 200) return res.body;
          return null;
        },
      );

  Future<List<String>> search(String tagName, String tagValue) {}

  Future<void> sign(Transaction transaction, Map<String, String> jwk) {}

  Future<bool> verify(Transaction transaction) {}

  Future<Response> post(Transaction transaction) =>
      this._api.post('tx', body: json.encode(transaction));
}
