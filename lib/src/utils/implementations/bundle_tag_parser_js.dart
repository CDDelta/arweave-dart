@JS()
library tagparser;

import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';
import 'package:js/js.dart';

@JS()
external Uint8List serializeTags(var bundleTags);

Uint8List parseTags({required List<Tag> tags}) {
  return serializeTags(
      tags.map((tag) => BundleTag(name: tag.name, value: tag.value)).toList());
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
