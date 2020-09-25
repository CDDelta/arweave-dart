import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

Future<Uint8List> deepHash(List<Object> data) async {
  final tag = utf8.encode('list') + utf8.encode(data.length.toString());
  return _deepHashChunks(
    data,
    await _sha384(tag),
  );
}

Future<Uint8List> _deepHashChunks(
    Iterable<Object> chunks, Uint8List acc) async {
  // If we're at the end of the chunks list, return.
  if (chunks.isEmpty) return acc;

  final hashPair = acc +
      // If the current chunk is not a byte list, we assume it's a nested byte list.
      (chunks.first is! Uint8List
          ? await deepHash(chunks.first)
          : await _deepHashChunk(chunks.first));

  final newAcc = await _sha384(hashPair);
  return _deepHashChunks(chunks.skip(1), newAcc);
}

Future<List<int>> _deepHashChunk(Uint8List data) async {
  final tag = utf8.encode('blob') + utf8.encode(data.lengthInBytes.toString());
  final taggedHash = await _sha384(tag) + await _sha384(data);
  return _sha384(taggedHash);
}

Future<List<int>> _sha384(List<int> data) async {
  final hash = await sha384.hash(data);
  return hash.bytes;
}
