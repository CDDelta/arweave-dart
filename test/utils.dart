import 'dart:convert';
import 'dart:io';

import 'package:arweave/arweave.dart';

final digestPattern = RegExp(r'^[a-z0-9-_]{43}$', caseSensitive: false);

Future<Transaction> getTestTransaction(String path) async =>
    Transaction.fromJson(
      json.decode(
        await File(path).readAsString(),
      ),
    );

Future<Wallet> getTestWallet(
        [String path = 'test/fixtures/test-key.json']) async =>
    Wallet.fromJwk(
      json.decode(
        await File(path).readAsString(),
      ),
    );
