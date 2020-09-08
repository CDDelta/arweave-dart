import 'dart:convert';

import 'package:http/http.dart';

import 'api/api.dart';
import 'models/models.dart';
import 'utils.dart';

class ArweaveTransactionsApi {
  final ArweaveApi _api;

  ArweaveTransactionsApi(ArweaveApi api) : this._api = api;

  Future<String> getTransactionAnchor() =>
      this._api.get('tx_anchor').then((res) => res.body);

  Future<BigInt> getPrice({int byteSize, String targetAddress = null}) {
    final endpoint = targetAddress != null
        ? 'price/$byteSize/$targetAddress'
        : 'price/$byteSize';
    return this._api.get(endpoint).then((res) => BigInt.parse(res.body));
  }

  /// Get a transaction by its ID.
  ///
  /// The data field is not included for transaction formats 2 and above, perform a seperate `getData(id)` request to retrieve the data.
  Future<Transaction> get(String id) async {
    final res = await this._api.get('tx/$id');

    if (res.statusCode == 200)
      return Transaction.fromJson(json.decode(res.body));

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

  /// Get the raw Base64 decoded data from a transaction.
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

  /// Prepares a transaction for uploading.
  ///
  /// Sets the transaction owner if a wallet is specified, the transaction anchor, and reward.
  /// Also chunks the transaction data for v2 transactions.
  Future<Transaction> prepare(
    Transaction transaction, [
    Wallet wallet,
  ]) async {
    assert(transaction.data != null ||
        (transaction.target != null && transaction.quantity != null));

    if (transaction.owner == null && wallet != null)
      transaction.setOwner(wallet.owner);

    if (transaction.lastTx == null)
      transaction.setLastTx(await getTransactionAnchor());

    if (transaction.reward == BigInt.zero && transaction.data.isNotEmpty)
      transaction.setReward(
        await getPrice(
          byteSize: int.parse(transaction.dataSize),
          targetAddress: transaction.target,
        ),
      );

    if (transaction.format == 2) await transaction.prepareChunks();

    return transaction;
  }

  Future<Response> post(Transaction transaction) {
    if (transaction.format != 1)
      throw ArgumentError('Only transaction format v1 can be posted.');

    final txJson = transaction.toJson();
    txJson['data'] = encodeBytesToBase64(transaction.data);
    return _api.post('tx', body: txJson);
  }
}
