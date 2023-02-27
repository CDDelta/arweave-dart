import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:base32/base32.dart';

String getSandboxSubdomain(String txId) {
  final bytes = b64UrlToBytes(txId);
  final b32Encoded = bytesToB32String(bytes);
  return b32Encoded;
}

Uint8List b64UrlToBytes(String base64Url) {
  final base64 = b64UrlToB64(base64Url);
  final bytes = b64ToBytes(base64);
  return bytes;
}

String b64UrlToB64(String base64Url) {
  final paddingLength = nextMultipleOf4(base64Url.length) - base64Url.length;
  var b64Encoded = base64Url.replaceAll("-", "+").replaceAll("_", "/");
  b64Encoded += ("=" * paddingLength);
  return b64Encoded;
}

Uint8List b64ToBytes(String base64) {
  final paddingLength = nextMultipleOf4(base64.length) - base64.length;
  final bytes = convert.base64.decode('$base64${'=' * paddingLength}');
  return bytes;
}

String bytesToB32String(Uint8List bytes) {
  final base32String = base32
      .encode(
        bytes,
      )
      .replaceAll('=', '')
      .toLowerCase();

  return base32String;
}

int nextMultipleOf4(int n) {
  final remainder = n % 4;
  if (remainder == 0) {
    return n;
  } else {
    return n + (4 - remainder);
  }
}
