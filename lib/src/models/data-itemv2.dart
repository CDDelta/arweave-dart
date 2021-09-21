import 'dart:convert';
import 'dart:typed_data';

import '../crypto/crypto.dart';
import '../utils.dart';
import 'models.dart';

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
  Future<void> sign(Wallet wallet) async {
    final signatureData = await getSignatureData();
    final rawSignature = await wallet.sign(signatureData);

    _signature = encodeBytesToBase64(rawSignature);

    final idHash = await sha256.hash(rawSignature);
    _id = encodeBytesToBase64(idHash.bytes);
  }

  @override
  Future<void> signWithRawSignature(Uint8List rawSignature) async {
    _signature = encodeBytesToBase64(rawSignature);

    final idHash = await sha256.hash(rawSignature);
    _id = encodeBytesToBase64(idHash.bytes);
  }

  /// Verify that the [DataItem] is valid.
  @override
  Future<bool> verify() async {
    try {
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

  Future<ByteBuffer> asBinary() {
    final bytesArray = Uint8List.fromList([]);

    final owner = utf8.encode(this.owner);
    final target = utf8.encode(this.target);

    final tags = this
        .tags
        .map((tag) => utf8.encode(json.encode(tag.toJson())))
        .reduce((value, element) => value + element);

    throw UnimplementedError();
  }
//Refrence to create Data bundle from arbundles lib
//   createData(
//   data: string | Uint8Array,
//   signer: Signer,
//   opts?: DataItemCreateOptions,
// ): DataItem {
//   // TODO: Add asserts
//   // Parse all values to a buffer and
//   const _owner = signer.publicKey;
//   assert(
//     _owner.byteLength == OWNER_LENGTH,
//     new Error(`Public key isn't the correct length: ${_owner.byteLength}`)
//   );

//   const _target = opts?.target ? base64url.toBuffer(opts.target) : null;
//   const target_length = 1 + (_target?.byteLength ?? 0);
//   const _anchor = opts?.anchor ? Buffer.from(opts.anchor) : null;
//   const anchor_length = 1 + (_anchor?.byteLength ?? 0);
//   const _tags = (opts?.tags?.length ?? 0) > 0 ? serializeTags(opts.tags) : null;
//   const tags_length = 16 + (_tags ? _tags.byteLength : 0);
//   const _data =
//     typeof data === "string" ? Buffer.from(data) : Buffer.from(data);
//   const data_length = _data.byteLength;

//   // See [https://github.com/joshbenaron/arweave-standards/blob/ans104/ans/ANS-104.md#13-dataitem-format]
//   const length =
//     2 +
//     512 +
//     _owner.byteLength +
//     target_length +
//     anchor_length +
//     tags_length +
//     data_length;
//   // Create array with set length
//   const bytes = Buffer.alloc(length);

//   bytes.set(shortTo2ByteArray(signer.signatureType), 0);
//   // Push bytes for `signature`
//   bytes.set(EMPTY_ARRAY, 2);
//   // // Push bytes for `id`
//   // bytes.set(EMPTY_ARRAY, 32);
//   // Push bytes for `owner`

//   assert(_owner.byteLength == 512, new Error("Owner must be 512 bytes"));
//   bytes.set(_owner, 514);

//   // Push `presence byte` and push `target` if present
//   // 64 + OWNER_LENGTH
//   bytes[1026] = _target ? 1 : 0;
//   if (_target) {
//     assert(_target.byteLength == 32, new Error("Target must be 32 bytes"));
//     bytes.set(_target, 1027);
//   }

//   // Push `presence byte` and push `anchor` if present
//   // 64 + OWNER_LENGTH
//   const anchor_start = 1026 + target_length;
//   let tags_start = anchor_start + 1;
//   bytes[anchor_start] = _anchor ? 1 : 0;
//   if (_anchor) {
//     tags_start += _anchor.byteLength;
//     assert(_anchor.byteLength == 32, new Error("Anchor must be 32 bytes"));
//     bytes.set(_anchor, anchor_start + 1);
//   }

//   bytes.set(longTo8ByteArray(opts?.tags?.length ?? 0), tags_start);
//   const bytesCount = longTo8ByteArray(_tags?.byteLength ?? 0);
//   bytes.set(bytesCount, tags_start + 8);
//   if (_tags) {
//     bytes.set(_tags, tags_start + 16);
//   }

//   const data_start = tags_start + tags_length;

//   bytes.set(_data, data_start);

//   return new DataItem(bytes);
// }
}
