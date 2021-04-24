import 'dart:convert';

import 'package:arweave/arweave.dart';

/// You can bundle multiple logical data transactions into one transaction using [DataBundle]s.
///
/// Read more about [DataBundle]s at [ANS-102](https://github.com/ArweaveTeam/arweave-standards/blob/master/ans/ANS-102.md).
void main() async {
  // Initialise an Arweave client.
  final client = Arweave();

  // Load an Arweave wallet.
  final wallet = Wallet.fromJwk(json.decode('<wallet jwk>'));
  final walletOwner = await wallet.getOwner();

  // Create a data item and make sure to provide an appropriate `owner`.
  final dataItem = DataItem.withBlobData(
    owner: walletOwner,
    data: utf8.encode('HELLOWORLD_TEST_STRING'),
  )
    ..addTag('MyTag', '0')
    ..addTag('OtherTag', 'Foo');
  final signatureData = await dataItem.getSignatureData();
  final rawSignature = await wallet.sign(signatureData);

  await dataItem.sign(rawSignature);

  // Prepare a data bundle transaction.
  final transaction = await client.transactions.prepare(
    Transaction.withDataBundle(bundle: DataBundle(items: [dataItem])),
    walletOwner,
  );
  final transactionSignatureData = await transaction.getSignatureData();
  final transactionRawSignature = await wallet.sign(transactionSignatureData);
  // Sign the bundle transaction.
  await transaction.sign(transactionRawSignature);

  // Upload the transaction.
  await client.transactions.post(transaction);
}
