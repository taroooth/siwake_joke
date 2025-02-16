import 'package:siwake_joke/model/shiwake/account_heading.dart';

class Kashikata implements AccountHeading {
  @override
  final String kamoku;

  @override
  final int amount;

  Kashikata({
    required this.kamoku,
    required this.amount,
  });

  @override
  factory Kashikata.fromJson(Map<String, dynamic> json) {
    return Kashikata(
      kamoku: json['kamoku'] as String,
      amount: json['amount'] as int,
    );
  }
}
