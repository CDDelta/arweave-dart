import 'dart:typed_data';

import 'package:arweave/arweave.dart';

import '../../utils.dart';

class DataBundle {
  final List<DataItem> items;

  DataBundle({required this.items});

  Future<Uint8List> asBlob(Wallet wallet) async {
    final headers = Uint8List(64 * items.length);
    final binaries = await Future.wait(
      items.map((d) async {
        // Sign DataItem
        var index = items.indexOf(d);
        final id = decodeBase64ToBytes(d.id);
        print('Transaction ID:' + d.id);
        // Create header array
        final header = Uint8List(64);
        // Set offset
        header.setAll(0, longTo32ByteArray(d.asBinary().lengthInBytes));
        // Set id
        header.setAll(32, id);
        // Add header to array of headers
        headers.setAll(64 * index, header);
        // Convert to array for flattening
        final raw = d.asBinary();
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

  Future<bool> verify(Wallet wallet) async {
    return false;
  }
}
