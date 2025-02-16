import 'package:siwake_joke/domain/repository/content_repository.dart';
import 'package:siwake_joke/model/shiwake/shiwake.dart';

// Clean Architecture: ビジネスロジックを管理するUseCaseクラス
class FetchContentUseCase {
  final ContentRepository repository;

  // DIによりテスト容易性と疎結合を実現
  FetchContentUseCase(this.repository);

  Future<List<Shiwake>> call(String input) async {
    return repository.generateContent(input);
  }
}
