# Arweave Dart SDK

![tests](https://github.com/CDDelta/arweave-dart/workflows/tests/badge.svg)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/CDDelta/arweave-dart/issues)

Dart package for interfacing with the Arweave network, modelled after [arweave-js](https://github.com/ArweaveTeam/arweave-js).

## Installation

`arweave-dart` is currently not available on [pub.dev](https://pub.dev) but you can use it by referencing this repository in your `pubspec.yaml` like so:

```yaml
dependencies:
  arweave:
    git: https://github.com/CDDelta/arweave-dart.git
```

You can optionally pin your dependency to a specific commit, branch, or tag to avoid possible breaking changes like so:

```yaml
dependencies:
  arweave:
    git:
      url: https://github.com/CDDelta/arweave-dart.git
      ref: some-branch
```

## Initialisation

Once you have the package, you can create an instance of the client like so:

```dart
import 'package:arweave/arweave.dart';

void main() {
  var client = Arweave(
    host: 'arweave.net',
    protocol: "https",
    port: 443,
  );
}
```

## Usage

### Utilities

Dart's Base64 encoder/decoder is incompatible with Arweave's returned Base64 content, so `arweave-dart` exposes utilities for working with Base64 from Arweave. It also includes other utilities for AR/Winston conversions etc.

To use these utilities, import them like so:

```dart
import 'package:arweave/utils.dart' as arweaveUtils;
```

## Development

To rebuild the generated code (eg. for JSON serialisation) run:
`dart pub run build_runner build`
