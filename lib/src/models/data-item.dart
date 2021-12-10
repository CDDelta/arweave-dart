import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/src/utils/bundle_tag_parser.dart';

import '../crypto/crypto.dart';
import '../utils.dart';
import 'models.dart';

final MIN_BINARY_SIZE = 1044;

/// ANS-104 [DataItem]
/// Spec: https://github.com/joshbenaron/arweave-standards/blob/ans104/ans/ANS-104.md
class DataItem implements TransactionBase {
  @override
  String get id => _id;
  late String _id;

  @override
  String get owner => _owner;
  late String _owner;

  @override
  late String target;
  late String nonce;

  @override
  List<Tag> get tags => _tags;
  List<Tag> _tags;

  /// The unencoded data associated with this [DataItem].
  ///
  /// This data is persisted unencoded to avoid having to convert it back from Base64 when signing.
  @override
  late Uint8List data;

  @override
  String get signature => _signature;
  late String _signature;
  late ByteBuffer binary;

  /// This constructor is reserved for JSON serialisation.
  ///
  /// [DataItem.withJsonData()] and [DataItem.withBlobData()] are the recommended ways to construct data items.
  DataItem({
    String? owner,
    String? target,
    String? nonce,
    List<Tag>? tags,
    String? data,
    Uint8List? dataBytes,
  })  : target = target ?? '',
        nonce = nonce ?? '',
        _owner = owner ?? '',
        data = data != null
            ? decodeBase64ToBytes(data)
            : (dataBytes ?? Uint8List(0)),
        _tags = tags ?? [];

  /// Constructs a [DataItem] with the specified JSON data and appropriate Content-Type tag.
  factory DataItem.withJsonData({
    String? owner,
    String target = '',
    String nonce = '',
    List<Tag>? tags,
    required Object data,
  }) =>
      DataItem.withBlobData(
        owner: owner,
        target: target,
        nonce: nonce,
        tags: tags,
        data: utf8.encode(json.encode(data)) as Uint8List,
      )..addTag('Content-Type', 'application/json');

  /// Constructs a [DataItem] with the specified blob data.
  factory DataItem.withBlobData({
    String? owner,
    String target = '',
    String nonce = '',
    List<Tag>? tags,
    required Uint8List data,
  }) =>
      DataItem(
        owner: owner,
        target: target,
        nonce: nonce,
        tags: tags,
        dataBytes: data,
      );

  @override
  void setOwner(String owner) => _owner = owner;

  @override
  void addTag(String name, String value) {
    tags.add(
      Tag(
        encodeStringToBase64(name),
        encodeStringToBase64(value),
      ),
    );
  }

  @override
  Future<Uint8List> getSignatureData() => deepHash(
        [
          utf8.encode('dataitem'),
          utf8.encode('1'), //Transaction format
          utf8.encode('1'), //Signature type
          decodeBase64ToBytes(owner),
          decodeBase64ToBytes(target),
          decodeBase64ToBytes(nonce),
          serializeTags(tags: tags),
          data,
        ],
      );

  /// Signs the [DataItem] using the specified wallet and sets the `id` and `signature` appropriately.
  @override
  Future<Uint8List> sign(Wallet wallet) async {
    final signatureData = await getSignatureData();
    final rawSignature = await wallet.sign(signatureData);

    _signature = encodeBytesToBase64(rawSignature);

    final idHash = await sha256.hash(rawSignature);
    _id = encodeBytesToBase64(idHash.bytes);
    return Uint8List.fromList(idHash.bytes);
  }

  int getSize() {
    const targetLength = 1;
    final anchorLength = nonce.isEmpty ? 1 : 1 + 32;

    final serializedTags = serializeTags(tags: tags);
    final tagsLength = 16 + serializedTags.lengthInBytes;

    const arweaveSignerLength = 512;
    const ownerLength = 512;

    const signatureTypeLength = 2;

    final dataLength = data.lengthInBytes;

    final totalByteLength = arweaveSignerLength +
        ownerLength +
        signatureTypeLength +
        targetLength +
        anchorLength +
        tagsLength +
        dataLength;
    return totalByteLength;
  }

