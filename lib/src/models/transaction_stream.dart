import 'dart:convert';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:json_annotation/json_annotation.dart';

import '../crypto/crypto.dart';
import '../utils.dart';

part 'transaction_stream.g.dart';

typedef DataStreamGenerator = Stream<Uint8List> Function([int? start, int? end]);

String _bigIntToString(BigInt v) => v.toString();
BigInt _stringToBigInt(String v) => BigInt.parse(v);
Future<Uint8List> _bufferStream(Stream<Uint8List> stream) async {
  final buffer = Uint8List(0);
  await for (final data in stream) {
    buffer.addAll(data);
  }
  return Uint8List.fromList(buffer);
}

@JsonSerializable()
class TransactionStream implements Transaction {
  @JsonKey(defaultValue: 1)
  final int format;

  @override
  String get id => _id;
  late String _id;

  @JsonKey(name: 'last_tx')
  String? get lastTx => _lastTx;
  String? _lastTx;

  @override
  String? get owner => _owner;
  String? _owner;

  @override
  List<Tag> get tags => _tags;
  late List<Tag> _tags;

  @override
  String get target => _target;
  String _target;

  @JsonKey(fromJson: _stringToBigInt, toJson: _bigIntToString)
  BigInt get quantity => _quantity;
  BigInt _quantity;

  /// The unencoded data associated with this [Transaction].
  ///
  /// This data is persisted unencoded to avoid having to convert it back from Base64 when signing.
  @override
  Uint8List get data => throw UnimplementedError('Cannot access data from a stream transaction');
  // Uint8List _data;

  @JsonKey(ignore: true)
  DataStreamGenerator get dataStreamGenerator => _dataStreamGenerator;
  DataStreamGenerator _dataStreamGenerator;

  @JsonKey(name: 'data_size')
  String get dataSize => _dataSize;
  String _dataSize = '0';

  @JsonKey(name: 'data_root')
  String get dataRoot => _dataRoot;
  late String _dataRoot;

  @JsonKey(fromJson: _stringToBigInt, toJson: _bigIntToString)
  BigInt get reward => _reward;
  late BigInt _reward;

  @override
  String get signature => _signature;
  late String _signature;

  @JsonKey(ignore: true)
  TransactionChunksWithProofs? get chunks => _chunks;
  TransactionChunksWithProofs? _chunks;

  /// This constructor is reserved for JSON serialisation.
  ///
  /// [TransactionStream.withJsonData()] and [TransactionStream.withBlobData()] are the recommended ways to construct data transactions.
  /// This constructor will not compute the data size or encode incoming data to Base64 for you.
  TransactionStream({
    this.format = 2,
    String? id,
    String? lastTx,
    String? owner,
    List<Tag>? tags,
    String? target,
    BigInt? quantity,
    DataStreamGenerator? dataStreamGenerator,
    String? dataSize,
    String? dataRoot,
    BigInt? reward,
    String? signature,
  })  : _target = target ?? '',
        _quantity = quantity ?? BigInt.zero,
        _dataStreamGenerator = dataStreamGenerator ?? 
          (([int? s, int? e]) => Stream.value(Uint8List(0))),
        _dataRoot = dataRoot ?? '',
        _reward = reward ?? BigInt.zero,
        _owner = owner,
        _lastTx = lastTx {
    if (signature != null) {
      _signature = signature;
    }
    if (dataSize != null) {
      _dataSize = dataSize;
    }
    if (id != null) {
      _id = id;
    }

    _tags = tags != null ? [...tags] : [];
  }

  // /// Constructs a [Transaction] with the specified [DataBundle], computed data size, and appropriate bundle tags.
  // factory TransactionStream.withDataBundle({
  //   String? owner,
  //   List<Tag>? tags,
  //   String? target,
  //   BigInt? quantity,
  //   required Uint8List bundleBlob,
  //   BigInt? reward,
  // }) =>
  //     TransactionStream.withBlobData(
  //       owner: owner,
  //       tags: tags,
  //       target: target,
  //       quantity: quantity,
  //       data: bundleBlob,
  //       reward: reward,
  //     )
  //       ..addTag('Bundle-Format', 'binary')
  //       ..addTag('Bundle-Version', '2.0.0');

  // /// Constructs a [Transaction] with the specified JSON data, computed data size, and Content-Type tag.
  // factory TransactionStream.withJsonData({
  //   String? owner,
  //   List<Tag>? tags,
  //   String? target,
  //   BigInt? quantity,
  //   required Object data,
  //   BigInt? reward,
  // }) =>
  //     TransactionStream.withBlobData(
  //       owner: owner,
  //       tags: tags,
  //       target: target,
  //       quantity: quantity,
  //       data: utf8.encode(json.encode(data)) as Uint8List,
  //       reward: reward,
  //     )..addTag('Content-Type', 'application/json');

