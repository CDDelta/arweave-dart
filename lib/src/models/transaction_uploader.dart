import 'package:arweave/src/api/api.dart';

import 'transaction.dart';

class TransactionUploader {
  int _chunkIndex;
  bool _txPosted;
  Transaction _transaction;

  ArweaveApi _api;

  TransactionUploader(Transaction transaction, ArweaveApi api)
      : _transaction = transaction,
        _api = api {
    if (transaction.id == null) throw ArgumentError('Transcation not signed.');
    if (transaction.format == 2 && transaction.chunks == null)
      throw ArgumentError('Transaction chunks not prepared.');
  }

  bool get isComplete =>
      _txPosted && _chunkIndex == _transaction.chunks.chunks.length;
  int get totalChunks => _transaction.chunks.chunks.length;
  int get uploadedChunks => _chunkIndex;
  double get percentageComplete => uploadedChunks / totalChunks * 100;

  Future<void> _postTransaction() {
    //final uploadInBody = totalChunks <= MAX_CHUNKS_IN_BODY;

    //if (uploadInBody) {}
  }

  Future<void> uploadChunk() {
    if (isComplete) throw StateError('Upload is already complete.');
  }
}
