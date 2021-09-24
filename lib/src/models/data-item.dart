import 'dart:convert';
import 'dart:typed_data';

import '../crypto/crypto.dart';
import '../utils.dart';
import 'models.dart';

final MIN_BINARY_SIZE = 1044;

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
  final Uint8List data;

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
          utf8.encode('1'),
          decodeBase64ToBytes(owner),
          decodeBase64ToBytes(target),
          decodeBase64ToBytes(nonce),
          tags
              .map(
                (t) => [
                  decodeBase64ToBytes(t.name),
                  decodeBase64ToBytes(t.value),
                ],
              )
              .toList(),
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

  /// Verify that the [DataItem] is valid.
  @override
  Future<bool> verify() async {
    final buffer = asBinary();
    try {
      if (buffer.lengthInBytes < MIN_BINARY_SIZE) {
        return false;
      }
      final sigType = byteArrayToLong(buffer.asUint8List().sublist(0, 2));
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

          // if (tags.length !== numberOfTags) {
          //   return false;
          // }
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

  ByteBuffer asBinary() {
    final decodedOwner = decodeBase64ToBytes(owner);
    final decodedTarget = decodeBase64ToBytes(target);
    final target_length = 1 + (decodedTarget.lengthInBytes);
    //We dont use anchors
    final anchor = null;
    final anchor_length = 1;
    // final tags = this
    //     .tags
    //     .map((tag) => utf8.encode(json.encode(tag.toJson())) as Uint8List)
    //     .reduce((value, element) => Uint8List.fromList((value + element)));
    final tags = Uint8List.fromList([]);
    final tags_length = 16 + (0);
    final data = this.data.buffer;

    final data_length = data.lengthInBytes;
    final signature_type_length = 2;
    final signature_length = 512;
    // See [https://github.com/joshbenaron/arweave-standards/blob/ans104/ans/ANS-104.md#13-dataitem-format]
    final length = signature_type_length +
        signature_length +
        decodedOwner.buffer.lengthInBytes +
        target_length +
        anchor_length +
        tags_length +
        data_length;
    assert(decodedOwner.buffer.lengthInBytes == 512);
    // Create array with set length
    final bytes = Uint8List(length);
    bytes.setAll(0, shortTo2ByteArray(1));

    // Push bytes for `signature`
    bytes.setAll(2, <int>[]);
    // // Push bytes for `id`
    // bytes.set(EMPTY_ARRAY, 32);
    // Push bytes for `owner`

    bytes.setAll(514, decodedOwner);

    // Push `presence byte` and push `target` if present
    // 64 + OWNER_LENGTH
    bytes[1026] = decodedTarget.isNotEmpty ? 1 : 0;
    if (decodedTarget.isNotEmpty) {
      assert(
          decodedTarget.lengthInBytes == 32, print('Target must be 32 bytes'));
      bytes.setAll(1027, decodedTarget);
    }

    // Push `presence byte` and push `anchor` if present
    // 64 + OWNER_LENGTH
    final anchor_start = 1026 + target_length;
    var tags_start = anchor_start + 1;
    bytes[anchor_start] = anchor != null ? 1 : 0;
    // if (anchor!=null) {
    //   tags_start += anchor.byteLength;
    //   assert(_anchor.byteLength == 32, new Error("Anchor must be 32 bytes"));
    //   bytes.set(_anchor, anchor_start + 1);
    // }

    bytes.setAll(tags_start, longTo8ByteArray(tags.length));
    final bytesCount = longTo8ByteArray(tags.lengthInBytes);
    bytes.setAll(tags_start + 8, bytesCount);
    if (tags.isNotEmpty) {
      bytes.setAll(tags_start + 16, tags);
    }

    final data_start = tags_start + tags_length;

    bytes.setAll(data_start, data.asUint8List());

    return bytes.buffer;
  }
}
