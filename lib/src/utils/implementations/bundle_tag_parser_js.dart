@JS()
library tagparser;

import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';
import 'package:arweave/src/utils.dart';
import 'package:js/js.dart';

@JS()
external Uint8List serializeTags(var bundleTags);

Uint8List parseTags({required List<Tag> tags}) {
  final decodedTags = <Tag>[];
  tags.forEach((tag) {
    decodedTags.add(Tag(
      decodeBase64ToString(tag.name),
      decodeBase64ToString(tag.value),
    ));
  });

  final data = serializeTags(decodedTags
      .map((tag) => BundleTag(name: tag.name, value: tag.value))
      .toList());

  return data;
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
