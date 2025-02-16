import 'package:siwake_joke/model/shiwake/account_heading.dart';

class Karikata implements AccountHeading {
  @override
  final String kamoku;

  @override
  final int amount;

  Karikata({
    required this.kamoku,
    required this.amount,
  });

  @override
  factory Karikata.fromJson(Map<String, dynamic> json) {
    return Karikata(
      kamoku: json['kamoku'] as String,
      amount: json['amount'] as int,
    );
  }
}
