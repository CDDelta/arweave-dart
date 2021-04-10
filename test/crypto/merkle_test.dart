import 'dart:io';
import 'dart:typed_data';

import 'package:arweave/src/crypto/crypto.dart';
import 'package:arweave/utils.dart' as utils;
import 'package:convert/convert.dart';
import 'package:test/test.dart';

import '../utils.dart';

const rootB64 = 't-GCOnjPWxdox950JsrFMu3nzOE4RktXpMcIlkqSUTw';
final root = utils.decodeBase64ToBytes(rootB64);
const pathB64 =
    '7EAC9FsACQRwe4oIzu7Mza9KjgWKT4toYxDYGjWrCdp0QgsrYS6AueMJ_rM6ZEGslGqjUekzD3WSe7B5_fwipgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAnH6dASdQCigcL43lp0QclqBaSncF4TspuvxoFbn2L18EXpQrP1wkbwdIjSSWQQRt_F31yNvxtc09KkPFtzMKAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAIHiHU9QwOImFzjqSlfxkJJCtSbAox6TbbFhQvlEapSgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAA';
final path = utils.decodeBase64ToBytes(pathB64);

const offset = 262143;
const dataSize = 836907;

void main() async {
  group('merkle', () {
    test('build valid tree and proofs', () async {
      final data = await File('test/fixtures/rebar3').readAsBytes();
      final root = await generateTree(data);
      final proofs = generateProofs(root);
      expect(utils.encodeBytesToBase64(root.id!), equals(rootB64));
      expect(utils.encodeBytesToBase64(proofs[0].proof), equals(pathB64));
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('validate a valid data path against a valid data root', () async {
      expect(await validatePath(root, offset, 0, dataSize, path), isTrue);
    });

    test('reject invalid data root', () async {
      // Use hex here to workaround problems with decoding invalid base64.
      final invalidRoot = hex.decode(
          '957e4aee001494832dda16189285d5ae39953279e317a3fa739b28bfa98fa829');
      expect(
          await validatePath(
              invalidRoot as Uint8List, offset, 0, dataSize, path),
          isFalse);
    });

    test('reject invalid data path', () async {
      // Use hex here for same reason above.
      final invalidPath = hex.decode(
          '55449db9b156d9c4efbebe6ce95192536a317edc666bbedb46f8a5b397ea8a4763e2a9cff31106d874102b265e6465b96fd58d1659834414f24c9f0d9c7403ded2c773657072d7ddad76e450e0c03404eb38fea9f1136548d4f9d2330a7522b2986d0cf32bfd8372c2a0f0784176b07113faabd5f9bb59e723b185325caec680b8a76d735a2eefebc7f5afbdf05c759d1fbe9580235bb74944503835a56f2c62f8baa5dc0075335d40870086a90ed89049d8ac2d9717a68f813a34c2a0f708b6a501ede822a55f74f9ad07557744edf1ccf1ae43940405bd27c5c62bd8922e88f82d6665df3e1c288172647ee25202330aef4877c8c8a0ef779557606946b845');
      expect(
          await validatePath(
              root, offset, 0, dataSize, invalidPath as Uint8List),
          isFalse);
    });

    test(
        'chunk data larger than the max chunk size with one extra zero length chunk',
        () async {
      final data = randomBytes(MAX_CHUNK_SIZE * 4);
      final chunks = await chunkData(data);

      expect(chunks.length, equals(5));

      for (final chunk in chunks.take(4)) {
        expect(chunk.maxByteRange - chunk.minByteRange, equals(MAX_CHUNK_SIZE));
      }

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
