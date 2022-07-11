@JS()
library tagparser;

import 'package:js/js.dart';
import 'package:arweave/utils.dart';
import 'package:arweave/src/models/tag.dart';

@JS()
external List<BundleTag> deserializeTagsFromBuffer(var buffer);

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
