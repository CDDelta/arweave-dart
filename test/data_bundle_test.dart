@TestOn('browser')
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:arweave/src/utils/implementations/bundle_tag_parser_js.dart';
import 'package:arweave/utils.dart';
import 'package:test/test.dart';

import 'fixtures/test_wallet.dart';
import 'snapshots/data_bundle_test_snaphot.dart';

void main() async {
  group('DataItem:', () {
    test('create, sign, and verify data item', () async {
      final wallet = getTestWallet();
      final dataItem = DataItem.withBlobData(
          owner: await wallet.getOwner(),
          data: utf8.encode('HELLOWORLD_TEST_STRING') as Uint8List)
        ..addTag('MyTag', '0')
        ..addTag('OtherTag', 'Foo')
        ..addTag('MyTag', '1');

      await dataItem.sign(wallet);

      expect(await dataItem.verify(), isTrue);
    });

    test('comfirm data item with wrong signaure fails verify', () async {
      final wallet = getTestWallet();
      final dataItem = DataItem.withBlobData(
          owner: await wallet.getOwner(),
          data: utf8.encode('HELLOWORLD_TEST_STRING') as Uint8List)
        ..addTag('MyTag', '0')
        ..addTag('OtherTag', 'Foo')
        ..addTag('MyTag', '1');

      await dataItem.sign(wallet);
      dataItem.addTag('MyTag', '2');

      expect(await dataItem.verify(), isFalse);
    });
  });

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

  test('create data bundle', () async {
    final wallet = getTestWallet();

    final dataItemOne = DataItem.withBlobData(
        owner: await wallet.getOwner(),
        data: utf8.encode('HELLOWORLD_TEST_STRING_1') as Uint8List)
      ..addTag('MyTag', '0')
      ..addTag('OtherTag', 'Foo')
      ..addTag('MyTag', '1');
    await dataItemOne.sign(wallet);
    final dataItemTwo = DataItem.withBlobData(
        owner: await wallet.getOwner(),
        data: utf8.encode('HELLOWORLD_TEST_STRING_2') as Uint8List)
      ..addTag('MyTag', '0')
      ..addTag('OtherTag', 'Foo')
      ..addTag('MyTag', '1');
    await dataItemTwo.sign(wallet);
    final bundle = DataBundle(items: [dataItemOne, dataItemTwo]);
    expect(await bundle.verify(), isTrue);
  });

  test('create data bundle with large files', () async {
    final wallet = getTestWallet();
    final testData = utf8.encode(
        List.generate(5000 * pow(2, 10) as int, (index) => 'A')
            .reduce((acc, next) => acc += next)) as Uint8List;
    final testStart = DateTime.now();
    final dataItemOne =
        DataItem.withBlobData(owner: await wallet.getOwner(), data: testData)
          ..addTag('MyTag', '0')
          ..addTag('OtherTag', 'Foo')
          ..addTag('MyTag', '1');
    await dataItemOne.sign(wallet);
    final dataItemTwo =
        DataItem.withBlobData(owner: await wallet.getOwner(), data: testData)
          ..addTag('MyTag', '0')
          ..addTag('OtherTag', 'Foo')
          ..addTag('MyTag', '1');
    await dataItemTwo.sign(wallet);
    final bundle = DataBundle(items: [dataItemOne, dataItemTwo]);
    await bundle.asBlob();
    print(
        'Time Elapsed to bundle ${(DateTime.now().difference(testStart)).inSeconds} Seconds');
    final verify = await bundle.verify();

    expect(verify, isTrue);
  });
}
