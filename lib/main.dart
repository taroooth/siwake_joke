import 'package:flutter/material.dart';
import 'package:siwake_joke/domain/usecase/fetch_content_use_case.dart';
import 'package:siwake_joke/infrastructure/repository/content_repository_impl.dart';
import 'package:siwake_joke/model/shiwake/karikata.dart';
import 'package:siwake_joke/model/shiwake/kashikata.dart';
import 'package:siwake_joke/model/shiwake/shiwake.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '仕訳に変換',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final FetchContentUseCase _useCase =
      FetchContentUseCase(ContentRepositoryImpl());
  final _textEditingController = TextEditingController();
  List<Shiwake>? _shiwakeList;
  bool _loading = false;
  String _error = '';
  String _input = '';
  String _prevInput = '';

  void _handleSubmit() async {
    // Commandパターン: ユーザーの操作を命令として実行
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final shiwakeList = await _useCase.call(_input);
      if (shiwakeList.isEmpty) {
        setState(() {
          _error = 'エラー：AIが理解できませんでした';
        });
        return;
      }
      // Observerパターン: 状態変化をsetStateで通知
      setState(() {
        _shiwakeList = shiwakeList;
        _prevInput = _input;
        _input = '';
        _textEditingController.clear();
        _error = '';
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
          karikata: Karikata(kamoku: '（例）幸福感', amount: 300),
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
                            : Column(
                                children: [
                                  Text(_prevInput),
                                  _card(_shiwakeList!),
                                ],
                              ),
                const SizedBox(height: 32),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _textEditingController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      hintText: '（例）朝ごはんが美味しかった',
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
                fontSize: 18,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
