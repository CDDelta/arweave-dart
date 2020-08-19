import 'dart:math';

import 'api.dart';
import 'id.dart';
import 'models/models.dart';
import 'network.dart';
import 'transactions.dart';
import 'wallets.dart';

class Arweave {
  ArweaveApi get api => _api;
  ArweaveApi _api;

  ArweaveWalletsApi get wallets => _wallets;
  ArweaveWalletsApi _wallets;

  ArweaveTransactionsApi get transactions => _transactions;
  ArweaveTransactionsApi _transactions;

  ArweaveIdApi get id => _id;
  ArweaveIdApi _id;

  ArweaveNetworkApi get network => _network;
  ArweaveNetworkApi _network;

  Arweave({
    String host,
    String protocol,
    int port,
  }) {
    this._api = ArweaveApi(host: host, protocol: protocol, port: port);
    this._wallets = ArweaveWalletsApi(api);
    this._transactions = ArweaveTransactionsApi(api);
    this._id = ArweaveIdApi(transactions);
    this._network = ArweaveNetworkApi(api);
  }

  Future<Transaction> createTransaction(
    Transaction transaction,
    Wallet wallet,
  ) async {
    assert(transaction.data != null ||
        (transaction.target != null && transaction.quantity != null));

    if (transaction.owner == null) transaction.setOwner(wallet.owner);

    if (transaction.lastTx == null)
      transaction.setLastTx(await transactions.getTransactionAnchor());

    if (transaction.reward == BigInt.zero && transaction.data.isNotEmpty)
      transaction.setReward(await transactions.getPrice(
        byteSize: int.parse(transaction.dataSize),
        targetAddress: transaction.target,
      ));

    return transaction;
  }

  Future<List<String>> arql(Map<String, dynamic> query) =>
      transactions.arql(query);

  double arToWinston(double ar) => ar * pow(10.0, 12);
}
