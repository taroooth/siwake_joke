import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:siwake_joke/model/shiwake/karikata.dart';
import 'package:siwake_joke/model/shiwake/kashikata.dart';
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
      debugShowCheckedModeBanner: false,
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
  final ContentController _controller = ContentController();
  List<Shiwake>? _shiwakeList;
  bool _loading = false;
  String _error = '';
  String _input = '';

  void _handleSubmit() async {
    // Commandパターン: ユーザーの操作を命令として実行
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final shiwakeList = await _controller.fetchContent(_input);
      // Observerパターン: 状態変化をsetStateで通知
      setState(() {
        _shiwakeList = shiwakeList;
      });
    } catch (e) {
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
    final sampleCard = _card(
      [
        Shiwake(
          karikata: Karikata(kamoku: '幸福感', amount: 300),
          kashikata: Kashikata(kamoku: '朝ごはん', amount: 300),
        ),
      ],
    );
    final buttonIsEnabled = !_loading && _input.isNotEmpty;
    // Observerパターン: 状態変化によりUIを更新
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF27BA74),
        elevation: 10,
        title: const Text(
          'あなたの出来事を仕訳に変換',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 32,
            ),
            child: Column(
              children: [
                _loading
                    ? const CircularProgressIndicator()
                    : _error.isNotEmpty
                        ? Text(_error)
                        : _shiwakeList == null
                            ? sampleCard
                            : _card(_shiwakeList!),
                const SizedBox(height: 32),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    maxLength: 30,
                    decoration: const InputDecoration(
                      hintText: '例：朝ごはんが美味しかった',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _input = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: buttonIsEnabled ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60),
                  ),
                  child: const Text(
                    '送信',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(List<Shiwake> list) {
    if (list.isEmpty) {
      return const Text('データがありません');
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: list.map((shiwake) {
            final karikata = shiwake.karikata;
            final kashikata = shiwake.kashikata;
            return Text(
              '${karikata.kamoku} ${karikata.amount} / ${kashikata.kamoku} ${kashikata.amount}',
              style: const TextStyle(
                fontSize: 20,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
