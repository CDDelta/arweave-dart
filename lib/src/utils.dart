import 'dart:convert';
import 'dart:typed_data';

final keyLength = 4096;
final publicExponent = BigInt.from(65537);

Uint8List decodeBase64ToBytes(String base64) =>
    base64Url.decode(base64Url.normalize(base64));

String decodeBase64ToString(String base64) =>
    utf8.decode(decodeBase64ToBytes(base64));

BigInt decodeBase64ToBigInt(String base64) {
  final bytes = decodeBase64ToBytes(base64);
  BigInt result = new BigInt.from(0);
  for (int i = 0; i < bytes.length; i++) {
    result += new BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
  }
  return result;
}

String encodeStringToBase64(String string) =>
    encodeBytesToBase64(utf8.encode(string));

String encodeBytesToBase64(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

final _byteMask = BigInt.from(0xff);
Uint8List encodeBigIntToBytes(BigInt bigInt) {
  int size = (bigInt.bitLength + 7) >> 3;
  var result = new Uint8List(size);
  for (int i = 0; i < size; i++) {
    result[size - i - 1] = (bigInt & _byteMask).toInt();
    bigInt = bigInt >> 8;
  }
  return result;
}

String encodeBigIntToBase64(BigInt bigInt) =>
    encodeBytesToBase64(encodeBigIntToBytes(bigInt));
