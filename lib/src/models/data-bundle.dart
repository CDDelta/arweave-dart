import 'dart:typed_data';

import 'package:arweave/arweave.dart';

import '../../utils.dart';

class DataBundle {
  late List<DataItem> items;

  DataBundle({this.items = const []});

  Future<Uint8List> asBlob() async {
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
    return buffer.takeBytes();
  }

  Future<Uint8List> asBlobFromPrototypes({
    required List<DataItemPrototype> items,
  }) async {
    final headers = Uint8List(64 * items.length);
    // Use precalculated buffers if provided to
    final binaries = BytesBuilder();
    await Future.wait(items.map((item) async {
      // Sign DataItem
      var index = items.indexOf(item);
      final dataItem = await item.processAndPrepareDataItem();
      final id = decodeBase64ToBytes(dataItem.id);
      // Create header array
      final header = Uint8List(64);
      final raw = await dataItem.asBinary();
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
    return buffer.takeBytes();
  }

  Future<bool> verify() async {
    var verify = await Future.wait(items.map((e) async => await e.verify()));
    return verify.reduce((value, element) => value &= element);
  }
}