  /// Verify that the [DataItem] is valid.
  @override
  Future<bool> verify() async {
    final buffer = (await asBinary()).toBytes().buffer;
    try {
      if (buffer.lengthInBytes < MIN_BINARY_SIZE) {
        return false;
      }
      final sigType = byteArrayToLong(buffer.asUint8List().sublist(0, 2));
      assert(sigType == 1);
      var tagsStart = 2 + 512 + 512 + 2;
      final targetPresent = buffer.asUint8List()[1026] == 1;
      tagsStart += targetPresent ? 32 : 0;
      final anchorPresentByte = targetPresent ? 1059 : 1027;
      final anchorPresent = buffer.asUint8List()[anchorPresentByte] == 1;
      tagsStart += anchorPresent ? 32 : 0;

      final numberOfTags = byteArrayToLong(
          buffer.asUint8List().sublist(tagsStart, tagsStart + 8));
      final numberOfTagBytesArray =
          buffer.asUint8List().sublist(tagsStart + 8, tagsStart + 16);
      final numberOfTagBytes = byteArrayToLong(numberOfTagBytesArray);

      if (numberOfTags > 0) {
        try {
          //TODO: Deserialize and check tags

          if (tags.length != numberOfTags) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }
      final signatureData = await getSignatureData();
      final claimedSignatureBytes = decodeBase64ToBytes(signature);

      final idHash = await sha256.hash(claimedSignatureBytes);
      final expectedId = encodeBytesToBase64(idHash.bytes);

      if (id != expectedId) return false;

      return rsaPssVerify(
        input: signatureData,
        signature: claimedSignatureBytes,
        modulus: decodeBase64ToBigInt(owner),
        publicExponent: publicExponent,
      );
    } catch (_) {
      return false;
    }
  }

  ByteBuffer getRawTags() {
    final tagsStart = getTagsStart();
    final tagsSize = byteArrayToLong(
        binary.asUint8List().sublist(tagsStart + 8, tagsStart + 16));
    return binary
        .asUint8List()
        .sublist(tagsStart + 16, tagsStart + 16 + tagsSize)
        .buffer;
  }

  int getTagsStart() {
    var tagsStart = 2 + 512 + 512 + 2;
    var targetPresent = binary.asUint8List()[1026] == 1;
    tagsStart += targetPresent ? 32 : 0;
    var anchorPresentByte = targetPresent ? 1059 : 1027;
    var anchorPresent = binary.asUint8List()[anchorPresentByte] == 1;
    tagsStart += anchorPresent ? 32 : 0;

    return tagsStart;
  }

  ByteBuffer getRawData() {
    final tagsStart = getTagsStart();

    final numberOfTagBytesArray =
        binary.asUint8List().sublist(tagsStart + 8, tagsStart + 16);
    final numberOfTagBytes = byteArrayToLong(numberOfTagBytesArray);
    final dataStart = tagsStart + 16 + numberOfTagBytes;

    return binary.asUint8List().sublist(dataStart, binary.lengthInBytes).buffer;
  }

  // Returns the start byte of the tags section (number of tags)
  int getTargetStart() {
    return 1026;
  }

  // Returns the start byte of the tags section (number of tags)
  int getAnchorStart() {
    var anchorStart = getTargetStart() + 1;
    final targetPresent = binary.asUint8List()[getTargetStart()] == 1;
    anchorStart += targetPresent ? 32 : 0;

    return anchorStart;
  }

  Future<BytesBuilder> asBinary() async {
    final decodedOwner = decodeBase64ToBytes(owner);
    final decodedTarget = decodeBase64ToBytes(target);
    final anchor = decodeBase64ToBytes(nonce);
    final tags = serializeTags(tags: this.tags);

    // See [https://github.com/joshbenaron/arweave-standards/blob/ans104/ans/ANS-104.md#13-dataitem-format]
    assert(decodedOwner.buffer.lengthInBytes == 512);
    final bytesBuilder = BytesBuilder();

    bytesBuilder.add(shortTo2ByteArray(1));
    bytesBuilder.add(decodeBase64ToBytes(signature));
    bytesBuilder.add(decodedOwner);
    bytesBuilder.addByte(decodedTarget.isNotEmpty ? 1 : 0);

    if (decodedTarget.isNotEmpty) {
      assert(
          decodedTarget.lengthInBytes == 32, print('Target must be 32 bytes'));
      bytesBuilder.add(decodedTarget);
    }
    bytesBuilder.addByte(anchor.isNotEmpty ? 1 : 0);
    if (anchor.isNotEmpty) {
      assert(
          anchor.buffer.lengthInBytes == 32, print('Anchor must be 32 bytes'));
      bytesBuilder.add(anchor);
    }
    bytesBuilder.add(longTo8ByteArray(this.tags.length));
    final bytesCount = longTo8ByteArray(tags.lengthInBytes);
    bytesBuilder.add(bytesCount);
    if (tags.isNotEmpty) {
      bytesBuilder.add(tags);
    }
    bytesBuilder.add(data);
    return bytesBuilder;
  }
}
