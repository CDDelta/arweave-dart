import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../crypto/crypto.dart';
import '../utils.dart';
import 'models.dart';

part 'data-item.g.dart';

@JsonSerializable()
class DataItem implements TransactionBase {
  @override
  String get id => _id;
  String _id;

  @override
  String get owner => _owner;
  String _owner;

  @override
  final String target;
  final String nonce;

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
  String _signature;

  /// This constructor is reserved for JSON serialisation.
  ///
  /// [DataItem.withJsonData()] and [DataItem.withBlobData()] are the recommended ways to construct data items.
  DataItem({
    String id,
    String owner,
    this.target,
    this.nonce,
    List<Tag> tags,
    String data,
    Uint8List dataBytes,
    String signature,
  })  : _id = id,
        _owner = owner ?? '',
        data = data != null
            ? decodeBase64ToBytes(data)
            : (dataBytes ?? Uint8List(0)),
        _signature = signature {
    _tags = tags ?? [];
  }

  /// Constructs a [DataItem] with the specified JSON data and appropriate Content-Type tag.
  factory DataItem.withJsonData({
    String owner,
    String target = '',
    String nonce = '',
    List<Tag> tags,
    @required Object data,
  }) =>
      DataItem.withBlobData(
        owner: owner,
        target: target,
        nonce: nonce,
        tags: tags,
        data: utf8.encode(json.encode(data)),
      )..addTag('Content-Type', 'application/json');

  /// Constructs a [DataItem] with the specified blob data.
  factory DataItem.withBlobData({
    String owner,
    String target = '',
    String nonce = '',
    List<Tag> tags,
    @required Uint8List data,
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

  factory DataItem.fromJson(Map<String, dynamic> json) =>
      _$DataItemFromJson(json);

  /// Returns the [DataItem] as a JSON map with the `data` encoded as Base64.
  Map<String, dynamic> toJson() {
    final json = _$DataItemToJson(this);
    // Lazily encode data bytes to Base64.
    // TODO: Make async
    json['data'] = encodeBytesToBase64(json['data']);
    return json;
  }
}
