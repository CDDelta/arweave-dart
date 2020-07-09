import 'package:http/http.dart' as http;

import './models/models.dart';

class ArweaveApi {
  final ApiConfig config;

  http.Client _client;

  ArweaveApi({this.config}) {
    this._client = http.Client();
  }

  Future<http.Response> get(String endpoint) =>
      this._client.get(_getEndpointUrl(endpoint));

  Future<http.Response> post(String endpoint, {dynamic body}) =>
      this._client.post(_getEndpointUrl(endpoint), body: body);

  String _getEndpointUrl(String endpoint) =>
      '${config.protocol}://${config.host}:${config.port}/$endpoint';
}
