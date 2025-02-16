import 'dart:convert';

import 'package:siwake_joke/domain/repository/content_repository.dart';
import 'package:siwake_joke/model/shiwake/shiwake.dart';
import 'package:http/http.dart' as http;

// Singletonパターン: ContentRepositoryの実装をシングルトン化
class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl._internal();

  static final ContentRepositoryImpl _instance =
  ContentRepositoryImpl._internal();

  factory ContentRepositoryImpl() => _instance; // Factoryパターン

  @override
  Future<List<Shiwake>> generateContent(String input) async {
    final url = Uri.parse(
      'https://us-central1-shiwake-joke.cloudfunctions.net/generateContent/',
    );

    final body = jsonEncode({'input': input});

    final httpResponse = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (httpResponse.statusCode == 200) {
      // レスポンス全体がList型の場合の処理
      final responseList = jsonDecode(httpResponse.body) as List;
      return responseList
          .map((json) => Shiwake.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('API呼び出しエラー: ${httpResponse.statusCode}');
    }
  }
}
