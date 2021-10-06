@JS()
library avrojs;

import 'dart:typed_data';

import 'package:arweave/src/models/tag.dart';
import 'package:js/js.dart';

Type _getTypeSchema() => Type.forSchema(Schema(
      type: 'record',
      name: 'Tag',
      fields: [
        SchemaField(name: 'name', type: 'string'),
        SchemaField(name: 'value', type: 'string'),
      ],
    ));

Uint8List serializeData({required List<Tag> tags}) => _getTypeSchema()
    .toBuffer(tags.map((tag) => BundleTag(name: tag.name, value: tag.value)));

@JS()
class Type {
  external static dynamic forSchema(Schema schema);
  external dynamic toBuffer(Object obj);
}

class Schema {
  external String type;
  external String name;
  external List<SchemaField> fields;

  external factory Schema({
    String type,
    String name,
    List<SchemaField> fields,
  });
}

class SchemaField {
  external String name;
  external String type;

  external factory SchemaField({
    String name,
    String type,
  });
}

class BundleTag {
  external String get name;
  external String get value;

  // Must have an unnamed factory constructor with named arguments.
  external factory BundleTag({
    String name,
    String value,
  });
}