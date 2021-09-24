import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() async {
  group('DataItem:', () {
    test('create, sign, and verify data items', () async {
      final wallet = await getTestWallet();
      print(await wallet.getOwner());
      print(await wallet.getAddress());
      final dataItem = DataItem.withBlobData(
          owner: await wallet.getOwner(),
          data: utf8.encode('HELLOWORLD_TEST_STRING') as Uint8List)
        ..addTag('MyTag', '0')
        ..addTag('OtherTag', 'Foo')
        ..addTag('MyTag', '1');
      final dataItemBinary = dataItem.asBinary();

      await dataItem.sign(wallet);

      expect(await dataItem.verify(), isTrue);

      dataItem.addTag('MyTag', '2');

      expect(await dataItem.verify(), isFalse);
    });
  });
  test('create data bundle', () async {
    final wallet = await getTestWallet();

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
    final bundleBlob = bundle.asBlob(wallet);
  });
}
