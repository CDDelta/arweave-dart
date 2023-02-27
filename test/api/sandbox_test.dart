import 'dart:typed_data';

import 'package:arweave/src/api/sandbox.dart'
    show fromB64Url, toB32, getSandboxSubdomain;
import 'package:test/test.dart';

import 'sandbox_test_utils.dart' as sandbox_test_utils;

void main() {
  group('fromB64Url method', () {
    test('takes a base64Url and returns the bytes of it', () {
      final input = 'x0r3HMmsWeoicM81PFQI9DONnUt-XjLgEKK3DsoDL_M';
      final expected = sandbox_test_utils.b64UrlToBytes(input);
      final actual = fromB64Url(input);
      expect(actual, expected);
    });
  });
  group('toB32 method', () {
    test('takes bytes and returns the base32 string', () {
      final input = Uint8List.fromList(
        [
          199,
          74,
          247,
          28,
          201,
          172,
          89,
          234,
          34,
          112,
          207,
          53,
          60,
          84,
          8,
          244,
          51,
          141,
          157,
          75,
          126,
          94,
          50,
          224,
          16,
          162,
          183,
          14,
          202,
          3,
          47,
          243
        ],
      );
      final expected = sandbox_test_utils.bytesToB32String(input);
      final actual = toB32(input);
      expect(actual, expected);
    });
  });
  group('getSandboxedSubdomain method', () {
    test('should return the correct sandbox subdomain', () {
      final input = 'x0r3HMmsWeoicM81PFQI9DONnUt-XjLgEKK3DsoDL_M';
      final expected = sandbox_test_utils.getSandboxSubdomain(input);
      final actual = getSandboxSubdomain(input);
      expect(actual, expected);
    });
  });
}
