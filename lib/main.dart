import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';

// Strategyパターン: API通信処理の抽象インターフェース
abstract class ContentRepository {
  Future<String> generateContent(String input);
}

// Singletonパターン: ContentRepositoryの実装をシングルトン化
class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl._internal();

  static final ContentRepositoryImpl _instance =
      ContentRepositoryImpl._internal();

  factory ContentRepositoryImpl() => _instance; // Factoryパターン

  @override
  Future<String> generateContent(String input) async {
    const apiKey = String.fromEnvironment('API_KEY');
    return 'APIキー: $apiKey, ${apiKey.isEmpty}';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
    // Adapterパターン: ユーザー入力をAPIのリクエスト形式に変換
    final requestData = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': input}
          ]
        }
      ]
    });
    try {
      final response = await HttpRequest.request(
        url,
        method: 'POST',
        sendData: requestData,
        requestHeaders: {'Content-Type': 'application/json'},
      );
      if (response.status == 200) {
        final jsonResponse = jsonDecode(response.responseText!);
        return jsonResponse['candidates'][0]['content']['parts'][0]['text']
            as String;
      } else {
        throw Exception('APIエラー: ${response.status}');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      if (e is ProgressEvent) {
        throw Exception('ネットワークエラー: CORS設定やオリジンの許可を確認してください ($e)');
      }
      throw Exception('ネットワークエラー: $e');
    }
  }
}

// MVCパターン: ビジネスロジックを管理するControllerクラス
class ContentController {
  final ContentRepository repository = ContentRepositoryImpl();

  // Commandパターン: API通信命令の実行
  Future<String> fetchContent(String input) {
    return repository.generateContent(input);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // MVCパターン: アプリ全体のView（Controllerと連携）
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web API Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  // MVCパターン: View部分を担当
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _textController = TextEditingController();
  final ContentController _controller = ContentController();
  String _result = '';
  bool _loading = false;
  String _error = '';

  void _handleSubmit() async {
    // Commandパターン: ユーザーの操作を命令として実行
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      String content = await _controller.fetchContent(_textController.text);
      // Observerパターン: 状態変化をsetStateで通知
      setState(() {
        _result = content;
      });
    } catch (e) {
      print('エラーが発生しました: $e');
      setState(() {
        _error = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observerパターン: 状態変化によりUIを更新
    return Scaffold(
      appBar: AppBar(
        title: const Text('API通信デモ'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _loading
                  ? const CircularProgressIndicator()
                  : _error.isNotEmpty
                  ? Text(_error)
                  : Text(
                _result,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: '自由入力してください',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                child: const Text('送信'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
