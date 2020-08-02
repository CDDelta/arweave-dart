# Arweave Dart SDK
![build](https://github.com/CDDelta/arweave-dart/workflows/build/badge.svg)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/CDDelta/arweave-dart/issues)

Dart package for interfacing with the Arweave network, modelled after [arweave-js](https://github.com/ArweaveTeam/arweave-js).

## Usage
`arweave-dart` is currently not available on [pub.dev](https://pub.dev) but you can use this package by referencing this repository in your `pubspec.yaml` like so:
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
