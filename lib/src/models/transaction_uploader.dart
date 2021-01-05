import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:arweave/src/api/api.dart';

import '../utils.dart';
import 'transaction.dart';

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
  int _chunkIndex = 0;
  bool _txPosted = false;
  int _lastRequestTimeEnd = 0;
  int _totalErrors = 0;

  int lastResponseStatus = 0;
  String lastResponseError = '';

  final Transaction _transaction;
  final ArweaveApi _api;
  final Random _random = Random();

  TransactionUploader(Transaction transaction, ArweaveApi api,
      {bool forDataOnly = false})
      : _transaction = transaction,
        _api = api,
        _txPosted = forDataOnly {
    if (transaction.id == null) throw ArgumentError('Transaction not signed.');
    if (transaction.chunks == null) {
      throw ArgumentError('Transaction chunks not prepared.');
    }
  }

  TransactionUploader._(
      {ArweaveApi api,
      int chunkIndex,
      bool txPosted,
      Transaction transaction,
      int lastRequestTimeEnd,
      this.lastResponseStatus,
      this.lastResponseError})
      : _api = api,
        _chunkIndex = chunkIndex,
        _txPosted = txPosted,
        _transaction = transaction,
        _lastRequestTimeEnd = lastRequestTimeEnd;

  bool get isComplete =>
      _txPosted && _chunkIndex >= _transaction.chunks.chunks.length;
  int get totalChunks => _transaction.chunks.chunks.length;
  int get uploadedChunks => _chunkIndex;

  /// The progress of the current upload ranging from 0 to 1.
  double get progress => uploadedChunks / totalChunks;

  /// Uploads a chunk of the transaction.
  /// On the first call this posts the transaction
  /// itself and on any subsequent calls uploads the
  /// next chunk until it completes.
  Future<void> uploadChunk() async {
    if (isComplete) throw StateError('Upload is already complete.');

    if (lastResponseError.isNotEmpty) {
      _totalErrors++;
    } else {
      _totalErrors = 0;
    }

    // We have been trying for about an hour receiving an
    // error every time, so eventually bail.
    if (_totalErrors == 100) {
      throw StateError(
          'Unable to complete upload: $lastResponseStatus: $lastResponseError');
    }

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
      // TODO: Make async
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

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw StateError('Unable to upload transaction: ${res.statusCode}');
    }

    _txPosted = true;
  }

  static Future<TransactionUploader> deserialize(
      Map<String, dynamic> json, Uint8List data, ArweaveApi api) async {
    final transaction = json['transaction'] != null
        ? Transaction.fromJson(json['transaction'])
        : null;

    await transaction.setData(data);

    return TransactionUploader._(
      api: api,
      chunkIndex: json['chunkIndex'] as int,
      txPosted: json['txPosted'] as bool,
      transaction: transaction,
      lastRequestTimeEnd: json['lastRequestTimeEnd'] as int,
      lastResponseStatus: json['lastResponseStatus'] as int,
      lastResponseError: json['lastResponseError'] as String,
    );
  }

  Map<String, dynamic> serialize() => <String, dynamic>{
        'chunkIndex': _chunkIndex,
        'txPosted': _txPosted,
        'transaction': _transaction.toJson()..['data'] = null,
        'lastRequestTimeEnd': _lastRequestTimeEnd,
        'lastResponseStatus': lastResponseStatus,
        'lastResponseError': lastResponseError,
      };
}
