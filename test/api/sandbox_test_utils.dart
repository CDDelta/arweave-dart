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
  final bytes = b64ToUint8List(base64);
  return bytes;
}

String b64UrlToB64(String base64Url) {
  final paddingLength = nextMultipleOf4(base64Url.length) - base64Url.length;
  var b64Encoded = base64Url.replaceAll("-", "+").replaceAll("_", "/");
  b64Encoded += ("=" * paddingLength);
  return b64Encoded;
}

Uint8List b64ToUint8List(String base64) {
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


// import 'dart:typed_data';

// import 'package:base32/base32.dart';

// String expectedTxSandbox(String id) {
//   return toB32(fromB64Url(id));
// }

// String toB32(Uint8List input) {
//   return base32.encode(input).replaceAll('=', '').toLowerCase();
// }

// // export function fromB64Url(input: Base64UrlEncodedString): Buffer {
// //   const paddingLength = input.length % 4 == 0 ? 0 : 4 - (input.length % 4);

// //   const base64 = input
// //     .replace(/\-/g, "+")
// //     .replace(/\_/g, "/")
// //     .concat("=".repeat(paddingLength));

// //   return Buffer.from(base64, "base64");
// // }
// Uint8List fromB64Url(String input) {
//   int paddingLength = (input.length % 4 == 0 ? 0 : 4 - (input.length % 4));

//   var base64 = input.replaceAll("-", "+").replaceAll("_", "/");
//   base64 += ("=" * paddingLength);

//   return _base64ToArrayBuffer(base64);
// }

// // String atobPolyfill(input) {}
// Uint8List _base64ToArrayBuffer(String base64) {
//   var len = base64.length;

//   var bytes = Uint8List(len);

//   for (var i = 0; i < len; i++) {
//     bytes[i] = base64.codeUnitAt(i);
//   }

//   return bytes;
// }
