import 'dart:typed_data';

import 'package:arweave/arweave.dart';

import '../../utils.dart';

class DataBundle {
  final List<DataItem> items;

  DataBundle({required this.items});

  Future<Uint8List> asBlob() async {
    final headers = Uint8List(64 * items.length);
    // Use precalculated buffers if provided to
    final binaries = await Future.wait(
      items.map((d) async {
        // Sign DataItem
        var index = items.indexOf(d);
        final id = decodeBase64ToBytes(d.id);
        // Create header array
        final header = Uint8List(64);
        final raw = await d.asBinary();
        // Set offset
        header.setAll(0, longTo32ByteArray(raw.lengthInBytes));
        // Set id
        header.setAll(32, id);
        // Add header to array of headers
        headers.setAll(64 * index, header);
        // Convert to array for flattening
        return raw.asUint8List();
      }),
    ).then((a) {
      return a.reduce((a, e) => Uint8List.fromList(a + e));
    });

    final buffer = Uint8List.fromList([
      ...longTo32ByteArray(items.length),
      ...headers,
      ...binaries,
    ]);
    return buffer;
  }

  Future<bool> verify() async {
    var verify = await Future.wait(items.map((e) async => await e.verify()));
    return verify.reduce((value, element) => value &= element);
  }
}
