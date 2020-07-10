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

    final walletJwk = walletA.toJwk();
    expect(walletJwk['kty'], equals('RSA'));
    expect(walletJwk['e'], equals('AQAB'));

    expect(walletJwk['n'], matches(r'/^[a-z0-9-_]{683}$/i'));
    expect(walletJwk['d'], matches(r'/^[a-z0-9-_]{683}$/i'));

    expect(walletA.address, matches(digestRegex));
    expect(walletB.address, matches(digestRegex));

    expect(walletA.address, isNot(equals(walletB.address)));
  });

  test('get wallet info', () async {
    expect(await client.wallets.getBalance(liveAddress),
        equals(liveAddressBalance));
    expect(await client.wallets.getLastTransactionId(liveAddress),
        equals(liveTxid));

    final newWallet = await client.wallets.generate();
    final newWalletAddress = newWallet.address;

    expect(await client.wallets.getBalance(newWalletAddress), equals('0'));
    expect(await client.wallets.getLastTransactionId(newWalletAddress),
        equals(''));
  });

  test('resolve address from wallet', () async {
    final wallet = Wallet.fromJwk(json
        .decode(await new File('test/fixtures/test-key.json').readAsString()));

    expect(
        wallet.address, equals('fOVzBRTBnyt4VrUUYadBH8yras_-jhgpmNgg-5b3vEw'));
  });

  test('resolve address from owner', () async {
    final jwk = json
        .decode(await new File('test/fixtures/test-key.json').readAsString());

    final address = client.wallets.ownerToAddress(jwk['n']);

    expect(address, equals('fOVzBRTBnyt4VrUUYadBH8yras_-jhgpmNgg-5b3vEw'));
  });
}
