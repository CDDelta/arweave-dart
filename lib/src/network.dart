import 'dart:convert';

import 'package:arweave/src/models/models.dart';

import 'api/api.dart';

class ArweaveNetworkApi {
  final ArweaveApi _api;

  ArweaveNetworkApi(ArweaveApi api) : this._api = api;

  Future<NetworkInfo> getInfo() => this._api.get('info').then(
        (res) => NetworkInfo.fromJson(
          json.decode(res.body),
        ),
      );

  Future<List<String>> getPeers() => this
      ._api
      .get('peers')
      .then((res) => (json.decode(res.body) as List<dynamic>).cast<String>());
}
