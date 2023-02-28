import 'dart:typed_data';

import 'package:arweave/src/api/sandbox.dart' as sandbox;
import 'package:test/test.dart';

typedef B64 = String;
typedef B64Url = String;
typedef B32 = String;
typedef Bytes = Uint8List;
typedef TxId = B64Url;
typedef Subdomain = B32;

class DataRepresentations {
  final TxId txId;
  final B64 b64;
  final B32 b32;
  final Bytes bytes;

  DataRepresentations({
    required this.txId,
    required this.b64,
    required this.b32,
    required this.bytes,
  });
}

final List<DataRepresentations> expectations = [
  DataRepresentations(
    txId: 'LuoFs4Pfij9blD0QGqYttEGyNm5cEOSdYpGOdr96fKc',
    b64: "LuoFs4Pfij9blD0QGqYttEGyNm5cEOSdYpGOdr96fKc=",
    b32: "f3valm4d36fd6w4uhuibvjrnwra3entolqiojhlcsghhnp32pstq",
    bytes: Uint8List.fromList([
      46,
      234,
      5,
      179,
      131,
      223,
      138,
      63,
      91,
      148,
      61,
      16,
      26,
      166,
      45,
      180,
      65,
      178,
      54,
      110,
      92,
      16,
      228,
      157,
      98,
      145,
      142,
      118,
      191,
      122,
      124,
      167
    ]),
  ),
  DataRepresentations(
    txId: 'KuCyKnbN4mmt7BE7sbWkToS4dakwQn1PM0hlwEM7dZM',
    b64: 'KuCyKnbN4mmt7BE7sbWkToS4dakwQn1PM0hlwEM7dZM=',
    b32: 'flqlektwzxrgtlpmce53dnnej2clq5njgbbh2tztjbs4aqz3owjq',
    bytes: Uint8List.fromList([
      42,
      224,
      178,
      42,
      118,
      205,
      226,
      105,
      173,
      236,
      17,
      59,
      177,
      181,
      164,
      78,
      132,
      184,
      117,
      169,
      48,
      66,
      125,
      79,
      51,
      72,
      101,
      192,
      67,
      59,
      117,
      147
    ]),
  ),
  DataRepresentations(
    txId: '8LxXDWKeB_0LlgZMzhSrEQaau27-mMAURgk2CBCijMY',
    b64: '8LxXDWKeB/0LlgZMzhSrEQaau27+mMAURgk2CBCijMY=',
    b32: '6c6fodlctyd72c4wazgm4fflcedjvo3o72mmafcgbe3aqefcrtda',
    bytes: Uint8List.fromList([
      240,
      188,
      87,
      13,
      98,
      158,
      7,
      253,
      11,
      150,
      6,
      76,
      206,
      20,
      171,
      17,
      6,
      154,
      187,
      110,
      254,
      152,
      192,
      20,
      70,
      9,
      54,
      8,
      16,
      162,
      140,
      198
    ]),
  ),
  DataRepresentations(
    txId: 'cSJLdZFchg7iMmMXutn3D6dXuCHOCh4_vr6CmfGDsCc',
    b64: 'cSJLdZFchg7iMmMXutn3D6dXuCHOCh4/vr6CmfGDsCc=',
    b32: 'oerew5mrlsda5yrsmml3vwpxb6tvpobbzyfb4p56x2bjt4mdwatq',
    bytes: Uint8List.fromList([
      113,
      34,
      75,
      117,
      145,
      92,
      134,
      14,
      226,
      50,
      99,
      23,
      186,
      217,
      247,
      15,
      167,
      87,
      184,
      33,
      206,
      10,
      30,
      63,
      190,
      190,
      130,
      153,
      241,
      131,
      176,
      39
    ]),
  ),
  DataRepresentations(
    txId: 're47Y9IQH4-Dn5FKtvVAdaCRE-OAZtOUpMMNiLOqKrw',
    b64: 're47Y9IQH4+Dn5FKtvVAdaCRE+OAZtOUpMMNiLOqKrw=',
    b32: 'vxxdwy6scapy7a47sffln5kaowqjce7dqbtnhffeymgyrm5kfk6a',
    bytes: Uint8List.fromList([
      173,
      238,
      59,
      99,
      210,
      16,
      31,
      143,
      131,
      159,
      145,
      74,
      182,
      245,
      64,
      117,
      160,
      145,
      19,
      227,
      128,
      102,
      211,
      148,
      164,
      195,
      13,
      136,
      179,
      170,
      42,
      188
    ]),
  ),
  DataRepresentations(
    txId: 'DRKbgFN9MfExm6L8VNLUg0OGLcMcKyTKx7yq_oeu9DM',
    b64: 'DRKbgFN9MfExm6L8VNLUg0OGLcMcKyTKx7yq/oeu9DM=',
    b32: 'bujjxactpuy7cmm3ul6fjuwuqnbymloddqvsjswhxsvp5b5o6qzq',
    bytes: Uint8List.fromList([
      13,
      18,
      155,
      128,
      83,
      125,
      49,
      241,
      49,
      155,
      162,
      252,
      84,
      210,
      212,
      131,
      67,
      134,
      45,
      195,
      28,
      43,
      36,
      202,
      199,
      188,
      170,
      254,
      135,
      174,
      244,
      51
    ]),
  ),
  DataRepresentations(
    txId: 'DzONSvqjyCyUF3yFctDLMfTFpd_w-1PYFQ9Emz3CQic',
    b64: 'DzONSvqjyCyUF3yFctDLMfTFpd/w+1PYFQ9Emz3CQic=',
    b32: 'b4zy2sx2upeczfaxpscxfuglgh2mljo76d5vhwavb5cjwpociitq',
    bytes: Uint8List.fromList([
      15,
      51,
      141,
      74,
      250,
      163,
      200,
      44,
      148,
      23,
      124,
      133,
      114,
      208,
      203,
      49,
      244,
      197,
      165,
      223,
      240,
      251,
      83,
      216,
      21,
      15,
      68,
      155,
      61,
      194,
      66,
      39
    ]),
  ),
  DataRepresentations(
    txId: 'VGh8QjtOuGuptxg08MAejTQpuEKdo8zs_5JNTRUSB_Q',
    b64: 'VGh8QjtOuGuptxg08MAejTQpuEKdo8zs/5JNTRUSB/Q=',
    b32: 'kruhyqr3j24gxknxda2pbqa6ru2ctocctwr4z3h7sjgu2fisa72a',
    bytes: Uint8List.fromList([
      84,
      104,
      124,
      66,
      59,
      78,
      184,
      107,
      169,
      183,
      24,
      52,
      240,
      192,
      30,
      141,
      52,
      41,
      184,
      66,
      157,
      163,
      204,
      236,
      255,
      146,
      77,
      77,
      21,
      18,
      7,
      244
    ]),
  ),
];

