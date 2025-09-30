import 'package:flutter/material.dart';
import 'package:my_diary_app/models/diary.dart';
import 'package:my_diary_app/new_diary_screen.dart';

// 削除処理を受け取るためのコールバック関数型を定義
typedef DeleteCallback = void Function(int index);

class DiaryDetailScreen extends StatelessWidget {
  // 表示する日記データを受け取るためのプロパティ
  final Diary diary;
  // リストの何番目の日記かを識別するためのインデックス
  final int index; 
  // --- 削除関数を受け取るプロパティを追加 ---
  final DeleteCallback onDelete; 

  const DiaryDetailScreen({
    super.key, 
    required this.diary,
    required this.index,
    required this.onDelete, 
  });

  @override
  Widget build(BuildContext context) {
    // 日付を「YYYY年MM月DD日」形式に整形するヘルパー関数
    String formatDate(DateTime date) {
      return '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(formatDate(diary.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NewDiaryScreen(
                    existingDiary: diary, // 既存の日記データを渡す
                    index: index,         // 編集対象のインデックスを渡す
                  ),
                ),
              ).then((_) {
                // 編集画面から戻ってきたときに、詳細画面を閉じ、一覧画面を再読み込みする
                Navigator.of(context).pop();
              });
            },
          ),
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 削除確認のダイアログを表示
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
                          Navigator.of(context).pop(); // ダイアログを閉じる
                          onDelete(index);            // 渡された削除関数を実行
                          Navigator.of(context).pop();  // 詳細画面を閉じて一覧に戻る
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
            // タイトル
            Text(
              diary.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // 本文
            Text(
              diary.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}