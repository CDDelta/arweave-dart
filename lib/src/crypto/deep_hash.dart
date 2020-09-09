import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

Future<Uint8List> deepHash(List<Object> data) async {
  final tag = utf8.encode('list') + utf8.encode(data.length.toString());
  return _deepHashChunks(data, sha384.convert(tag).bytes);
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

  final newAcc = sha384.convert(hashPair).bytes;
  return _deepHashChunks(chunks.skip(1), newAcc);
}

Future<Uint8List> _deepHashChunk(Uint8List data) async {
  final tag = utf8.encode('blob') + utf8.encode(data.lengthInBytes.toString());
  final taggedHash = sha384.convert(tag).bytes + sha384.convert(data).bytes;
  return sha384.convert(taggedHash).bytes;
}
