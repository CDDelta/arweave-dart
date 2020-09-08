import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class TransactionChunksWithProofs {
  final Uint8List dataRoot;
  final List<Chunk> chunks;
  final List<Proof> proofs;

  TransactionChunksWithProofs(this.dataRoot, this.chunks, this.proofs);
}

class Chunk {
  final Uint8List dataHash;
  final int minByteRange;
  final int maxByteRange;

  Chunk(this.dataHash, this.minByteRange, this.maxByteRange);
}

abstract class MerkleNode {
  final List<int> id;
  final int maxByteRange;

  MerkleNode(this.id, this.maxByteRange);
}

class BranchNode extends MerkleNode {
  final int byteRange;
  final MerkleNode leftChild;
  final MerkleNode rightChild;

  BranchNode(
      {List<int> id,
      this.byteRange,
      int maxByteRange,
      this.leftChild,
      this.rightChild})
      : super(id, maxByteRange);
}

class LeafNode extends MerkleNode {
  final List<int> dataHash;
  final int minByteRange;

  LeafNode({List<int> id, this.dataHash, this.minByteRange, int maxByteRange})
      : super(id, maxByteRange);
}

const MAX_CHUNK_SIZE = 256 * 1024;
const MIN_CHUNK_SIZE = 32 * 1024;
const _NOTE_SIZE = 32;

/// Builds an Arweave Merkle tree and returns the root hash for the given input.
Future<Uint8List> computeRootHash(Uint8List data) async {
  final rootNode = await generateTree(data);
  return rootNode.id;
}

Future<MerkleNode> generateTree(Uint8List data) async {
  final chunks = await _chunkData(data);
  final leaves = await _generateLeaves(chunks);
  return _buildLayers(leaves);
}

/// Generates the data root, chunks & proofs needed for a transaction.
///
/// This also checks if the last chunk is a zero-length
/// chunk and discards that chunk and proof if so.
/// (we do not need to upload this zero length chunk)
Future<TransactionChunksWithProofs> generateTransactionChunks(
    Uint8List data) async {
  final chunks = await _chunkData(data);
  final leaves = await _generateLeaves(chunks);
  final root = await _buildLayers(leaves);
  final proofs = await _generateProofs(root);

  // Discard the last chunk & proof if it's zero length.
  if (chunks.last.maxByteRange - chunks.last.minByteRange == 0) {
    chunks.removeLast();
    proofs.removeLast();
  }

  return TransactionChunksWithProofs(root.id, chunks, proofs);
}

/// Takes the input data and chunks it into (mostly) equal sized chunks.
/// The last chunk will be a bit smaller as it contains the remainder
/// from the chunking process.
Future<List<Chunk>> _chunkData(Uint8List data) async {
  final chunks = <Chunk>[];

  var rest = data;
  var cursor = 0;

  while (rest.lengthInBytes >= MAX_CHUNK_SIZE) {
    var chunkSize = MAX_CHUNK_SIZE;

    // If the total bytes left will produce a chunk < MIN_CHUNK_SIZE,
    // then adjust the amount we put in this 2nd last chunk.
    var nextChunkSize = rest.lengthInBytes - MAX_CHUNK_SIZE;
    if (nextChunkSize > 0 && nextChunkSize < MIN_CHUNK_SIZE)
      chunkSize = (rest.lengthInBytes / 2).ceil();

    final chunk = Uint8List.sublistView(rest, 0, chunkSize);
    final dataHash = sha256.convert(chunk).bytes;
    cursor += chunk.lengthInBytes;
    chunks.add(Chunk(dataHash, cursor - chunk.lengthInBytes, cursor));
    rest = Uint8List.sublistView(rest, chunkSize);
  }

  chunks.add(
      Chunk(sha256.convert(rest).bytes, cursor, cursor + rest.lengthInBytes));

  return chunks;
}

Future<List<LeafNode>> _generateLeaves(List<Chunk> chunks) async => chunks
    .map(
      (c) => LeafNode(
        id: sha256
            .convert(sha256.convert(c.dataHash).bytes +
                sha256.convert(_intToBuffer(c.maxByteRange)).bytes)
            .bytes,
        dataHash: c.dataHash,
        minByteRange: c.minByteRange,
        maxByteRange: c.maxByteRange,
      ),
    )
    .toList();

/// Starting with the bottom layer of leaf nodes, hash every second pair
/// into a new branch node, push those branch nodes onto a new layer,
/// and then recurse, building up the tree to it's root, where the
/// layer only consists of two items.
Future<MerkleNode> _buildLayers(List<MerkleNode> nodes, [int level = 0]) async {
  // If there are only 2 nodes left, this is going to be the root node
  if (nodes.length < 2) {
    final root =
        await _hashBranch(nodes[0], nodes.length == 2 ? nodes[1] : null);
    return root;
  }

  final nextLayer = <MerkleNode>[];

  for (var i = 0; i < nodes.length; i += 2)
    nextLayer.add(await _hashBranch(
        nodes[i], i + 1 < nodes.length ? nodes[i + 1] : null));

  return _buildLayers(nextLayer, level + 1);
}

Future<MerkleNode> _hashBranch(MerkleNode left, MerkleNode right) async {
  if (right == null) return left;

  return BranchNode(
    id: sha256
        .convert(sha256.convert(left.id).bytes +
            sha256.convert(right.id).bytes +
            sha256.convert(_intToBuffer(left.maxByteRange)).bytes)
        .bytes,
    byteRange: left.maxByteRange,
    maxByteRange: right.maxByteRange,
    leftChild: left,
    rightChild: right,
  );
}

class Proof {
  final int offset;
  final Uint8List proof;

  Proof(this.offset, this.proof);
}

/// Recursively search through all branches of the tree,
/// and generate a proof for each leaf node.
List<Proof> _generateProofs(MerkleNode root) {
  List<Object> proofs = _resolveBranchProofs(root);

  flatten(Iterable iter) => iter.fold([], (List xs, s) {
        s is Iterable ? xs.addAll(flatten(s)) : xs.add(s);
        return xs;
      });

  // Flatten the Merkle proofs.
  return flatten(proofs).cast<Proof>().toList();
}

List<Object> _resolveBranchProofs(MerkleNode node,
    [List<int> proof, depth = 0]) {
  proof = proof ?? <int>[];

  if (node is LeafNode)
    return [
      Proof(
        node.maxByteRange - 1,
        Uint8List.fromList(
            proof + node.dataHash + _intToBuffer(node.maxByteRange)),
      )
    ];
  else if (node is BranchNode) {
    final partialProof = proof +
        node.leftChild.id +
        node.rightChild.id +
        _intToBuffer(node.byteRange);
    return [
      _resolveBranchProofs(node.leftChild, partialProof, depth + 1),
      _resolveBranchProofs(node.rightChild, partialProof, depth + 1),
    ];
  }

  throw ArgumentError('Unexpected node type');
}

Uint8List _intToBuffer(int note) {
  final buffer = Uint8List(_NOTE_SIZE);

  for (var i = buffer.length - 1; i >= 0; i--) {
    var byte = note % 256;
    buffer[i] = byte;
    note = (note - byte) ~/ 256;
  }

  return buffer;
}
