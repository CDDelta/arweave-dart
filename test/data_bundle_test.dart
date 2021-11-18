@TestOn('browser')
import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:arweave/src/utils/implementations/bundle_tag_parser_js.dart';
import 'package:test/test.dart';

import 'fixtures/test_wallet.dart';
import 'snapshots/data_bundle_test_snaphot.dart';

void main() async {
  group('DataItem:', () {
    test('create, sign, and verify data items', () async {
      final wallet = getTestWallet();
      final dataItem = DataItem.withBlobData(
          owner: await wallet.getOwner(),
          data: utf8.encode('HELLOWORLD_TEST_STRING') as Uint8List)
        ..addTag('MyTag', '0')
        ..addTag('OtherTag', 'Foo')
        ..addTag('MyTag', '1');

      await dataItem.sign(wallet);

      expect(await dataItem.verify(), isTrue);

      dataItem.addTag('MyTag', '2');

      expect(await dataItem.verify(), isFalse);
    });
  });

  test('check if avro serializes tags correctly', () {
    final buffer = serializeTags(tags: testTagsSnapshot);
    expect(buffer, equals(testTagsBufferSnapshot));
  });
  test('check if avro deserializes tags correctly', () {
    final tags = deserializeTags(buffer: testTagsBufferSnapshot);
    expect(tags, equals(testTagsSnapshot));
  });
  test('create data bundle', () async {
    final wallet = getTestWallet();

    final dataItemOne = DataItem.withBlobData(
        owner: await wallet.getOwner(),
        data: utf8.encode('HELLOWORLD_TEST_STRING_1') as Uint8List)
      ..addTag('MyTag', '0')
      ..addTag('OtherTag', 'Foo')
      ..addTag('MyTag', '1');
    final dataItemTwo = DataItem.withBlobData(
        owner: await wallet.getOwner(),
        data: utf8.encode('HELLOWORLD_TEST_STRING_2') as Uint8List)
      ..addTag('MyTag', '0')
      ..addTag('OtherTag', 'Foo')
      ..addTag('MyTag', '1');

    final bundle = DataBundle(items: [dataItemOne, dataItemTwo]);
  });
}
