import 'dart:convert';
import 'dart:io';

import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

const liveAddressBalance = '498557055636';
const liveAddress = '9_666Wkk2GzL0LGd3xhb0jY7HqNy71BaV4sULQlJsBQ';
const liveTxid = 'CE-1SFiXqWUEu0aSTebE6LC0-5JBAc3IAehYGwdF5iI';

void main() {
  final client = Arweave();

  group('wallets:', () {
    test('decode and encode wallet', () async {
      final jwk =
          json.decode(await File('test/fixtures/test-key.json').readAsString());
      expect(Wallet.fromJwk(jwk).toJwk(), equals(jwk));
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    final jwkFieldPattern = RegExp(r'^[a-z0-9-_]{683}$', caseSensitive: false);
    test('generate wallet', () async {
      final walletA = await client.wallets.generate();
      final walletB = await client.wallets.generate();

      final walletJwk = walletA.toJwk();
      expect(walletJwk['kty'], equals('RSA'));
      expect(walletJwk['e'], equals('AQAB'));

      expect(walletJwk['n'], matches(jwkFieldPattern));
      expect(walletJwk['d'], matches(jwkFieldPattern));

      expect(walletA.address, matches(digestPattern));
      expect(walletB.address, matches(digestPattern));

      expect(walletA.address, isNot(equals(walletB.address)));
    });

    test('get wallet info', () async {
      expect(await client.wallets.getBalance(liveAddress),
          equals(liveAddressBalance));
      expect(await client.wallets.getLastTransactionId(liveAddress),
          equals(liveTxid));

      final fakeWallet = await getTestWallet();

      expect(await client.wallets.getBalance(fakeWallet.address), equals('0'));
      expect(await client.wallets.getLastTransactionId(fakeWallet.address),
          equals(''));
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });

    test('resolve address from wallet', () async {
      final wallet = await getTestWallet();
      expect(wallet.address,
          equals('fOVzBRTBnyt4VrUUYadBH8yras_-jhgpmNgg-5b3vEw'));
    }, onPlatform: {
      'browser': Skip('dart:io unavailable'),
    });
  });
}
