import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:arweave/src/models/transaction_stream.dart';

final digestPattern = RegExp(r'^[a-z0-9-_]{43}$', caseSensitive: false);

Future<Transaction> getTestTransaction(String path) async =>
    Transaction.fromJson(json.decode(await File(path).readAsString()));

Future<Wallet> getTestWallet(
        [String path = 'test/fixtures/test-key.json']) async =>
    Wallet.fromJwk(json.decode(await File(path).readAsString()));

final random = Random();
Uint8List randomBytes(int length) {
  final bytes = Uint8List(length);
  for (var i = 0; i < length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return bytes;
}

Uint8List generateByteList(int mb) {
  final size = mb * 1000 * pow(2, 10) as int;
  var list = StringBuffer();

  for (var i = 0; i < size; i++) {
    list.write('A');
  }

  return utf8.encode(list.toString()) as Uint8List;
}

class StreamMeta {
  final DataStreamGenerator dataStreamGenerator;
  final int dataSize;

  StreamMeta(this.dataStreamGenerator, this.dataSize);
}

Future<StreamMeta> getFileStreamMeta(String filePath) async {
  final file = File(filePath);
  Stream<Uint8List> dataStreamGenerator ([int? start, int? end]) {
    final fileStream = file.openRead(start, end);
    return fileStream.asyncMap((chunk) => (chunk as Uint8List));
  }
  final dataSize = await file.length();

  return StreamMeta(dataStreamGenerator, dataSize);
}
