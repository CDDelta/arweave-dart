@TestOn('browser')

import 'dart:typed_data';

import 'package:arweave/src/utils/bundle_tag_parser.dart';
import 'package:arweave/src/models/tag.dart';
import 'package:arweave/utils.dart';
import 'package:test/test.dart';

import 'snapshots/data_bundle_test_snaphot.dart';
import 'deserialize_tags.dart';

void main() {
  group('bundle tag parser', () {
    test('check if avro serializes tags correctly', () {
      final buffer = serializeTags(tags: testTagsSnapshot);
      expect(buffer, equals(testTagsBufferSnapshot));
    });

    test('check if avro fails serialization when wrong data is given', () {
      final testTags = [
        Tag(encodeStringToBase64('wrong'), encodeStringToBase64('wrong'))
      ];
      final buffer = serializeTags(tags: testTags);

      expect(
        () => deserializeTags(buffer: [Uint8List.fromList(buffer), 0]),
        throwsException,
      );
    });

    test('check if avro deserializes tags correctly', () {
      final tags = deserializeTags(buffer: testTagsBufferSnapshot);
      expect(tags, equals(testTagsSnapshot));
    });
  });
}
