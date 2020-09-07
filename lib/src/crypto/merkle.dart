import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class Chunk {
  final Uint8List dataHash;
  final int minByteRange;
  final int maxByteRange;

  Chunk(this.dataHash, this.minByteRange, this.maxByteRange);
}

const MAX_CHUNK_SIZE = 256 * 1024;
const MIN_CHUNK_SIZE = 32 * 1024;
const _NOTE_SIZE = 32;
const _HASH_SIZE = 32;

Future<List<Chunk>> chunkData(Uint8List data) async {
  final chunks = <Chunk>[];

  var rest = data;
  var cursor = 0;

  while (rest.lengthInBytes >= MAX_CHUNK_SIZE) {
    var chunkSize = MAX_CHUNK_SIZE;

    // If the total bytes left will produce a chunk < MIN_CHUNK_SIZE,
    // then adjust the amount we put in this 2nd last chunk.
    var nextChunkSize = rest.lengthInBytes - MAX_CHUNK_SIZE;
    if (nextChunkSize > 0 && nextChunkSize < MIN_CHUNK_SIZE)
      chunkSize = (rest.lengthInBytes / 2).ceil();

    final chunk = Uint8List.sublistView(rest, 0, chunkSize);
    final dataHash = sha256.convert(chunk).bytes;
    cursor += chunk.lengthInBytes;
    chunks.add(Chunk(dataHash, cursor - chunk.lengthInBytes, cursor));
    rest = Uint8List.sublistView(rest, chunkSize);
  }

  chunks.add(
      Chunk(sha256.convert(rest).bytes, cursor, cursor + rest.lengthInBytes));

  return chunks;
}
