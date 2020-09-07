import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

Future<Uint8List> deepHash(List<Object> data) async {
  final tag = utf8.encode('list') + utf8.encode(data.length.toString());
  return _deepHashChunks(data, 0, sha384.convert(tag).bytes);
}

Future<Uint8List> _deepHashChunks(
    List<Object> chunks, int i, Uint8List acc) async {
  // If we're at the end of the chunks list, return.
  if (i >= chunks.length - 1) return acc;

  final hashPair = acc +
      // If the current chunk is not a byte list, we assume it's an object list.
      (chunks[i] is! Uint8List
          ? await deepHash(chunks[i])
          : await _deepHashChunk(chunks[i]));
  final newAcc = sha384.convert(hashPair).bytes;

  return _deepHashChunks(chunks, i + 1, newAcc);
}

Future<Uint8List> _deepHashChunk(Uint8List data) async {
  final tag = utf8.encode('blob') + utf8.encode(data.lengthInBytes.toString());
  final taggedHash = sha384.convert(tag).bytes + sha384.convert(data).bytes;
  return sha384.convert(taggedHash).bytes;
}
