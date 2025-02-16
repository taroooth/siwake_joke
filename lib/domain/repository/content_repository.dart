// Strategyパターン: API通信処理の抽象インターフェース
import 'package:siwake_joke/model/shiwake/shiwake.dart';

abstract class ContentRepository {
  Future<List<Shiwake>> generateContent(String input);
}
