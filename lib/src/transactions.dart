import 'dart:convert';

import 'package:arweave/src/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:ninja/ninja.dart' as ninja;

import './api.dart';
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

  /// Get a transaction by its ID.
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

  Future<void> sign(Transaction transaction, Wallet wallet) async {
    final signatureData = await transaction.getSignatureData();
    final rawSignature = wallet.sign(signatureData);

    final id = encodeBytesToBase64(sha256.convert(rawSignature).bytes);

    transaction.setSignature(encodeBytesToBase64(rawSignature), id);
  }

  Future<bool> verify(Transaction transaction) async {
    final signatureData = await transaction.getSignatureData();
    final claimedSignatureRaw = decodeBase64ToBytes(transaction.signature);

    final expectedId =
        encodeBytesToBase64(sha256.convert(claimedSignatureRaw).bytes);

    if (transaction.id != expectedId) return false;

    return ninja.RSAPublicKey(
      decodeBase64ToBigInt(transaction.owner),
      publicExponent,
    ).verifySsaPss(
      signatureData,
      claimedSignatureRaw,
    );
  }

  Future<Response> post(Transaction transaction) =>
      this._api.post('tx', body: json.encode(transaction));
}
