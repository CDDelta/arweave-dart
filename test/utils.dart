import 'package:arweave/arweave.dart';

const digestRegex = r'/^[a-z0-9-_]{43}$/i';

Arweave getArweaveClient() => Arweave(
      config: ApiConfig(
        host: 'arweave.net',
        protocol: "https",
        port: 443,
      ),
    );
