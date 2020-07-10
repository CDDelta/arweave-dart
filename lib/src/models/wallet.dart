class Wallet {
  String get owner => null;
  String get address => null;

  factory Wallet.fromJwk(Map<String, dynamic> jwk) {}
  Map<String, dynamic> toJwk() {}
}
