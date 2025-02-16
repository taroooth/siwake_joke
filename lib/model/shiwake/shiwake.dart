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
      karikata: Karikata.fromJson(json['karikata'] as Map<String, dynamic>),
      kashikata: Kashikata.fromJson(json['kashikata'] as Map<String, dynamic>),
    );
  }
}
