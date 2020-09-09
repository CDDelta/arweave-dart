import 'dart:convert';
import 'dart:math';

import 'package:arweave/arweave.dart';
import 'package:arweave/src/api/api.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';
import 'transaction.dart';

part 'transaction_uploader.g.dart';

/// Maximum amount of chunks we will upload in the body.
const MAX_CHUNKS_IN_BODY = 1;

/// Amount we will delay on receiving an error response but do want to continue.
const ERROR_DELAY = 1000 * 40;

/// Errors from /chunk we should never try and continue on.
const FATAL_CHUNK_UPLOAD_ERRORS = [
  'invalid_json',
  'chunk_too_big',
  'data_path_too_big',
  'offset_too_big',
  'data_size_too_big',
  'chunk_proof_ratio_not_attractive',
  'invalid_proof'
];

class TransactionUploader {
  int _chunkIndex;
  bool _txPosted;
  Transaction _transaction;
  int _lastRequestTimeEnd;
  int _totalErrors;
  Random _random = Random();

  int lastResponseStatus;
  String lastResponseError;

  ArweaveApi _api;

  TransactionUploader(Transaction transaction, ArweaveApi api)
      : _transaction = transaction,
        _api = api {
    if (transaction.id == null) throw ArgumentError('Transaction not signed.');
    if (transaction.chunks == null)
      throw ArgumentError('Transaction chunks not prepared.');
  }

  TransactionUploader._(
      {int chunkIndex,
      bool txPosted,
      Transaction transaction,
      int lastRequestTimeEnd,
      this.lastResponseStatus,
      this.lastResponseError})
      : _chunkIndex = chunkIndex,
        _txPosted = txPosted,
        _transaction = transaction,
        _lastRequestTimeEnd = lastRequestTimeEnd;

  bool get isComplete =>
      _txPosted && _chunkIndex == _transaction.chunks.chunks.length;
  int get totalChunks => _transaction.chunks.chunks.length;
  int get uploadedChunks => _chunkIndex;
  double get percentageComplete => uploadedChunks / totalChunks * 100;

  /// Uploads a chunk of the transaction.
  /// On the first call this posts the transaction
  /// itself and on any subsequent calls uploads the
  /// next chunk until it completes.
  Future<void> uploadChunk() async {
    if (isComplete) throw StateError('Upload is already complete.');

    if (lastResponseError.isNotEmpty)
      _totalErrors++;
    else
      _totalErrors = 0;

    // We have been trying for about an hour receiving an
    // error every time, so eventually bail.
    if (_totalErrors == 100)
      throw StateError(
          'Unable to complete upload: $lastResponseStatus: $lastResponseError');

    var delay = lastResponseError.isEmpty
        ? 0
        : max(
            _lastRequestTimeEnd +
                ERROR_DELAY -
                DateTime.now().millisecondsSinceEpoch,
            ERROR_DELAY);

    if (delay > 0) {
      // Jitter delay because networks, subtract up to 30% from 40 seconds
      delay = delay - (delay * _random.nextDouble() * 0.30).toInt();
      await Future.delayed(Duration(milliseconds: delay));
    }

    lastResponseError = '';

    if (!_txPosted) {
      await _postTransaction();
      return;
    }

    final chunk = _transaction.getChunk(_chunkIndex);

    // TODO: Validate chunks
    // final chunkValid = await validatePath(this.transaction.chunks!.data_root, parseInt(chunk.offset), 0, parseInt(chunk.data_size), ArweaveUtils.b64UrlToBuffer(chunk.data_path))
    // if (!chunkValid)
    //  throw StateError('Unable to validate chunk: $_chunkIndex');

    // Catch network errors and turn them into objects with status -1 and an error message.
    final res = await _api.post('chunk', body: json.encode(chunk));

    _lastRequestTimeEnd = DateTime.now().millisecondsSinceEpoch;
    lastResponseStatus = res.statusCode;

    if (lastResponseStatus == 200) {
      _chunkIndex++;
    } else {
      lastResponseError = getResponseError(res);
      if (FATAL_CHUNK_UPLOAD_ERRORS.contains(lastResponseError)) {
        throw StateError(
            'Fatal error uploading chunk: $_chunkIndex: $lastResponseError');
      }
    }
  }

  Future<void> _postTransaction() async {
    final uploadInBody = totalChunks <= MAX_CHUNKS_IN_BODY;
    final txJson = _transaction.toJson();

    if (uploadInBody) {
      txJson['data'] = encodeBytesToBase64(_transaction.data);
      final res = await _api.post('tx', body: json.encode(txJson));

      _lastRequestTimeEnd = DateTime.now().millisecondsSinceEpoch;
      lastResponseStatus = res.statusCode;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // This transaction and it's data is uploaded.
        _txPosted = true;
        _chunkIndex = MAX_CHUNKS_IN_BODY;
        return;
      }

      throw StateError('Unable to upload transaction: ${res.statusCode}');
    }

    // Post the transaction with no data.
    txJson.remove('data');
    final res = await _api.post('tx', body: json.encode(txJson));

    _lastRequestTimeEnd = DateTime.now().millisecondsSinceEpoch;
    lastResponseStatus = res.statusCode;

    if (!(res.statusCode >= 200 && res.statusCode < 300))
      throw StateError('Unable to upload transaction: ${res.statusCode}');

    _txPosted = true;
  }

  factory TransactionUploader.deserialize(
          SerializedTransactionUploader serialized) =>
      TransactionUploader._(
        chunkIndex: serialized.chunkIndex,
        txPosted: serialized.txPosted,
        transaction: serialized.transaction,
        lastRequestTimeEnd: serialized.lastRequestTimeEnd,
        lastResponseError: serialized.lastResponseError,
        lastResponseStatus: serialized.lastResponseStatus,
      );
  SerializedTransactionUploader serialize() => SerializedTransactionUploader(
        chunkIndex: _chunkIndex,
        txPosted: _txPosted,
        transaction: _transaction,
        lastRequestTimeEnd: _lastRequestTimeEnd,
        lastResponseError: lastResponseError,
        lastResponseStatus: lastResponseStatus,
      );
  factory TransactionUploader.fromJson(Map<String, dynamic> json) =>
      TransactionUploader.deserialize(
          SerializedTransactionUploader.fromJson(json));
  Map<String, dynamic> toJson() => serialize().toJson();
}

@JsonSerializable()
class SerializedTransactionUploader {
  final int chunkIndex;
  final bool txPosted;
  final Transaction transaction;
  final int lastRequestTimeEnd;
  final int lastResponseStatus;
  final String lastResponseError;

  SerializedTransactionUploader(
      {this.chunkIndex,
      this.txPosted,
      this.transaction,
      this.lastRequestTimeEnd,
      this.lastResponseStatus,
      this.lastResponseError});

  factory SerializedTransactionUploader.fromJson(Map<String, dynamic> json) =>
      _$SerializedTransactionUploaderFromJson(json);
  Map<String, dynamic> toJson() => _$SerializedTransactionUploaderToJson(this);
}
