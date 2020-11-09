import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() async {
  group('DataItem:', () {
    test('create, sign, and verify data items', () async {
      final wallet = await getTestWallet();

      final dataItem = DataItem.withStringData(
          owner: wallet.owner, data: 'HELLOWORLD_TEST_STRING')
        ..addTag('MyTag', '0')
        ..addTag('OtherTag', 'Foo')
        ..addTag('MyTag', '1');

      await dataItem.sign(wallet);

      expect(await dataItem.verify(), isTrue);

      dataItem.addTag('MyTag', '2');

      expect(await dataItem.verify(), isFalse);
    });
  });
}
