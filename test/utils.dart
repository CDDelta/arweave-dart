import 'dart:convert';
import 'dart:io';

import 'package:arweave/arweave.dart';

final digestPattern = RegExp(r'^[a-z0-9-_]{43}$', caseSensitive: false);

Future<Wallet> getTestWallet() async => Wallet.fromJwk(
      json.decode(
        await File('test/fixtures/test-key.json').readAsString(),
      ),
    );
