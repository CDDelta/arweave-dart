import 'package:http/http.dart' as http;

class ArweaveApi {
  http.Client _client;

  String _host;
  String _protocol;
  int _port;

  ArweaveApi({
    String host,
    String protocol,
    int port,
  })  : _host = host,
        _protocol = protocol,
        _port = protocol == "https" ? 443 : 80,
        _client = http.Client();

  Future<http.Response> get(String endpoint) =>
      this._client.get(_getEndpointUrl(endpoint));

  Future<http.Response> post(String endpoint, {dynamic body}) =>
      this._client.post(_getEndpointUrl(endpoint), body: body);

  String _getEndpointUrl(String endpoint) =>
      '${_protocol}://${_host}:${_port}/$endpoint';
}
