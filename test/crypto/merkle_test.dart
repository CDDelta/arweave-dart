import 'dart:io';

import 'package:arweave/src/crypto/crypto.dart';
import 'package:arweave/utils.dart' as utils;
import 'package:test/test.dart';

import '../utils.dart';

const rootB64 = "t-GCOnjPWxdox950JsrFMu3nzOE4RktXpMcIlkqSUTw";
final root = utils.decodeBase64ToBytes(rootB64);
const pathB64 =
    "7EAC9FsACQRwe4oIzu7Mza9KjgWKT4toYxDYGjWrCdp0QgsrYS6AueMJ_rM6ZEGslGqjUekzD3WSe7B5_fwipgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAnH6dASdQCigcL43lp0QclqBaSncF4TspuvxoFbn2L18EXpQrP1wkbwdIjSSWQQRt_F31yNvxtc09KkPFtzMKAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAIHiHU9QwOImFzjqSlfxkJJCtSbAox6TbbFhQvlEapSgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAA";
final path = utils.decodeBase64ToBytes(pathB64);

const offset = 262143;
const dataSize = 836907;

void main() async {
  group('merkle', () {
    test('build valid tree and proofs', () async {
      final data = await File('test/fixtures/rebar3').readAsBytes();
      final root = await generateTree(data);
      final proofs = await generateProofs(root);
      expect(utils.encodeBytesToBase64(root.id), equals(rootB64));
      expect(utils.encodeBytesToBase64(proofs[0].proof), equals(pathB64));
    });

    test(
        'chunk data larger than the max chunk size with one extra zero length chunk',
        () async {
      final data = randomBytes(MAX_CHUNK_SIZE * 4);
      final chunks = await chunkData(data);

      expect(chunks.length, equals(5));

      for (final chunk in chunks.take(4))
        expect(chunk.maxByteRange - chunk.minByteRange, equals(MAX_CHUNK_SIZE));

      expect(chunks.last.maxByteRange - chunks.last.minByteRange, equals(0));
    });

    test(
        'chunk data while adjusting the last two chunks to avoid chunks smaller than the minimum chunk size',
        () async {
      final data = randomBytes(MAX_CHUNK_SIZE + MIN_CHUNK_SIZE - 1);
      final chunks = await chunkData(data);

      expect(chunks.length, equals(2));

      final chunk1Size = chunks[0].maxByteRange - chunks[0].minByteRange;
      final chunk2Size = chunks[1].maxByteRange - chunks[1].minByteRange;

      expect(chunk1Size, greaterThan(MIN_CHUNK_SIZE));
      expect(chunk1Size, equals(chunk2Size + 1));
      expect(chunk2Size, greaterThanOrEqualTo(MIN_CHUNK_SIZE));
    });
  });
}
