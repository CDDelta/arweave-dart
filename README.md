# Arweave Dart SDK

![tests](https://github.com/CDDelta/arweave-dart/workflows/tests/badge.svg)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/CDDelta/arweave-dart/issues)

Dart package for interfacing with the Arweave network, modelled after [arweave-js](https://github.com/ArweaveTeam/arweave-js).

## Installation

`arweave-dart` is currently not available on [pub.dev](https://pub.dev) but you can use it by referencing this repository in your `pubspec.yaml` as shown below:

```yaml
dependencies:
  arweave:
    git: https://github.com/CDDelta/arweave-dart.git
```

You can optionally pin your dependency to a specific commit, branch, or tag to avoid possible breaking changes:

```yaml
dependencies:
  arweave:
    git:
      url: https://github.com/CDDelta/arweave-dart.git
      ref: some-branch
```

## Initialisation

Once you have the package, you can create an instance of the client with its default configuration:

```dart
import 'package:arweave/arweave.dart';
void main() {
  var client = Arweave();
}
```

This will create an instance of the client that connects to the `arweave.net` gateway or if you're running on the web, this will detect the origin you're hosting on and use that as the gateway to connect to.

You can optionally choose to provide your own gateway url:

```dart
Arweave(gatewayUrl: Uri.parse('https://arweave.dev'));
```

## Usage

### Working with Wallets

Loading an Arweave wallet can be done as shown below:

```dart
Wallet.fromJwk(json.decode('<wallet data>'));
```

### Creating Transactions

Creating transactions with `arweave-dart` is easy. First prepare a transaction like below, optionally adding some tags:

```dart
final transaction = await client.transactions.prepare(
  Transaction.withBlobData(data: utf8.encode('Hello world!')),
  wallet,
);
transaction.addTag('App-Name', 'Hello World App');
transaction.addTag('App-Version', '1.0.0');
```

Secondly, sign the transaction:

```dart
await transaction.sign(wallet);
```

Finally upload the transaction.

This can be done in a single call, useful for small transactions.

```dart
await client.transactions.post(transaction);
```

Or progressively for more granularity.

```dart
await for (final upload in client.transactions.upload(transaction)) {
  print('${upload.progress * 100}%');
}
```

### Using Data Bundles

Use ANS-104 data bundles by first preparing some data items as so:

```dart
final dataItem = DataItem.withBlobData(
  owner: wallet.owner,
  data: utf8.encode('hello world'),
)
  ..addTag('MyTag', '0')
  ..addTag('OtherTag', 'Foo');
await dataItem.sign(wallet);
```

and then creating the data bundle transaction:

```dart
final transaction = await client.transactions.prepare(
  Transaction.withDataBundle(bundle: DataBundle(items: [dataItem])),
  wallet,
);
```

### Utilities

Dart's Base64 encoder/decoder is incompatible with Arweave's returned Base64 content, so `arweave-dart` exposes utilities for working with Base64 from Arweave. It also includes other utilities for AR/Winston conversions etc.

To use these utilities, import them like so:

```dart
import 'package:arweave/utils.dart' as utils;
```

## Development

To rebuild the generated code (eg. for JSON serialisation) run:

```shell
dart pub run build_runner build
```

### Testing

To test, run the following command

```shell
dart test -p "chrome,vm"
```
