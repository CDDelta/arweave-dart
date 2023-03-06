import 'dart:convert';

import 'package:arweave/src/models/transaction_stream.dart';

import 'api/api.dart';
import 'models/models.dart';

class ArweaveTransactionsApi {
  final ArweaveApi _api;

  ArweaveTransactionsApi(ArweaveApi api) : _api = api;

  Future<String> getTransactionAnchor() =>
      _api.get('tx_anchor').then((res) => res.body);

  Future<BigInt> getPrice({required int byteSize, String? targetAddress}) {
    final endpoint = targetAddress != null
        ? 'price/$byteSize/$targetAddress'
        : 'price/$byteSize';
    return _api.get(endpoint).then((res) => BigInt.parse(res.body));
  }

  /// Get a transaction by its ID.
  ///
  /// The data field is not included for transaction formats 2 and above, perform a seperate `getData(id)` request to retrieve the data.
  Future<T?> get<T extends Transaction>(String id) async {
    final res = await _api.get('tx/$id');

    if (res.statusCode == 200) {
      switch (T) {
        case Transaction:
          return Transaction.fromJson(jsonDecode(res.body)) as T;
        case TransactionStream:
          return TransactionStream.fromJson(jsonDecode(res.body)) as T;
        default:
          throw ArgumentError('Unsupported transaction type: $T');
      }
    }

    // TODO: Throw on other status codes
    return null;
  }

  /// Prepares a transaction with the required details.
  ///
  /// Chunks the transaction data, sets the transaction anchor, reward,
  /// and the transaction owner if a wallet is specified,
  Future<T> prepare<T extends Transaction>(
    T transaction,
    Wallet wallet,
  ) async {
    if (transaction.format == 1) {
      throw ArgumentError('Creating v1 transactions is not supported.');
    }

    if (transaction.owner == null) {
      transaction.setOwner(await wallet.getOwner());
    }

    if (transaction.lastTx == null) {
      transaction.setLastTx(await getTransactionAnchor());
    }

    if (transaction.reward == BigInt.zero) {
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
          {int maxConcurrentUploadCount = 128,
          bool forDataOnly = false}) async =>
      TransactionUploader(transaction, _api,
          maxConcurrentChunkUploadCount: maxConcurrentUploadCount,
          forDataOnly: forDataOnly);

  /// Uploads the transaction in full, returning a stream of events signaling the status of the upload.
  Stream<TransactionUploader> upload(
    Transaction transaction, {
    int maxConcurrentUploadCount = 128,
    bool dataOnly = false,
    bool dryRun = false,
  }) async* {
    final uploader = await getUploader(transaction,
        maxConcurrentUploadCount: maxConcurrentUploadCount,
        forDataOnly: dataOnly);

    if (!dryRun) {
      yield* uploader.upload();
    } else {
      yield uploader;
    }
  }

  /// Uploads the transaction in full. Useful for small data or wallet transactions.
  Future<void> post(
    Transaction transaction, {
    int maxConcurrentUploadCount = 128,
    bool dryRun = false,
  }) async {
    await upload(transaction,
            maxConcurrentUploadCount: maxConcurrentUploadCount, dryRun: dryRun)
        .drain();
  }
}
