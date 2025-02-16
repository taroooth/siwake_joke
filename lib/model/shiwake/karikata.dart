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
}
