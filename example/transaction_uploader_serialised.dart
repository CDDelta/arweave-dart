import 'dart:convert';

import 'package:arweave/arweave.dart';

/// You can resume an upload by serialising the transaction uploader
/// and reloading it at a later time with the relevant data.
void main() async {
  // Initialise an Arweave client.
  final client = Arweave();

  // Load an Arweave wallet.
  final wallet = Wallet.fromJwk(json.decode('<wallet jwk>'));

  // Create a data transaction.
  final transaction = await client.transactions.prepare(
    Transaction.withBlobData(data: utf8.encode('Hello world!')),
    wallet,
  );

  // Sign the transaction.
  await transaction.sign(wallet);

  // Get an uploader for this transaction.
  final uploader = await client.transactions.getUploader(transaction);

  // Serialise and store the uploader.
  final uploaderJson = uploader.serialize();

  // Deserialise the uploader and provide the original transaction data again
  // as it isn't serialised along with the uploader.
  final reloadedUploader = await TransactionUploader.deserialize(
      uploaderJson, utf8.encode('Hello world!'), client.api);

  // Resume the upload.
  while (!reloadedUploader.isComplete) {
    await reloadedUploader.uploadChunk();
  }
}
