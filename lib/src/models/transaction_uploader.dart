import 'dart:async';
import 'dart:convert';

import 'package:arweave/arweave.dart';
import 'package:retry/retry.dart';

import '../api/api.dart';
import '../crypto/crypto.dart';
import '../utils.dart';

/// Maximum amount of chunks we will upload in the body.
const maxChunksInBody = 1;

/// Errors from /chunk we should never try and continue on.
const fatalChunkUploadErrors = [
  'invalid_json',
  'chunk_too_big',
  'data_path_too_big',
  'offset_too_big',
  'data_size_too_big',
  'chunk_proof_ratio_not_attractive',
  'invalid_proof'
];

class TransactionUploader {
  final Transaction _transaction;
  final ArweaveApi _api;

  bool get isComplete => _txPosted && uploadedChunks >= totalChunks;
  int get totalChunks => _transaction.chunks!.chunks.length;
  int get uploadedChunks => _uploadedChunks;

  /// The progress of the current upload ranging from 0 to 1.
  ///
  /// Additionally accounts for the posting of the transaction header, therefore
  /// data only uploads will start with a progress > 0.
  double get progress =>
      ((_txPosted ? 1 : 0) + uploadedChunks) / (1 + totalChunks);

  final int maxConcurrentChunkUploadCount;

  bool _txPosted = false;
  int _uploadedChunks = 0;

  TransactionUploader(Transaction transaction, ArweaveApi api,
      {this.maxConcurrentChunkUploadCount = 128, bool forDataOnly = false})
      : _transaction = transaction,
        _api = api,
        _txPosted = forDataOnly {
    if (transaction.chunks == null) {
      throw ArgumentError('Transaction chunks not prepared.');
    } else if (forDataOnly && totalChunks == 0) {
      throw ArgumentError('Transaction has no chunks.');
    }
  }

  /// Uploads the transaction in full, returning a stream of events signaling
  /// the status of the upload on every completed chunk upload.
  Stream<TransactionUploader> upload() async* {
    if (!_txPosted) {
      await retry(() => _postTransactionHeader());

      yield this;

      if (isComplete) {
        return;
      }
    }

    final chunkUploadCompletionStreamController = StreamController<int>();
    int chunkIndex = 0;

    Future<void> uploadChunkAndNotifyOfCompletion(int chunkIndex) async {
      try {
        await retry(
          () => _uploadChunk(chunkIndex),
          onRetry: (exception) {
            print(
              'Retrying for chunk $chunkIndex on exception ${exception.toString()}',
            );
          },
        );

        chunkUploadCompletionStreamController.add(chunkIndex);
      } catch (err) {
        print('Chunk upload failed at $chunkIndex');
        chunkUploadCompletionStreamController.addError(err);
      }
    }

    // Initiate as many chunk uploads as we can in parallel at the start.
    chunkUploadCompletionStreamController.onListen = () {
      while (chunkIndex < totalChunks &&
          chunkIndex < maxConcurrentChunkUploadCount) {
        uploadChunkAndNotifyOfCompletion(chunkIndex);
        chunkIndex++;
      }
    };

    // Start a new chunk upload if there are still any left to upload and
    // notify the stream consumer of chunk upload completion events.
    yield* chunkUploadCompletionStreamController.stream
        .map((completedChunkIndex) {
      _uploadedChunks++;

      if (chunkIndex < totalChunks) {
        uploadChunkAndNotifyOfCompletion(chunkIndex);
        chunkIndex++;
      } else if (isComplete) {
        chunkUploadCompletionStreamController.close();
      }

      return this;
    });
  }

  /// Posts the transaction header to Arweave as well as the transaction data, if it can fit in the body.
  ///
  /// Throws an [Exception] if the transaction header could not be posted.
  Future<void> _postTransactionHeader() async {
    final uploadInBody = totalChunks <= maxChunksInBody;
    final txJson = _transaction.toJson();

    if (uploadInBody) {
      if (_transaction.tags.contains(Tag('Bundle-Format', 'binary'))) {
        txJson['data'] = _transaction.data.buffer;
      } else {
        txJson['data'] = encodeBytesToBase64(_transaction.data);
      }

      final res = await _api.post('tx', body: json.encode(txJson));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // This transaction and it's data is uploaded.
        _txPosted = true;
        _uploadedChunks = totalChunks;
        return;
      }
      throw Exception('Unable to upload transaction: ${res.statusCode}');
    }

    // Post the transaction with no data.
    txJson.remove('data');
    final res = await _api.post('tx', body: json.encode(txJson));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception('Unable to upload transaction: ${res.statusCode}');
    }

    _txPosted = true;
  }

  /// Uploads the specified chunk onto Arweave.
  ///
  /// Throws a [StateError] if the chunk being uploaded encounters a fatal error
  /// during upload and an [Exception] if a non-fatal error is encountered.
  Future<void> _uploadChunk(int chunkIndex) async {
    final chunk = await _transaction.getChunk(chunkIndex);

    final chunkValid = await validatePath(
        _transaction.chunks!.dataRoot,
        int.parse(chunk.offset),
        0,
        int.parse(chunk.dataSize),
        decodeBase64ToBytes(chunk.dataPath));

    if (!chunkValid) {
      throw StateError('Unable to validate chunk: $chunkIndex');
    }

    final res = await _api.post('chunk', body: json.encode(chunk));

    if (res.statusCode != 200) {
      final responseError = getResponseError(res);

      if (fatalChunkUploadErrors.contains(responseError)) {
        throw StateError(
            'Fatal error uploading chunk: $chunkIndex: ${res.statusCode} $responseError');
      } else {
        throw Exception(
            'Received non-fatal error while uploading chunk $chunkIndex: ${res.statusCode} $responseError');
      }
    }
  }
}
