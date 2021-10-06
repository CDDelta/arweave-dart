import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';

import 'implementations/avro_js.dart'
    if (dart.library.io) 'implementations/pst_stub.dart' as implementation;

Uint8List serializeTags({required List<Tag> tags}) =>
    implementation.serializeData(tags: tags);
