import 'package:flutter/material.dart';
import 'package:my_diary_app/new_diary_screen.dart';
import 'package:my_diary_app/diary_detail_screen.dart';
import 'package:my_diary_app/models/diary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'dart:convert';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyDiaryHomePage(),
    );
  }
}

// 日記一覧画面を StatefulWidget に変更
class MyDiaryHomePage extends StatefulWidget {
  const MyDiaryHomePage({super.key});

  @override
  State<MyDiaryHomePage> createState() => _MyDiaryHomePageState();
}

class _MyDiaryHomePageState extends State<MyDiaryHomePage> {
  List<Diary> _diaries = [];

  @override
  void initState() {
    super.initState();
    _loadDiaries(); // 画面が初期化されたときに日記を読み込む
  }

  // SharedPreferencesから日記を読み込む関数
  Future<void> _loadDiaries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? diariesJson = prefs.getString('diaries');

    if (diariesJson != null) {
      final List<dynamic> decodedList = jsonDecode(diariesJson);
      setState(() {
        _diaries = decodedList.map((item) => Diary.fromJson(item)).toList();
      });
    }
  }

  // --- ここに削除関数を追加 ---
  Future<void> _deleteDiary(int index) async {
    if (index < 0 || index >= _diaries.length) return;

    // リストから日記を削除
    _diaries.removeAt(index);

    // SharedPreferencesに保存
    final prefs = await SharedPreferences.getInstance();
    final String updatedDiariesJson = jsonEncode(_diaries.map((e) => e.toJson()).toList());
    await prefs.setString('diaries', updatedDiariesJson);

    // 画面を更新
    setState(() {});
  }
  // --- 削除関数はここまで ---

  // 日記作成画面から戻ってきたときに日記を再読み込みする
  void _navigateAndReload() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewDiaryScreen(),
      ),
    );
    _loadDiaries(); // 画面が戻ってきたら日記を再読み込み
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日記一覧'),
      ),
      body: _diaries.isEmpty
          ? const Center(child: Text('ここに日記の一覧が表示されます'))
          : ListView.builder(
              itemCount: _diaries.length,
              itemBuilder: (context, index) {
                final diary = _diaries[index];
                // ★整形用のフォーマッタを定義★
                final dateFormatter = DateFormat('yyyy年MM月dd日');
                final formattedDate = dateFormatter.format(diary.date);                
                return ListTile(
                  title: Text(diary.title),
                  subtitle: Text(formattedDate),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DiaryDetailScreen(
                          diary: diary, // タップされた日記データを渡す
                          index: index, // タップされたインデックスを渡す
                          onDelete: _deleteDiary, 
                        ),
                      ),
                    ).then((_) {
                       _loadDiaries(); // リストを強制的に再読み込みする
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndReload, // 関数呼び出し
        child: const Icon(Icons.add),
      ),
    );
  }
}