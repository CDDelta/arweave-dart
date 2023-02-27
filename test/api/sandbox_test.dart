import 'dart:typed_data';

import 'package:arweave/src/api/sandbox.dart'
    show b64UrlToBytes, bytesToB32String, getSandboxSubdomain;
import 'package:test/test.dart';

import 'sandbox_test_utils.dart' as sandbox_test_utils;

/// TODO: update the test cases
// typedef SandboxDomain = String;
// typedef TxId = String;
// final Map<SandboxDomain, TxId> testBaseline = {
//   'f3valm4d36fd6w4uhuibvjrnwra3entolqiojhlcsghhnp32pstq':
//       'LuoFs4Pfij9blD0QGqYttEGyNm5cEOSdYpGOdr96fKc',
//   'flqlektwzxrgtlpmce53dnnej2clq5njgbbh2tztjbs4aqz3owjq':
//       'KuCyKnbN4mmt7BE7sbWkToS4dakwQn1PM0hlwEM7dZM',
//   '6c6fodlctydufzmbsmzykkweigtk5w5zrqauiyetmcaqukgm':
//       '8LxXDWKeB_0LlgZMzhSrEQaau27-mMAURgk2CBCijMY',
//   'oerew5mrlsda5yrsmml3vwpxb6tvpobbzyfb4l5pucthyyhmbe':
//       'cSJLdZFchg7iMmMXutn3D6dXuCHOCh4_vr6CmfGDsCc',
//   'vxxdwy6scapybz7ekkw32ua5naseioagnu4uutbq3cftvivl':
//       're47Y9IQH4-Dn5FKtvVAdaCRE-OAZtOUpMMNiLOqKrw',
//   'bujjxactpuy7cmm3ul6fjuwuqnbymloddqvsjswhxsvkd255bq':
//       'DRKbgFN9MfExm6L8VNLUg0OGLcMcKyTKx7yq_oeu9DM',
//   'b4zy2sx2upeczfaxpscxfuglgh2mljo4gu6ycuhujgz5yjbc':
//       'DzONSvqjyCyUF3yFctDLMfTFpd_w-1PYFQ9Emz3CQic',
//   'kruhyqr3j24gxknxda2pbqa6ru2ctocctwr4z3hesnjukreb':
//       'VGh8QjtOuGuptxg08MAejTQpuEKdo8zs_5JNTRUSB_Q',
// };

void main() {
  group('fromB64Url method', () {
    test('takes a base64Url and returns the bytes of it', () {
      final input = 'x0r3HMmsWeoicM81PFQI9DONnUt-XjLgEKK3DsoDL_M';
      final expected = sandbox_test_utils.b64UrlToBytes(input);
      final actual = b64UrlToBytes(input);
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
      final actual = bytesToB32String(input);
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
