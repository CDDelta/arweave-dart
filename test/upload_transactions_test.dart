import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:arweave/utils.dart' as utils;
import 'package:test/test.dart';

import 'utils.dart';

const liveDataTxId = 'bNbA3TEQVL60xlgCcqdz4ZPHFZ711cZ3hmkpGttDt_U';

void main() {
  final client = Arweave();

  group('upload transactions:', () {
    final transactionFieldPattern =
        RegExp(r'^[a-z0-9-_]{64}$', caseSensitive: false);
    final signaturePattern = RegExp(r'^[a-z0-9-_]+$', caseSensitive: false);

    test('successfully seed existing network transaction', () async {
      final transaction = await client.transactions
          .get('8C6yYu5pWMADLSd65wTnrzgN-9eLj9sFbyVC3prSaFs');

      await transaction!.setData(utf8
          .encode('{"name":"Blockchains & Cryptocurrencies"}') as Uint8List);

      expect(
        client.transactions.upload(transaction, dataOnly: true),
        emitsInOrder([
          emits(anything),
          emitsDone,
        ]),
      );
    });

    test('successfully upload AR only transaction', () async {
      final wallet = await getTestWallet();

      final transaction = await client.transactions.prepare(
        Transaction(
          target: 'GRQ7swQO1AMyFgnuAPI7AvGQlW3lzuQuwlJbIpWV7xk',
          quantity: utils.arToWinston('1.5'),
        ),
        wallet,
      );

      await transaction.sign(wallet);

      expect(
        client.transactions.upload(transaction),
        emitsInOrder([
          emits(predicate((TransactionUploader event) =>
              event.isComplete && event.progress == 1)),
          emitsDone,
        ]),
      );
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('successfully seed existing large network transaction', () async {
      final txId = 'gAnkEioD7xoP3qx7VepVEp1O0v4L1UgtBV_trM-Ria8';
      final transaction = await client.transactions.get(txId);
      final txData = await File("test/fixtures/$txId").readAsBytes();

      await transaction!.setData(txData);

      int lastUploadedChunkCount = 0;
      double lastProgress = 0;

      expect(
        client.transactions.upload(transaction, dataOnly: true),
        emitsInOrder([
          ...List.filled(393, emits(predicate((TransactionUploader event) {
            final eventIsInSequence =
                event.uploadedChunks > lastUploadedChunkCount &&
                    event.progress > lastProgress;

            lastUploadedChunkCount = event.uploadedChunks;
            lastProgress = event.progress;

            return eventIsInSequence;
          }))),
          emits(predicate((TransactionUploader event) =>
              event.isComplete && event.progress == 1)),
          emitsDone,
        ]),
      );
    }, timeout: Timeout(Duration(seconds: 120)), onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('get and verify transaction', () async {
      final transaction = await (client.transactions.get(liveDataTxId));
      expect(await transaction!.verify(), isTrue);
    });
  });
}