void main() {
  group('nextMultipleOf4 method', () {
    test('returns the same number if it is already a multiple', () {
      final actual_1 = sandbox.nextMultipleOf4(0);
      final actual_2 = sandbox.nextMultipleOf4(4);
      expect(actual_1, 0);
      expect(actual_2, 4);
    });

    test('returns the next multiple of 4 if it is not', () {
      final actual = sandbox.nextMultipleOf4(1);
      expect(actual, 4);
    });
  });

  group('b64UrlToB64 method', () {
    test('takes a base64Url and returns a base64', () {
      for (final expectation in expectations) {
        final actual = sandbox.b64UrlToB64(expectation.txId);
        expect(actual, expectation.b64);
      }
    });
  });

  group('b64ToBytes method', () {
    test('takes a base64 and returns the bytes of it', () {
      for (final expectation in expectations) {
        final actual = sandbox.b64ToBytes(expectation.b64);
        expect(actual, expectation.bytes);
      }
    });
  });

  group('b64UrlToBytes method', () {
    test('takes a base64Url and returns the bytes of it', () {
      for (final expectation in expectations) {
        final actual = sandbox.b64UrlToBytes(expectation.txId);
        expect(actual, expectation.bytes);
      }
    });
  });

  group('bytesToB32String method', () {
    test('takes bytes and returns the base32 string', () {
      for (final expectation in expectations) {
        final actual = sandbox.bytesToB32String(expectation.bytes);
        expect(actual, expectation.b32);
      }
    });
  });

  group('getSandboxedSubdomain method', () {
    test('should return the correct sandbox subdomain', () {
      for (final expectation in expectations) {
        final actual = sandbox.getSandboxSubdomain(expectation.txId);
        expect(actual, expectation.b32);
      }
    });
  });
}
