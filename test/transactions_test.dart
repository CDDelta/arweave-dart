import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

const liveDataTxId = "bNbA3TEQVL60xlgCcqdz4ZPHFZ711cZ3hmkpGttDt_U";

void main() {
  Arweave client;

  setUp(() {
    client = getArweaveClient();
  });

  final transactionFieldPattern =
      RegExp(r'^[a-z0-9-_]{64}$', caseSensitive: false);
  final signaturePattern = RegExp(r'^[a-z0-9-_]+$', caseSensitive: false);
  final rewardPattern = RegExp(r'^[0-9]+$', caseSensitive: false);
  test(
    'create and sign data transaction',
    () async {
      final wallet = await client.wallets.generate();

      final transaction =
          await client.createTransaction(Transaction(data: 'test'), wallet);

      transaction.addTag("test-tag-1", "test-value-1");
      transaction.addTag("test-tag-2", "test-value-2");
      transaction.addTag("test-tag-3", "test-value-3");

      expect(transaction.data, equals('dGVzdA'));
      expect(transaction.lastTx, matches(transactionFieldPattern));
      expect(transaction.reward, matches(rewardPattern));

      await client.transactions.sign(transaction, wallet);

      expect(transaction.signature, matches(signaturePattern));
      expect(transaction.id, matches(digestPattern));

      expect(await client.transactions.verify(transaction), isTrue);

      transaction.addTag('k', 'v');
      expect(await client.transactions.verify(transaction), isFalse);
    },
    timeout: Timeout.factor(2),
  );

  test(
    'create and sign AR transaction',
    () async {
      final wallet = await client.wallets.generate();

      final transaction = await client.createTransaction(
        Transaction(
          target: 'GRQ7swQO1AMyFgnuAPI7AvGQlW3lzuQuwlJbIpWV7xk',
          quantity: client.arToWinston(1.5).toStringAsFixed(0),
        ),
        wallet,
      );

      expect(transaction.quantity, equals('1500000000000'));
      expect(transaction.target,
          equals('GRQ7swQO1AMyFgnuAPI7AvGQlW3lzuQuwlJbIpWV7xk'));

      await client.transactions.sign(transaction, wallet);

      expect(transaction.signature, matches(signaturePattern));
      expect(transaction.id, matches(digestPattern));

      expect(await client.transactions.verify(transaction), isTrue);
    },
    timeout: Timeout.factor(2),
  );

  test('get and verify transaction', () async {
    final transaction = await client.transactions.get(liveDataTxId);
    expect(await client.transactions.verify(transaction), isTrue);
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
}
