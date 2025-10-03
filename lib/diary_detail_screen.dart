// lib/diary_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:my_diary_app/models/diary.dart';
import 'package:my_diary_app/new_diary_screen.dart';
import 'package:my_diary_app/gemini_service.dart'; // ★追加
import 'package:intl/intl.dart'; // 日付整形のために追加

// 削除処理を受け取るためのコールバック関数型を定義
typedef DeleteCallback = void Function(int index);

// StatelessWidgetからStatefulWidgetに変更
class DiaryDetailScreen extends StatefulWidget {
  final Diary diary;
  final int index;
  final DeleteCallback onDelete; 

  const DiaryDetailScreen({
    super.key, 
    required this.diary,
    required this.index,
    required this.onDelete,
  });

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  // AIコメントの状態を管理する変数
  String _geminiComment = 'AIコメントを読み込み中...';
  // Geminiサービスを初期化
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    // 画面がロードされたらすぐにGeminiコメントの生成を開始
    _fetchGeminiComment();
  }

  // Gemini APIを呼び出し、コメントを取得する非同期関数
  Future<void> _fetchGeminiComment() async {
    try {
      final comment = await _geminiService.generateComment(
        widget.diary.title,
        widget.diary.content,
      );
      // 取得後、setStateで画面を更新し、コメントを表示
      setState(() {
        _geminiComment = comment;
      });
    } catch (e) {
      // エラーが発生した場合
      setState(() {
        _geminiComment = 'コメントの取得に失敗しました: $e';
      });
    }
  }

  // 日付を整形するヘルパー関数
  String _formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日 (HH:mm)').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(widget.diary.date)), // 時刻も含む詳細な日付
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NewDiaryScreen(
                    existingDiary: widget.diary, 
                    index: widget.index,         
                  ),
                ),
              ).then((_) {
                // 編集画面から戻ってきたら詳細画面を閉じ、一覧画面へ戻る
                Navigator.of(context).pop();
              });
            },
          ),
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('削除の確認'),
                    content: const Text('この日記を本当に削除しますか？'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('キャンセル'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('削除'),
                        onPressed: () {
                          Navigator.of(context).pop(); 
                          widget.onDelete(widget.index); 
                          Navigator.of(context).pop();  
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AIコメント表示エリア
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Geminiからのコメント',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // コメントがロードされるまでローディング表示
                  _geminiComment == 'AIコメントを読み込み中...'
                      ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_geminiComment),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // 日記のタイトル
            Text(
              widget.diary.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // 日記の本文
            Text(
              widget.diary.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}