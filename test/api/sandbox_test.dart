import 'dart:typed_data';

import 'package:arweave/src/api/sandbox.dart' as sandbox;
import 'package:test/test.dart';

import 'sandbox_test_utils.dart' as sandbox_test_utils;

typedef TxId = String;
final List<TxId> validTxIds = [
  'LuoFs4Pfij9blD0QGqYttEGyNm5cEOSdYpGOdr96fKc',
  'KuCyKnbN4mmt7BE7sbWkToS4dakwQn1PM0hlwEM7dZM',
  '8LxXDWKeB_0LlgZMzhSrEQaau27-mMAURgk2CBCijMY',
  'cSJLdZFchg7iMmMXutn3D6dXuCHOCh4_vr6CmfGDsCc',
  're47Y9IQH4-Dn5FKtvVAdaCRE-OAZtOUpMMNiLOqKrw',
  'DRKbgFN9MfExm6L8VNLUg0OGLcMcKyTKx7yq_oeu9DM',
  'DzONSvqjyCyUF3yFctDLMfTFpd_w-1PYFQ9Emz3CQic',
  'VGh8QjtOuGuptxg08MAejTQpuEKdo8zs_5JNTRUSB_Q',
];

void main() {
  group('b64UrlToB64 method', () {
    test('takes a base64Url and returns a base64', () {
      final input = 'x0r3HMmsWeoicM81PFQI9DONnUt-XjLgEKK3DsoDL_M';
      final expected = sandbox_test_utils.b64UrlToB64(input);
      final actual = sandbox.b64UrlToB64(input);
      expect(actual, expected);
    });
  });

  group('b64ToBytes method', () {
    test('takes a base64 and returns the bytes of it', () {
      final input = 'x0r3HMmsWeoicM81PFQI9DONnUt-XjLgEKK3DsoDL_M';
      final expected = sandbox_test_utils.b64ToBytes(input);
      final actual = sandbox.b64ToBytes(input);
      expect(actual, expected);
    });
  });

  group('b64UrlToBytes method', () {
    test('takes a base64Url and returns the bytes of it', () {
      final input = 'x0r3HMmsWeoicM81PFQI9DONnUt-XjLgEKK3DsoDL_M';
      final expected = sandbox_test_utils.b64UrlToBytes(input);
      final actual = sandbox.b64UrlToBytes(input);
      expect(actual, expected);
    });
  });

  group('bytesToB32String method', () {
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
      final actual = sandbox.bytesToB32String(input);
      expect(actual, expected);
    });
  });

  group('getSandboxedSubdomain method', () {
    test('should return the correct sandbox subdomain', () {
      for (var input in validTxIds) {
        final expected = sandbox_test_utils.getSandboxSubdomain(input);
        final actual = sandbox.getSandboxSubdomain(input);
        expect(actual, expected);
      }
    });
  });
}
