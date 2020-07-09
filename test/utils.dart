import 'package:arweave/arweave.dart';

Arweave getArweaveClient() => Arweave(
      config: ApiConfig(host: 'arweave.net'),
    );
