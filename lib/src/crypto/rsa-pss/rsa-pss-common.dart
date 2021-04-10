import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart';

import '../../utils.dart';

Future<Uint8List> rsaPssSign(
    {required Uint8List message, required RsaKeyPair keyPair}) async {
  final pk = await keyPair.extract();

  final pcPk = RSAPrivateKey(
    decodeBytesToBigInt(pk.n),
    decodeBytesToBigInt(pk.d),
    decodeBytesToBigInt(pk.p),
    decodeBytesToBigInt(pk.q),
  );

  final signer = PSSSigner(RSAEngine(), SHA256Digest(), SHA256Digest())
    ..init(
      true,
      ParametersWithSalt(
        PrivateKeyParameter<RSAPrivateKey>(pcPk),
        Uint8List(0),
      ),
    );
  return signer.generateSignature(message).bytes;
}

Future<bool> rsaPssVerify({
  required Uint8List input,
  required Uint8List signature,
  required BigInt modulus,
  required BigInt publicExponent,
}) async {
  var signer = PSSSigner(RSAEngine(), SHA256Digest(), SHA256Digest())
    ..init(
      false,
      ParametersWithSalt(
        PublicKeyParameter<RSAPublicKey>(
          RSAPublicKey(
            modulus,
            publicExponent,
          ),
        ),
        Uint8List(0),
      ),
    );

  return signer.verifySignature(input, PSSSignature(signature));
}
