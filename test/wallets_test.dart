import 'dart:convert';
import 'dart:io';

import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

const liveAddressBalance = "498557055636";
const liveAddress = "9_666Wkk2GzL0LGd3xhb0jY7HqNy71BaV4sULQlJsBQ";
const liveTxid = "CE-1SFiXqWUEu0aSTebE6LC0-5JBAc3IAehYGwdF5iI";

void main() {
  Arweave client;

  setUp(() {
    client = getArweaveClient();
  });

  test('generate wallet', () async {
    final walletA = await client.wallets.generate();
    final walletB = await client.wallets.generate();

    expect(walletA['kty'], equals('RSA'));
    expect(walletA['e'], equals('AQAB'));

    expect(walletA['n'], matches(r'/^[a-z0-9-_]{683}$/i'));
    expect(walletA['d'], matches(r'/^[a-z0-9-_]{683}$/i'));

    final addressA = client.wallets.jwkToAddress(walletA);
    final addressB = client.wallets.jwkToAddress(walletB);

    expect(addressA, matches(digestRegex));
    expect(addressB, matches(digestRegex));

    expect(addressA, isNot(equals(addressB)));
  });

  test('get wallet info', () async {
    final newWallet = await client.wallets.generate();
    final newWalletAddress = await client.wallets.jwkToAddress(newWallet);

    expect(await client.wallets.getBalance(newWalletAddress), equals('0'));
    expect(await client.wallets.getLastTransactionId(newWalletAddress),
        equals(''));

    expect(await client.wallets.getBalance(liveAddress),
        equals(liveAddressBalance));
    expect(await client.wallets.getLastTransactionId(liveAddress),
        equals(liveTxid));
  });

  test('resolve address from jwk', () async {
    final jwk = json
        .decode(await new File('test/fixtures/test-key.json').readAsString());

    final address = client.wallets.ownerToAddress(jwk);

    expect(address, equals('fOVzBRTBnyt4VrUUYadBH8yras_-jhgpmNgg-5b3vEw'));
  });

  test('resolve address from owner', () async {
    final jwk = json
        .decode(await new File('test/fixtures/test-key.json').readAsString());

    final address = client.wallets.ownerToAddress(jwk['n']);

    expect(address, equals('fOVzBRTBnyt4VrUUYadBH8yras_-jhgpmNgg-5b3vEw'));
  });
}