  /// Constructs a [Transaction] with the specified blob data and computed data size.
  factory TransactionStream.withBlobData({
    String? owner,
    List<Tag>? tags,
    String? target,
    BigInt? quantity,
    required DataStreamGenerator dataStreamGenerator,
    required int dataSize,
    BigInt? reward,
  }) =>
      TransactionStream(
        owner: owner,
        tags: tags,
        target: target,
        quantity: quantity,
        dataStreamGenerator: dataStreamGenerator,
        dataSize: dataSize.toString(),
        reward: reward,
      );

  @override
  void setLastTx(String lastTx) => _lastTx = lastTx;

  @override
  void setTarget(String target) => _target = target;

  @override
  void setQuantity(BigInt quantity) => _quantity = quantity;

  @override
  void setOwner(String owner) => _owner = owner;

  @override
  Future<void> setData(Uint8List data) async {
    throw UnimplementedError('Cannot set data on a stream transaction');
  }

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
  void setReward(BigInt reward) => _reward = reward;

  @override
  Future<Uint8List> getSignatureData() async {
    switch (format) {
      case 1:
        return Uint8List.fromList(
          decodeBase64ToBytes(owner!) +
              decodeBase64ToBytes(target) +
              data +
              utf8.encode(quantity.toString()) +
              utf8.encode(reward.toString()) +
              decodeBase64ToBytes(lastTx!) +
              tags
                  .expand((t) =>
                      decodeBase64ToBytes(t.name) +
                      decodeBase64ToBytes(t.value))
                  .toList(),
        );
      case 2:
        return deepHash([
          utf8.encode(format.toString()),
          decodeBase64ToBytes(owner!),
          decodeBase64ToBytes(target),
          utf8.encode(quantity.toString()),
          utf8.encode(reward.toString()),
          decodeBase64ToBytes(lastTx!),
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

  /// Sets the data and data size of this [Transaction].
  ///
  /// Also chunks and validates the incoming data for format 2 transactions.
  Future<void> setStreamGenerator(DataStreamGenerator dataStreamGenerator, int dataSize) async {
    _dataStreamGenerator = dataStreamGenerator;
    _dataSize = dataSize.toString();

    if (format == 2) {
      final existingDataRoot = _dataRoot;
      _chunks = null;

      await prepareChunks();

      if (existingDataRoot != dataRoot) {
        throw StateError(
            'Incoming data does not match data transaction was prepared with.');
      }
    }
  }

  @override
  Future<void> prepareChunks() async {
    if (chunks != null) return;

    final dataStream = dataStreamGenerator();
    _chunks = await generateTransactionChunksFromStream(dataStream);
    _dataRoot = encodeBytesToBase64(chunks!.dataRoot);
  }

  /// Returns a chunk in a format suitable for posting to /chunk.
  @override
  Future<TransactionChunk> getChunk(int index) async {
    if (chunks == null) throw StateError('Chunks have not been prepared.');

    final proof = chunks!.proofs[index];
    final chunk = chunks!.chunks[index];

    final chunkStream = dataStreamGenerator(chunk.minByteRange, chunk.maxByteRange);
    final chunkData = await _bufferStream(chunkStream);

    return TransactionChunk(
      dataRoot: dataRoot,
      dataSize: dataSize,
      dataPath: encodeBytesToBase64(proof.proof),
      offset: proof.offset.toString(),
      chunk: encodeBytesToBase64(chunkData),
    );
  }

    @override
  Future<void> sign(Wallet wallet) async {
    final signatureData = await getSignatureData();
    final rawSignature = await wallet.sign(signatureData);

    _signature = encodeBytesToBase64(rawSignature);

    final idHash = await sha256.hash(rawSignature);
    _id = encodeBytesToBase64(idHash.bytes);
  }

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
        modulus: decodeBase64ToBigInt(owner!),
        publicExponent: publicExponent,
      );
    } catch (_) {
      return false;
    }
  }

  factory TransactionStream.fromJson(Map<String, dynamic> json) =>
      _$TransactionStreamFromJson(json);

  /// Encodes the [Transaction] as JSON with the `data` as the original unencoded [Uint8List].
  @override
  Map<String, dynamic> toJson() => _$TransactionStreamToJson(this);
}
