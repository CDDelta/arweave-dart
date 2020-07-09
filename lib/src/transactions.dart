import './api.dart';

class ArweaveTransactions {
  final ArweaveApi _api;

  ArweaveTransactions(ArweaveApi api) : this._api = api;

  Future<String> getTransactionAnchor() =>
      this._api.get('tx_anchor').then((res) => res.body);

  Future<String> getPrice({int byteSize, String targetAddress = null}) {
    final endpoint = targetAddress != null
        ? 'price/$byteSize/$targetAddress'
        : 'price/$byteSize';
    return this._api.get(endpoint).then((res) => res.body);
  }
}
