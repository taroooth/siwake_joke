import 'package:siwake_joke/model/shiwake/karikata.dart';
import 'package:siwake_joke/model/shiwake/kashikata.dart';

class Shiwake {
  final Karikata karikata;
  final Kashikata kashikata;

  Shiwake({
    required this.karikata,
    required this.kashikata,
  });

  factory Shiwake.fromJson(Map<String, dynamic> json) {
    return Shiwake(
      karikata: Karikata(
        kamoku: json['karikata']['kamoku'] as String,
        amount: json['karikata']['amount'] as int,
      ),
      kashikata: Kashikata(
        kamoku: json['kashikata']['kamoku'] as String,
        amount: json['kashikata']['amount'] as int,
      ),
    );
  }
}
