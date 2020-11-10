import 'dart:convert';

import 'package:arweave/arweave.dart';

/// In the case of a failure that causes a transaction upload to not fully complete
/// you can complete the upload by loading the transaction metadata off the network
/// and uploading the data again.
///
/// This will upload every chunk of the data as we don't know what has already
/// been uploaded.
void main() async {
  // Initialise an Arweave client.
  final client = Arweave();

  // Get the transaction from the network.
  final transaction = await client.transactions.get('<transaction id>');

  // Set the data that is meant to be on this transaction.
  await transaction.setData(utf8.encode('<original data>'));

  // Upload the original transaction data.
  await for (final upload
      in client.transactions.upload(transaction, dataOnly: true)) {
    print('${upload.progress * 100}%');
  }
}
