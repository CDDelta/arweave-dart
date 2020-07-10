import 'dart:convert';

String stringToBase64(String string) {
  final bytes = utf8.encode(string);
  return base64Url.encode(bytes);
}

String base64ToString(String string) {
  final bytes = base64Url.decode(string);
  return utf8.decode(bytes);
}
