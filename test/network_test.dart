import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

void main() {
  final client = Arweave();

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
