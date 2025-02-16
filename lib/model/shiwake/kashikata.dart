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
}
