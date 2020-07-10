import 'package:arweave/arweave.dart';

final digestPattern = RegExp(r'^[a-z0-9-_]{43}$', caseSensitive: false);

Arweave getArweaveClient() => Arweave(
      host: 'arweave.net',
      protocol: "https",
      port: 443,
    );
