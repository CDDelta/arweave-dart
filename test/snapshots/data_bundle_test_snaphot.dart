
import 'package:arweave/src/models/models.dart';
import 'package:arweave/src/utils.dart';

final testTagsSnapshot = <Tag>[
  Tag(
    encodeStringToBase64('MyTag'),
    encodeStringToBase64('Foo'),
  ),
  Tag(
    encodeStringToBase64('MyTag'),
    encodeStringToBase64('Foo'),
  ),
  Tag(
    encodeStringToBase64('MyTag'),
    encodeStringToBase64('Foo'),
  )
];

final testTagsBufferSnapshot = [
  6,
  10,
  77,
  121,
  84,
  97,
  103,
  6,
  70,
  111,
  111,
  10,
  77,
  121,
  84,
  97,
  103,
  6,
  70,
  111,
  111,
  10,
  77,
  121,
  84,
  97,
  103,
  6,
  70,
  111,
  111,
  0
];
