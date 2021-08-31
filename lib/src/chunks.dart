import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/src/models/models.dart';
import 'package:arweave/utils.dart';

import 'api/api.dart';

class ArweaveChunksApi {
  final ArweaveApi _api;

  ArweaveChunksApi(ArweaveApi api) : _api = api;

  Future<TransactionOffsetResponse> getTransactionOffset(String id) async {
    final res = await _api.get('tx/$id/offset');
    return TransactionOffsetResponse.fromJson(json.decode(res.body));
  }

  Future<TransactionChunkResponse> getChunk(int offset) async {
    final res = await _api.get('chunk/$offset');
    return TransactionChunkResponse.fromJson(json.decode(res.body));
  }

  Future<Uint8List> getChunkData(int offset) async {
    final chunk = await getChunk(offset);
    return decodeBase64ToBytes(chunk.chunk);
  }

  int firstChunkOffset(TransactionOffsetResponse offsetResponse) =>
      int.parse(offsetResponse.offset) - int.parse(offsetResponse.size) + 1;

  Future<Uint8List> downloadChunkedData(String id) async {
    final res = await getTransactionOffset(id);

    final size = int.parse(res.size);
    final endOffset = int.parse(res.offset);
    final startOffset = endOffset - size + 1;

    final data = Uint8List(size);
    var offsetPos = startOffset;

    while (offsetPos < endOffset) {
      final chunkData = await getChunkData(offsetPos);
      data.setAll(offsetPos, chunkData);
      offsetPos += chunkData.length;
    }

    return data;
  }
}
