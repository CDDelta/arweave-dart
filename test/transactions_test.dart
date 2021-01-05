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

  group('transactions:', () {
    final transactionFieldPattern =
        RegExp(r'^[a-z0-9-_]{64}$', caseSensitive: false);
    final signaturePattern = RegExp(r'^[a-z0-9-_]+$', caseSensitive: false);
    test('create, sign, and verify data transaction', () async {
      final wallet = await getTestWallet();

      final transaction = await client.transactions
          .prepare(Transaction.withBlobData(data: utf8.encode('test')), wallet);

      transaction
        ..addTag('test-tag-1', 'test-value-1')
        ..addTag('test-tag-2', 'test-value-2')
        ..addTag('test-tag-3', 'test-value-3');

      expect(utf8.decode(transaction.data), equals('test'));
      expect(transaction.lastTx, matches(transactionFieldPattern));
      expect(transaction.reward.toInt(), greaterThan(0));

      await transaction.sign(wallet);

      expect(transaction.signature, matches(signaturePattern));
      expect(transaction.id, matches(digestPattern));

      expect(await transaction.verify(), isTrue);

      transaction.addTag('k', 'v');
      expect(await transaction.verify(), isFalse);
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('create, sign, and specify reward for AR transaction', () async {
      final wallet = await getTestWallet();

      final transaction = await client.transactions.prepare(
        Transaction(
          target: 'GRQ7swQO1AMyFgnuAPI7AvGQlW3lzuQuwlJbIpWV7xk',
          quantity: utils.arToWinston('1.5'),
        ),
        wallet,
      );

      expect(transaction.target,
          equals('GRQ7swQO1AMyFgnuAPI7AvGQlW3lzuQuwlJbIpWV7xk'));

      await transaction.sign(wallet);

      expect(transaction.signature, matches(signaturePattern));
      expect(transaction.id, matches(digestPattern));
      expect(transaction.quantity, equals(BigInt.from(1500000000000)));
      expect(transaction.reward, greaterThan(BigInt.zero));

      expect(await transaction.verify(), isTrue);
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('sign v2 transaction', () async {
      final wallet = await getTestWallet();
      final signedV2Tx =
          await getTestTransaction('test/fixtures/signed_v2_tx.json');
      final unsignedV2Tx =
          await getTestTransaction('test/fixtures/unsigned_v2_tx.json');

      final tx = await client.transactions.prepare(
        Transaction.withBlobData(
          data: unsignedV2Tx.data,
          reward: utils.arToWinston('100'),
        ),
        wallet,
      );

      tx.setLastTx('');

      await tx.sign(wallet);

      expect(tx.dataRoot, signedV2Tx.dataRoot);
      expect(tx.signature, signedV2Tx.signature);
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('successfully validate data from 1mb.bin set on prepared transaction',
        () async {
      final data = await File('test/fixtures/1mb.bin').readAsBytes();

      final transaction = await client.transactions
          .prepare(Transaction.withBlobData(data: data, reward: BigInt.one));
      expect(transaction.setData(data), completion(null));
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test(
        'successfully validate data from lotsofdata.bin set on prepared transaction',
        () async {
      final data = await File('test/fixtures/lotsofdata.bin').readAsBytes();

      final transaction = await client.transactions
          .prepare(Transaction.withBlobData(data: data, reward: BigInt.one));
      expect(transaction.setData(data), completion(null));
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('error when invalid data is set on prepared transaction', () async {
      final data = await File('test/fixtures/lotsofdata.bin').readAsBytes();

      final transaction = await client.transactions
          .prepare(Transaction.withBlobData(data: data, reward: BigInt.one));
      expect(
        transaction.setData(Uint8List.sublistView(data, 1)),
        throwsStateError,
      );
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('upload data to transaction already on network', () async {
      final transaction = await client.transactions
          .get('8C6yYu5pWMADLSd65wTnrzgN-9eLj9sFbyVC3prSaFs');

      await transaction
          .setData(utf8.encode('{"name":"Blockchains & Cryptocurrencies"}'));

      expect(
        client.transactions.upload(transaction, dataOnly: true).drain(),
        completion(null),
      );
    });

    test('upload transaction with serialised uploader', () async {
      final data = utf8.encode('Hello world!');
      final wallet = await getTestWallet();
      final transaction = await client.transactions.prepare(
        Transaction.withBlobData(data: data),
        wallet,
      );

      await transaction.sign(wallet);

      final uploader = await client.transactions.getUploader(transaction);
      final reloadedUploader = await TransactionUploader.deserialize(
          uploader.serialize(), data, client.api);

      // Technically this should fail since the test wallet has no AR but the
      // HTTP API doesn't return an error so there's nothing we can do about it.
      expect(reloadedUploader.uploadChunk(), completion(null));
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('get and verify transaction', () async {
      final transaction = await client.transactions.get(liveDataTxId);
      expect(await transaction.verify(), isTrue);
    });
  });
}
