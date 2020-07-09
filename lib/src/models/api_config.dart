class ApiConfig {
  String host;
  String protocol;
  int port;
  int timeout;

  ApiConfig({
    this.host = '127.0.0.1',
    this.protocol = 'http',
    this.port,
    this.timeout = 20000,
  }) {
    this.port = protocol == "https" ? 443 : 80;
  }
}
