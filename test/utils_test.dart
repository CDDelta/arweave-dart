import 'package:arweave/src/utils.dart';
import 'package:test/test.dart';

void main() async {
  group('Utils:', () {
    test('longTo8ByteArray', () async {
      var long = 9;
      expect(longTo8ByteArray(long), [9, 0, 0, 0, 0, 0, 0, 0]);
    });
  });
}
