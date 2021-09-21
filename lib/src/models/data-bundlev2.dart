import 'dart:typed_data';

import 'models.dart';

class DataBundle {
  final List<DataItem> items;

  DataBundle({required this.items});

  Future<ByteBuffer> asBinary() {
    throw UnimplementedError();
  }
}
