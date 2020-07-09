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

  test('get wallet balance', () async {
    final balance = await client.wallets.getBalance(liveAddress);
    expect(balance, equals(liveAddressBalance));
  });

  test('get wallet last transaction id', () async {
    final lastTxId = await client.wallets.getLastTransactionId(liveAddress);
    expect(lastTxId, equals(liveTxid));
  });

  test('generate wallet', () async {
    final wallet = await client.wallets.generate();

    expect(wallet['kty'], equals('RSA'));
    expect(wallet['e'], equals('AQAB'));
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
