import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';

import 'implementations/bundle_tag_parser_js.dart'
    if (dart.library.io) 'implementations/bundle_tag_parser_ffi.dart'
    as implementation;

Uint8List serializeTags({required List<Tag> tags}) =>
    implementation.serializeTags(tags: tags);
