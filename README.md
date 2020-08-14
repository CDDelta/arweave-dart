# Arweave Dart SDK

![tests](https://github.com/CDDelta/arweave-dart/workflows/test/badge.svg)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/CDDelta/arweave-dart/issues)

Dart package for interfacing with the Arweave network, modelled after [arweave-js](https://github.com/ArweaveTeam/arweave-js).

## Installation

This package is currently not available on [pub.dev](https://pub.dev) but you can use it by referencing this repository in your `pubspec.yaml` like so:

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

## Usage

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

## Development

To update build the generated code (ie. for JSON serialisation) run:
`dart pub run build_runner build`
