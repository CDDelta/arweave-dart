@JS('tagparser')
library tagparser;

import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';
import 'package:js/js.dart';

@JS('serializeData')
external Uint8List _serializeData(Iterable<BundleTag> bundleTags);

Uint8List serializeData({required List<Tag> tags}) {
  return _serializeData(
      tags.map((tag) => BundleTag(name: tag.name, value: tag.value)));
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
