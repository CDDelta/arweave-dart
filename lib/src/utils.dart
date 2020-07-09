import 'dart:convert';

String stringToBase64(String string) {
  final bytes = utf8.encode(string);
  return base64.encode(bytes);
}
