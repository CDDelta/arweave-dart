import 'dart:typed_data';

import 'package:arweave/arweave.dart';

import '../../utils.dart';

class DataBundle {
  final Uint8List blob;

  DataBundle({required this.blob});

  static Future<DataBundle> fromDataItems(
      {required List<DataItem> items}) async {
    final headers = Uint8List(64 * items.length);
    // Use precalculated buffers if provided to
    final binaries = BytesBuilder();
    await Future.wait(items.map((item) async {
      // Sign DataItem
      var index = items.indexOf(item);
      final id = decodeBase64ToBytes(item.id);
      // Create header array
      final header = Uint8List(64);
      final raw = await item.asBinary();
      // Set offset
      header.setAll(0, longTo32ByteArray(raw.length));
      // Set id
      header.setAll(32, id);
      // Add header to array of headers
      headers.setAll(64 * index, header);
      // Convert to array for flattening
      binaries.add(raw.takeBytes());
    }));

    final buffer = BytesBuilder();
    buffer.add(longTo32ByteArray(items.length));
    buffer.add(headers);
    buffer.add(binaries.takeBytes());
    return DataBundle(blob: buffer.takeBytes());
  }

  static Future<DataBundle> fromHandles({
    required List<DataItemHandle> handles,
  }) async {
    final headers = Uint8List(64 * handles.length * 2);
    // Use precalculated buffers if provided to
    var dataItemIndex = 0;
    final binaries = BytesBuilder();
    await Future.wait(handles.map((handle) async {
      // Sign DataItem
      final dataItems = await handle.createDataItemsFromFileHandle();
      assert(dataItems.length == 2);
      for (var dataItem in dataItems) {
        final id = decodeBase64ToBytes(dataItem.id);
        // Create header array
        final header = Uint8List(64);
        final raw = await dataItem.asBinary();
        dataItem.data = Uint8List(0);
        // Set offset
        header.setAll(0, longTo32ByteArray(raw.length));
        // Set id
        header.setAll(32, id);
        // Add header to array of headers
        headers.setAll(64 * dataItemIndex, header);
        dataItemIndex++;
        // Convert to array for flattening
        binaries.add(raw.takeBytes());
      }
    }));

    final buffer = BytesBuilder();
    buffer.add(longTo32ByteArray(handles.length * 2));
    buffer.add(headers);
    buffer.add(binaries.takeBytes());
    return DataBundle(blob: buffer.takeBytes());
  }
}
