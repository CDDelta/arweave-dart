import 'package:arweave/src/models/models.dart';

import 'bundle_tag_parser.dart';

int estimateDataItemSize({
  required int fileDataSize,
  required List<Tag> tags,
  required List<int> nonce,
}) {
  const targetLength = 1;
  final anchorLength = nonce.isEmpty ? 1 : 1 + 32;

  final serializedTags = serializeTags(tags: tags);
  final tagsLength = 16 + serializedTags.lengthInBytes;

  const arweaveSignerLength = 512;
  const ownerLength = 512;

  const signatureTypeLength = 2;

  final dataLength = fileDataSize;

  final totalByteLength = arweaveSignerLength +
      ownerLength +
      signatureTypeLength +
      targetLength +
      anchorLength +
      tagsLength +
      dataLength;
  return totalByteLength;
}
