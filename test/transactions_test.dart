import 'dart:convert';

import 'package:arweave/arweave.dart';
import 'package:arweave/utils.dart' as utils;
import 'package:test/test.dart';

import 'utils.dart';

const liveDataTxId = "bNbA3TEQVL60xlgCcqdz4ZPHFZ711cZ3hmkpGttDt_U";

void main() {
  final client = Arweave();

  group('transactions:', () {
    final transactionFieldPattern =
        RegExp(r'^[a-z0-9-_]{64}$', caseSensitive: false);
    final signaturePattern = RegExp(r'^[a-z0-9-_]+$', caseSensitive: false);
    test('create and sign data transaction', () async {
      final wallet = await getTestWallet();

      final transaction = await client.transactions
          .prepare(Transaction.withStringData(data: 'test'), wallet);

      transaction.addTag("test-tag-1", "test-value-1");
      transaction.addTag("test-tag-2", "test-value-2");
      transaction.addTag("test-tag-3", "test-value-3");

      expect(utf8.decode(transaction.data), equals('test'));
      expect(transaction.lastTx, matches(transactionFieldPattern));
      expect(transaction.reward.toInt(), greaterThan(0));

      await transaction.sign(wallet);

      expect(transaction.signature, matches(signaturePattern));
      expect(transaction.id, matches(digestPattern));

      expect(await transaction.verify(), isTrue);

      transaction.addTag('k', 'v');
      expect(await transaction.verify(), isFalse);
    });

    test('create and sign AR transaction', () async {
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

      expect(await transaction.verify(), isTrue);
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
    });

    test('get and verify transaction', () async {
      final transaction = await client.transactions.get(liveDataTxId);
      expect(await transaction.verify(), isTrue);
    });

    test('get transaction status', () async {
      final status = await client.transactions.getStatus(liveDataTxId);
      expect(status.status, equals(200));
      expect(status.confirmed, isNotNull);
    });

    test('get transaction data', () async {
      final txData = await client.transactions.getData(liveDataTxId);
      expect(txData, contains("CjwhRE9DVFlQRSBodG1sPgo"));
    });

    test('search transactions', () async {
      final results =
          await client.transactions.search('Silo-Name', 'BmjRGIsemI77+eQb4zX8');
      expect(results, contains('Sgmyo7nUqPpVQWUfK72p5yIpd85QQbhGaWAF-I8L6yE'));
    });
  });
}
