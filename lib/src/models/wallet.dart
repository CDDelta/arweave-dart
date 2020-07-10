class Wallet {
  String get owner => null;
  String get address => null;

  factory Wallet.fromJwk(Map<String, dynamic> jwk) {
    throw UnimplementedError();
  }
  Map<String, dynamic> toJwk() {
    throw UnimplementedError();
  }
}
