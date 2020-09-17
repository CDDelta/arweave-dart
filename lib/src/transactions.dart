import 'dart:convert';

import 'api/api.dart';
import 'models/models.dart';

class ArweaveTransactionsApi {
  final ArweaveApi _api;

  ArweaveTransactionsApi(ArweaveApi api) : _api = api;

  Future<String> getTransactionAnchor() =>
      _api.get('tx_anchor').then((res) => res.body);

  Future<BigInt> getPrice({int byteSize, String targetAddress}) {
    final endpoint = targetAddress != null
        ? 'price/$byteSize/$targetAddress'
        : 'price/$byteSize';
    return _api.get(endpoint).then((res) => BigInt.parse(res.body));
  }

  /// Get a transaction by its ID.
  ///
  /// The data field is not included for transaction formats 2 and above, perform a seperate `getData(id)` request to retrieve the data.
  Future<Transaction> get(String id) async {
    final res = await _api.get('tx/$id');

    if (res.statusCode == 200) {
      return Transaction.fromJson(json.decode(res.body));
    }

    // TODO: Throw on other status codes
    return null;
  }

  Future<TransactionStatus> getStatus(String id) =>
      _api.get('tx/$id/status').then((res) {
        if (res.statusCode == 200) {
          return TransactionStatus(
              status: 200,
              confirmed:
                  TransactionConfimedData.fromJson(json.decode(res.body)));
        }

        return TransactionStatus(status: res.statusCode);
      });

  /// Get the data associated with a transaction.
  ///
  /// Optionally provide an extension to decode the data.
  Future<String> getData(String id, [String extension]) =>
      _api.get('tx/$id/data${extension != null ? '.$extension' : ''}').then(
        (res) {
          if (res.statusCode == 200) return res.body;
          return null;
        },
      );

  Future<List<String>> search(String tagName, String tagValue) => arql({
        'op': 'equals',
        'expr1': tagName,
        'expr2': tagValue,
      });

  Future<List<String>> arql(Map<String, dynamic> query) =>
      _api.post('arql', body: json.encode(query)).then(
        (res) {
          if (res.body == '') return [];
          return (json.decode(res.body) as List<dynamic>).cast<String>();
        },
      );

  /// Prepares a transaction with the required details.
  ///
  /// Chunks the transaction data, sets the transaction anchor, reward,
  /// and the transaction owner if a wallet is specified,
  Future<Transaction> prepare(
    Transaction transaction, [
    Wallet wallet,
  ]) async {
    assert(transaction.data != null ||
        (transaction.target != null && transaction.quantity != null));

    if (transaction.format == 1) {
      throw ArgumentError('Creating v1 transactions is not supported.');
    }

    if (transaction.owner == null && wallet != null) {
      transaction.setOwner(wallet.owner);
    }

    if (transaction.lastTx == null) {
      transaction.setLastTx(await getTransactionAnchor());
    }

    if (transaction.reward == BigInt.zero && transaction.data.isNotEmpty) {
      transaction.setReward(
        await getPrice(
          byteSize: int.parse(transaction.dataSize),
          targetAddress: transaction.target,
        ),
      );
    }

    await transaction.prepareChunks();

    return transaction;
  }

  /// Returns an uploader than can be used to upload a transaction chunk by chunk, giving progress
  /// and the ability to resume.
  Future<TransactionUploader> getUploader(Transaction transaction,
          {bool forDataOnly = false}) async =>
      TransactionUploader(transaction, _api, forDataOnly: forDataOnly);

  /// Uploads the transaction in full, returning a stream of events signaling the status of the upload.
  Stream<TransactionUploader> upload(Transaction transaction,
      {bool dataOnly = false}) async* {
    final uploader = await getUploader(transaction, forDataOnly: dataOnly);

    while (!uploader.isComplete) {
      await uploader.uploadChunk();
      yield uploader;
    }
  }

  /// Uploads the transaction in full. Useful for small data or wallet transactions.
  Future<void> post(Transaction transaction) async {
    final uploader = await getUploader(transaction);
    while (!uploader.isComplete) {
      await uploader.uploadChunk();
    }
  }
}
