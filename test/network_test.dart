import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  Arweave client;

  setUp(() {
    client = getArweaveClient();
  });

  group('network:', () {
    test('get info', () async {
      final info = await client.network.getInfo();
      expect(info.height, greaterThan(0));
    });

    test('get peers', () async {
      final peers = await client.network.getPeers();
      expect(peers, isNotNull);
    });
  });
}
