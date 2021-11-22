@JS()
library tagparser;

import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';
import 'package:arweave/src/utils.dart';
import 'package:js/js.dart';

@JS()
external Uint8List serializeTagsToBuffer(var bundleTags);

@JS()
external List<BundleTag> deserializeTagsFromBuffer(var buffer);

Uint8List serializeTags({required List<Tag> tags}) {
  final decodedTags = <Tag>[];
  tags.forEach((tag) {
    decodedTags.add(Tag(
      decodeBase64ToString(tag.name),
      decodeBase64ToString(tag.value),
    ));
  });
  final data = serializeTagsToBuffer(decodedTags
      .map((tag) => BundleTag(name: tag.name, value: tag.value))
      .toList());
  return data;
}

List<Tag> deserializeTags({var buffer}) {
  try {
    final tags = deserializeTagsFromBuffer(buffer);
    final decodedTags = <Tag>[];
    for (var tag in tags) {
      decodedTags.add(Tag(
        encodeBytesToBase64(
            tag.name.split(',').map((e) => int.parse(e)).toList()),
        encodeBytesToBase64(
            tag.value.split(',').map((e) => int.parse(e)).toList()),
      ));
    }

    return decodedTags;
  } catch (e) {
    throw WrongTagBufferException();
  }
}

@JS()
@anonymous
class BundleTag {
  external String get name;
  external String get value;

  // Must have an unnamed factory constructor with named arguments.
  external factory BundleTag({
    String name,
    String value,
  });
}

class WrongTagBufferException implements Exception {}
