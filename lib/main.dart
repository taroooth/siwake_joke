import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:siwake_joke/model/shiwake/shiwake.dart';

// Strategyパターン: API通信処理の抽象インターフェース
abstract class ContentRepository {
  Future<List<Shiwake>> generateContent(String input);
}

// Singletonパターン: ContentRepositoryの実装をシングルトン化
class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl._internal();

  static final ContentRepositoryImpl _instance =
      ContentRepositoryImpl._internal();

  factory ContentRepositoryImpl() => _instance; // Factoryパターン

  @override
  Future<List<Shiwake>> generateContent(String input) async {
    const apiKey = String.fromEnvironment('API_KEY');
    final schema = Schema.array(
      description: '面白い仕訳',
      items: Schema.object(
        properties: {
          'karikata': Schema.object(
            description: '借方',
            nullable: false,
            properties: {
              'kamoku': Schema.string(
                description: '科目',
                nullable: false,
              ),
              'amount': Schema.integer(
                description: '金額',
                nullable: false,
              ),
            },
            requiredProperties: [
              'kamoku',
              'amount',
            ],
          ),
          'kashikata': Schema.object(
            description: '貸方',
            nullable: false,
            properties: {
              'kamoku': Schema.string(
                description: '科目',
                nullable: false,
              ),
              'amount': Schema.integer(
                description: '金額',
                nullable: false,
              ),
            },
            requiredProperties: [
              'kamoku',
              'amount',
            ],
          ),
        },
        requiredProperties: [
          'karikata',
          'kashikata',
        ],
      ),
    );

    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite-preview-02-05',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final prompt = '''
    以下の例を参考にして、面白い仕訳を生成してください。
    入力例①：ベットに向かう途中でチョコレートを口に入れた矢先にくしゃみが出て、寝具が汚れました😭
    出力例①：
      [
        {
          'karikata': {
            'kamoku': 'チョコ発射損',
            'amount': 200,
          },
          'kashikata': {
            'kamoku': 'チョコ',
            'amount': 200,
          }
        },
        {
          'karikata': {
            'kamoku': '寝具評価損',
            'amount': 200,
          },
          'kashikata': {
            'kamoku': '寝具',
            'amount': 200,
          }
        },
      ]
    入力例②：奥様が昨日から泊まりで福岡に行っていたからやったー自由な時間ができた！って仕事してました…
    出力例②：
      [
        {
          'karikata': {
            'kamoku': '時間',
            'amount': 500,
          },
          'kashikata': {
            'kamoku': '自由時間発生益',
            'amount': 500,
          }
        },
        {
          'karikata': {
            'kamoku': '未成業務支出金',
            'amount': 500,
          },
          'kashikata': {
            'kamoku': '時間',
            'amount': 500,
          }
        },
      ]
    入力例③：豚骨ラーメン食べた
    出力例③：
      [
        {
          'karikata': {
            'kamoku': '脂肪',
            'amount': 500,
          },
          'kashikata': {
            'kamoku': '豚骨ラーメン',
            'amount': 500,
          }
        },
      ]
    
    今回の入力は以下です。
    $input
    ''';
    final response = await model.generateContent([Content.text(prompt)]);
    final responseString = response.text ?? '[]';
    final responseJson = jsonDecode(responseString) as List;
    return responseJson
        .map((json) => Shiwake.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

// MVCパターン: ビジネスロジックを管理するControllerクラス
class ContentController {
  final ContentRepository repository = ContentRepositoryImpl();

  // Commandパターン: API通信命令の実行
  Future<List<Shiwake>> fetchContent(String input) {
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
      final shiwakeList = await _controller.fetchContent(_textController.text);
      // Observerパターン: 状態変化をsetStateで通知
      setState(() {
        _result = shiwakeList
            .map((shiwake) =>
                '借方: ${shiwake.karikata.kamoku} ${shiwake.karikata.amount}円\n貸方: ${shiwake.kashikata.kamoku} ${shiwake.kashikata.amount}円\n')
            .join('\n');
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
