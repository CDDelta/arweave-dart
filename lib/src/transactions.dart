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
      final txJson = json.decode(res.body);

      var transaction = Transaction.fromJson(txJson);
      if (transaction.format >= 2 && transaction.dataSize != '0') {
        txJson['data'] = await getData(id);
        return Transaction.fromJson(txJson);
      }

      return transaction;
    }

    // TODO: Throw on other status codes
    return null;
  }

  Future<TransactionStatus> getStatus(String id) =>
      this._api.get('tx/$id/status').then((res) {
        if (res.statusCode == 200)
          return TransactionStatus(
              status: 200,
              confirmed:
                  TransactionConfimedData.fromJson(json.decode(res.body)));

        return TransactionStatus(status: res.statusCode);
      });

  Future<String> getData(String id) => this._api.get('tx/$id/data').then(
        (res) {
          if (res.statusCode == 200) return res.body;
          return null;
        },
      );

  Future<List<String>> search(String tagName, String tagValue) => arql({
        "op": "equals",
        "expr1": tagName,
        "expr2": tagValue,
      });

  Future<List<String>> arql(Map<String, dynamic> query) =>
      this._api.post('arql', body: json.encode(query)).then(
        (res) {
          if (res.body == '') return [];
          return (json.decode(res.body) as List<dynamic>).cast<String>();
        },
      );

  Future<void> sign(Transaction transaction, Map<String, String> jwk) {
    // TODO: IMPLEMENT
  }

  Future<bool> verify(Transaction transaction) {
    // TODO: IMPLEMENT
  }

  Future<Response> post(Transaction transaction) =>
      this._api.post('tx', body: json.encode(transaction));
}
