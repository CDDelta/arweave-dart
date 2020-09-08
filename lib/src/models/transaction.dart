import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/src/crypto/crypto.dart';
import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/export.dart';

import '../utils.dart';
import 'tag.dart';
import 'transaction_chunk.dart';
import 'wallet.dart';

part 'transaction.g.dart';

String _bigIntToString(BigInt v) => v.toString();
BigInt _stringToBigInt(String v) => BigInt.parse(v);

@JsonSerializable()
class Transaction {
  @JsonKey(defaultValue: 1)
  int get format => _format;
  int _format;

  String get id => _id;
  String _id;

  @JsonKey(name: 'last_tx')
  String get lastTx => _lastTx;
  String _lastTx;

  String get owner => _owner;
  String _owner;

  List<Tag> get tags => _tags;
  List<Tag> _tags;

  String get target => _target;
  String _target;

  @JsonKey(fromJson: _stringToBigInt, toJson: _bigIntToString)
  BigInt get quantity => _quantity;
  BigInt _quantity;

  Uint8List get data => _data;
  Uint8List _data;

  @JsonKey(name: 'data_size')
  String get dataSize => _dataSize;
  String _dataSize;

  @JsonKey(name: 'data_root')
  String get dataRoot => _dataRoot;
  String _dataRoot;

  @JsonKey(fromJson: _stringToBigInt, toJson: _bigIntToString)
  BigInt get reward => _reward;
  BigInt _reward;

  String get signature => _signature;
  String _signature;

  @JsonKey(ignore: true)
  TransactionChunksWithProofs chunks;

  /// This constructor is reserved for JSON serialisation.
  /// [Transaction.withStringData()] and [Transaction.withBlobData()] are the recommended ways to construct data transactions.
  Transaction({
    int format = 1,
    String id,
    String lastTx,
    String owner,
    List<Tag> tags,
    String target = "",
    BigInt quantity,
    String data,
    Uint8List dataBytes,
    String dataSize = "0",
    String dataRoot,
    BigInt reward,
    String signature,
  })  : _format = format,
        _id = id,
        _lastTx = lastTx,
        _owner = owner,
        _tags = tags,
        _target = target,
        _quantity = quantity ?? BigInt.zero,
        _data = data != null
            ? decodeBase64ToBytes(data)
            : (dataBytes ?? Uint8List(0)),
        _dataSize = dataSize,
        _dataRoot = dataRoot,
        _reward = reward ?? BigInt.zero,
        _signature = signature {
    _tags = _tags ?? [];
  }

  /// Constructs a transaction with the specified string data encoded to Base64 and computed data size.
  factory Transaction.withStringData({
    int format = 1,
    String owner,
    List<Tag> tags,
    String target = "",
    BigInt quantity,
    String data,
    BigInt reward,
  }) =>
      Transaction.withBlobData(
        format: format,
        owner: owner,
        tags: tags,
        target: target,
        quantity: quantity,
        data: utf8.encode(data),
        reward: reward,
      );

  /// Constructs a transaction with the specified blob data encoded to Base64 and computed data size.
  factory Transaction.withBlobData({
    int format = 1,
    String owner,
    List<Tag> tags,
    String target = "",
    BigInt quantity,
    Uint8List data,
    BigInt reward,
  }) =>
      Transaction(
        format: format,
        owner: owner,
        tags: tags,
        target: target,
        quantity: quantity,
        dataBytes: data,
        dataSize: data.lengthInBytes.toString(),
        reward: reward,
      );

  void setLastTx(String lastTx) => _lastTx = lastTx;

  void setOwner(String owner) => _owner = owner;

  void setReward(BigInt reward) => _reward = reward;

  Future<void> prepareChunks() async {
    if (chunks != null) return;

    if (data.isNotEmpty) {
      chunks = await generateTransactionChunks(data);
      _dataRoot = encodeBytesToBase64(chunks.dataRoot);
    } else {
      chunks = TransactionChunksWithProofs(Uint8List(0), [], []);
    }
  }

  /// Returns a chunk in a format suitable for posting to /chunk.
  TransactionChunk getChunk(int index) {
    if (chunks == null) throw StateError('Chunks have not been prepared.');

    final proof = chunks.proofs[index];
    final chunk = chunks.chunks[index];

    return TransactionChunk(
      dataRoot: dataRoot,
      dataSize: dataSize,
      dataPath: encodeBytesToBase64(proof.proof),
      offset: proof.offset.toString(),
      chunk: encodeBytesToBase64(
          Uint8List.sublistView(data, chunk.minByteRange, chunk.maxByteRange)),
    );
  }

  void setSignature(String signature, String id) {
    this._signature = signature;
    this._id = id;
  }

  Future<Uint8List> getSignatureData() async {
    switch (format) {
      case 1:
        return Uint8List.fromList(
          decodeBase64ToBytes(owner) +
              decodeBase64ToBytes(target) +
              data +
              utf8.encode(quantity.toString()) +
              utf8.encode(reward.toString()) +
              decodeBase64ToBytes(lastTx) +
              tags
                  .expand((t) =>
                      decodeBase64ToBytes(t.name) +
                      decodeBase64ToBytes(t.value))
                  .toList(),
        );
      case 2:
        return deepHash([
          utf8.encode(format.toString()),
          decodeBase64ToBytes(owner),
          decodeBase64ToBytes(target),
          utf8.encode(quantity.toString()),
          utf8.encode(reward.toString()),
          decodeBase64ToBytes(lastTx),
          tags
              .map(
                (t) => [
                  decodeBase64ToBytes(t.name),
                  decodeBase64ToBytes(t.value),
                ],
              )
              .toList(),
          utf8.encode(dataSize),
          decodeBase64ToBytes(dataRoot),
        ]);
      default:
        throw Exception('Unexpected transaction format!');
    }
  }

  void addTag(String name, String value) {
    this.tags.add(Tag(encodeStringToBase64(name), encodeStringToBase64(value)));
  }

  Future<void> sign(Wallet wallet) async {
    final signatureData = await getSignatureData();
    final rawSignature = wallet.sign(signatureData);

    final id = encodeBytesToBase64(sha256.convert(rawSignature.bytes).bytes);

    setSignature(encodeBytesToBase64(rawSignature.bytes), id);
  }

  Future<bool> verify() async {
    final signatureData = await getSignatureData();
    final claimedRawSignature = decodeBase64ToBytes(signature);

    final expectedId =
        encodeBytesToBase64(sha256.convert(claimedRawSignature).bytes);

    if (id != expectedId) return false;

    var signer = PSSSigner(RSAEngine(), SHA256Digest(), SHA256Digest())
      ..init(
        false,
        ParametersWithSalt(
          PublicKeyParameter<RSAPublicKey>(
            RSAPublicKey(
              decodeBase64ToBigInt(owner),
              publicExponent,
            ),
          ),
          null,
        ),
      );

    return signer.verifySignature(
        signatureData, PSSSignature(claimedRawSignature));
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
