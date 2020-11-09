import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../utils.dart';
import 'rsa-pss-common.dart' as common;

final rsaPss = RsaPss(sha256, nonceLength: 0);

Future<Uint8List> rsaPssSign({Uint8List message, KeyPair keyPair}) async {
  try {
    final signature = await rsaPss.sign(message, keyPair);
    return signature.bytes;
  } catch (err) {
    if (err is UnimplementedError) {
      return common.rsaPssSign(message: message, keyPair: keyPair);
    } else {
      rethrow;
    }
  }
}

Future<bool> rsaPssVerify({
  Uint8List input,
  Uint8List signature,
  BigInt modulus,
  BigInt publicExponent,
}) async {
  try {
    final valid = await rsaPss.verify(
      input,
      Signature(
        signature,
        publicKey: RsaJwkPublicKey(
          n: encodeBigIntToBytes(modulus),
          e: encodeBigIntToBytes(publicExponent),
        ),
      ),
    );

    return valid;
  } catch (err) {
    if (err is UnimplementedError) {
      return common.rsaPssVerify(
        input: input,
        signature: signature,
        modulus: modulus,
        publicExponent: publicExponent,
      );
    } else {
      rethrow;
    }
  }
}
