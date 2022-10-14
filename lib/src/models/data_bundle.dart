import 'dart:developer';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';

import '../../utils.dart';

class DataBundle {
  final Uint8List blob;

  DataBundle({required this.blob});

  static Future<DataBundle> fromDataItems({
    required List<DataItem> items,
  }) async {
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
    bool parallelize = true,
  }) async {
    log('Get DataBundle from handles...');
    log('Number of handles: ${handles.length}');

    final noOfDataItems = handles
        .map((handle) => handle.dataItemCount)
        .reduce((sum, current) => sum += current);
    final headers = Uint8List(64 * noOfDataItems);
    // Use precalculated buffers if provided to
    var dataItemIndex = 0;
    final binaries = BytesBuilder();

    Future<void> getDataItems(DataItemHandle handle) async {
      log('current ${handle.hashCode}');
      // Sign DataItem
      log('Getting DataItems');

      final dataItems = await handle.getDataItems();

      log('DataItems done');
      log('Number of data items: ${dataItems.length}');

      log('Iterating for each DataItem');

      for (var dataItem in dataItems) {
        log('Current dataItem: ${dataItem.id}');

        log('Decoding');

        final id = decodeBase64ToBytes(dataItem.id);

        log('Decoded');

        // Create header array
        final header = Uint8List(64);

        log('Get raw');

        final raw = await dataItem.asBinary();

        log('Raw done: ${raw.length}');

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

        log('Added binaries from ${dataItem.id}');
      }
    }

    if (parallelize) {
      final futures =
          handles.map((handle) async => getDataItems(handle)).toList();

      await Future.wait<void>(futures);
    } else {
      await Future.forEach<DataItemHandle>(handles, getDataItems);
    }

    log('DataBundle from handles finished');
    log('Mouting buffer....');

    final buffer = BytesBuilder();
    buffer.add(longTo32ByteArray(noOfDataItems));
    buffer.add(headers);
    buffer.add(binaries.takeBytes());

    log('Buffer mounted');
    log('Returning DataBundle');

    return DataBundle(blob: buffer.takeBytes());
  }
}
