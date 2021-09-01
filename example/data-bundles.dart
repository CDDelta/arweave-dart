import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';

/// You can bundle multiple logical data transactions into one transaction using [DataBundle]s.
///
/// Read more about [DataBundle]s at [ANS-102](https://github.com/ArweaveTeam/arweave-standards/blob/master/ans/ANS-102.md).
void main() async {
  // Initialise an Arweave client.
  final client = Arweave();

  // Load an Arweave wallet.
  final wallet = Wallet.fromJwk(json.decode('<wallet jwk>'));

  // Create a data item and make sure to provide an appropriate `owner`.
  final dataItem = DataItem.withBlobData(
    owner: await wallet.getOwner(),
    data: utf8.encode('HELLOWORLD_TEST_STRING') as Uint8List,
  )
    ..addTag('MyTag', '0')
    ..addTag('OtherTag', 'Foo');

  await dataItem.sign(wallet);

  // Prepare a data bundle transaction.
  final transaction = await client.transactions.prepare(
    Transaction.withDataBundle(bundle: DataBundle(items: [dataItem])),
    wallet,
  );

  // Sign the bundle transaction.
  await transaction.sign(wallet);

  // Upload the transaction.
  await client.transactions.post(transaction);
}
