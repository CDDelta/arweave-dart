import 'dart:typed_data';

import 'package:base32/base32.dart';

String getSandboxSubdomain(String txId) {
  return toB32(fromB64Url(txId));
}

Uint8List fromB64Url(String input) {
  int paddingLength = (input.length % 4 == 0 ? 0 : 4 - (input.length % 4));

  var base64 = input.replaceAll("-", "+").replaceAll("_", "/");
  base64 += ("=" * paddingLength);

  return _base64ToArrayBuffer(base64);
}

String toB32(Uint8List input) {
  final base32String = base32
      .encode(
        input,
      )
      .replaceAll('=', '')
      .toLowerCase();

  return base32String;
}

Uint8List _base64ToArrayBuffer(base64) {
  var binaryString = atobPolyfill(base64);

  var len = binaryString.length;

  var bytes = Uint8List(len);

  for (var i = 0; i < len; i++) {
    bytes[i] = binaryString.codeUnitAt(i);
  }

  return bytes;
}

String atobPolyfill(input) {
  var chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  var str = input.replaceAll(RegExp(r'[=]+$'), "");
  if (str.length % 4 == 1) {
    return input;
  }
  var output = "";
  // TODO: is null check appropriate?
  for (var bc = 0, bs, buffer, idx = 0; idx < str.length; idx++) {
    buffer = str[idx];
    buffer = chars.indexOf(buffer);
    if (~buffer != 0) {
      if (bc % 4 > 0) {
        bs = bs * 64 + buffer;
        bc++;
        output += String.fromCharCode(255 & (bs >> ((-2 * bc) & 6)));
      } else {
        bs = buffer;
        bc++;
      }
    }
  }
  return output;
}
