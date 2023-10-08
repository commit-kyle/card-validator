class CreditCard {
  String number;
  String cvv;
  String country;
  String issuer;

  CreditCard({
    required this.number,
    required this.cvv,
    required this.country,
    required this.issuer,
  });

  Map<String, String> toJson() {
    return {
      'number': number,
      'cvv': cvv,
      'country': country,
      'issuer': issuer,
    };
  }

  static CreditCard fromJson(Map<String, dynamic> json) {
    return CreditCard(
      number: json['number'],
      cvv: json['cvv'], 
      country: json['country'], 
      issuer: json['issuer']
    );
  }
}