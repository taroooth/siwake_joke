interface class AccountHeading {
  final String kamoku;
  final int amount;

  AccountHeading({
    required this.kamoku,
    required this.amount,
  });

  factory AccountHeading.fromJson(Map<String, dynamic> json) {
    return AccountHeading(
      kamoku: json['kamoku'] as String,
      amount: json['amount'] as int,
    );
  }
}
