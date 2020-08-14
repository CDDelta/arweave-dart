import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  Arweave client;

  setUp(() {
    client = getArweaveClient();
  });

  /*group('AR', () {
    group('format winston as AR', () {
      test('smaller than one AR', () {
        expect(client.winstonToAr(BigInt.from(1)), equals('0.000000000001'));
        expect(client.winstonToAr(BigInt.from(123)), equals('0.000000000123'));
      });

      test('at least one AR', () {
        expect(client.winstonToAr(BigInt.from(1000000000000)), equals('1'));
        expect(client.winstonToAr(BigInt.from(1100000000000)), equals('1.1'));
      });
    });
  });*/
}
