import 'dart:typed_data';

Uint8List fromB64Url(String input) {
  final paddingLength = 44;
  final paddedInput = input
      .replaceAll(RegExp(r'/\-/g'), '+')
      .replaceAll(RegExp(r'/\_/g'), '/')
      .padRight(paddingLength, '=');

  return _base64ToArrayBuffer(paddedInput);
}

String toB32(Uint8List input) {
  final base32String = encodeU32Bytes(
    input,
  ).replaceAll('=', '').toLowerCase();

  return base32String;
}

var base32EncodeChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".split("");

String encodeU32Bytes(bytes) {
  var v1, v2, v3, v4, v5, i = 0, base32Str = "", length = bytes.length;

  var count = (length ~/ 5) * 5;

  while (i < count) {
    v1 = bytes[i++];

    v2 = bytes[i++];

    v3 = bytes[i++];

    v4 = bytes[i++];

    v5 = bytes[i++];

    base32Str += base32EncodeChar[v1 >>> 3] +
        base32EncodeChar[((v1 << 2) | (v2 >>> 6)) & 31] +
        base32EncodeChar[(v2 >>> 1) & 31] +
        base32EncodeChar[((v2 << 4) | (v3 >>> 4)) & 31] +
        base32EncodeChar[((v3 << 1) | (v4 >>> 7)) & 31] +
        base32EncodeChar[(v4 >>> 2) & 31] +
        base32EncodeChar[((v4 << 3) | (v5 >>> 5)) & 31] +
        base32EncodeChar[v5 & 31];
  }

  // remain char

  var remain = length - count;

  if (remain == 1) {
    v1 = bytes[i];

    base32Str += base32EncodeChar[v1 >>> 3] +
        base32EncodeChar[(v1 << 2) & 31] +
        "======";
  } else if (remain == 2) {
    v1 = bytes[i++];

    v2 = bytes[i];

    base32Str += base32EncodeChar[v1 >>> 3] +
        base32EncodeChar[((v1 << 2) | (v2 >>> 6)) & 31] +
        base32EncodeChar[(v2 >>> 1) & 31] +
        base32EncodeChar[(v2 << 4) & 31] +
        "====";
  } else if (remain == 3) {
    v1 = bytes[i++];

    v2 = bytes[i++];

    v3 = bytes[i];

    base32Str += base32EncodeChar[v1 >>> 3] +
        base32EncodeChar[((v1 << 2) | (v2 >>> 6)) & 31] +
        base32EncodeChar[(v2 >>> 1) & 31] +
        base32EncodeChar[((v2 << 4) | (v3 >>> 4)) & 31] +
        base32EncodeChar[(v3 << 1) & 31] +
        "===";
  } else if (remain == 4) {
    v1 = bytes[i++];

    v2 = bytes[i++];

    v3 = bytes[i++];

    v4 = bytes[i];

    base32Str += base32EncodeChar[v1 >>> 3] +
        base32EncodeChar[((v1 << 2) | (v2 >>> 6)) & 31] +
        base32EncodeChar[(v2 >>> 1) & 31] +
        base32EncodeChar[((v2 << 4) | (v3 >>> 4)) & 31] +
        base32EncodeChar[((v3 << 1) | (v4 >>> 7)) & 31] +
        base32EncodeChar[(v4 >>> 2) & 31] +
        base32EncodeChar[(v4 << 3) & 31] +
        "=";
  }

  return base32Str;
}

Uint8List _base64ToArrayBuffer(base64) {
  var binary_string = atobPolyfill(base64);

  var len = binary_string.length;

  var bytes = new Uint8List(len);

  for (var i = 0; i < len; i++) {
    bytes[i] = binary_string.codeUnitAt(i);
  }

  return bytes;
}

String atobPolyfill(input) {
  var chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  String str = input.replaceAll(RegExp(r'[=]+$'), "");
  if (str.length % 4 == 1) {
    return input;
  }
  var output = "";
  for (var bc = 0, bs, buffer, idx = 0;
      (buffer = idx < str.length ? str.codeUnitAt(idx++) : 0) != 0;
      0) {
    buffer = chars.indexOf(buffer.toString());
    if (buffer != 0) {
      if (bc % 4 > 0) {
        bs = bs * 64 + buffer;
        bc++;
        output += String.fromCharCode(255 & (bs >> ((-2 * bc) & 6)));
      } else {
        bs = buffer;
      }
    }
  }
  return output;
}
