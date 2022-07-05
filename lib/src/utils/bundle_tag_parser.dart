import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';
import 'package:arweave/src/utils.dart';

Uint8List serializeTags({required List<Tag> tags}) {
  final decodedTags = <Tag>[];
  for (var tag in tags) {
    decodedTags.add(Tag(
      decodeBase64ToString(tag.name),
      decodeBase64ToString(tag.value),
    ));
  }
  final avroTags = decodedTags.map(_serializeTag);
  final avroTagArray = _serializeArray(avroTags);

  return avroTagArray;
}

Uint8List _serializeTag(Tag tag) {
  return Uint8List.fromList(
    _serializeString(tag.name) + _serializeString(tag.value),
  );
}

Uint8List _serializeArray(Iterable<Uint8List> array) {
  final concatBuffer = <int>[];
  for (final element in array) {
    concatBuffer.addAll(element);
  }

  return Uint8List.fromList(
    _serializeLong(array.length) + concatBuffer + [0],
  );
}

Uint8List _serializeString(String string) {
  final stringBytes = utf8.encode(string);

  return Uint8List.fromList(
    _serializeLong(stringBytes.length) + stringBytes,
  );
}

Uint8List _serializeLong(int long) {
  var zigZag = (long << 1) ^ (long >> 63);

  final buffer = <int>[];
  while (zigZag >= 0x80) {
    buffer.add((zigZag & 0x7f) | (1 << 7));
    zigZag >>= 7;
  }
  buffer.add(zigZag);

  return Uint8List.fromList(buffer);
}
