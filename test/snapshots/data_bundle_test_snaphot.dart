
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

final testFileHash = [142, 252, 10, 230, 71, 134, 191, 96, 33, 72, 42, 16, 99, 185, 150, 242, 228, 245, 21, 169, 15, 175, 71, 245, 191, 128, 35, 189, 120, 37, 101, 149, 144, 164, 61, 15, 147, 19, 98, 201, 177, 9, 28, 126, 59, 224, 83, 101];
