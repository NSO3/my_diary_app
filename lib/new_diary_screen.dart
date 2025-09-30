import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_diary_app/models/diary.dart';
import 'dart:convert';

class NewDiaryScreen extends StatefulWidget {
  // 編集対象の日記データ (新規作成の場合は null)
  final Diary? existingDiary;
  // 編集対象の日記のインデックス (新規作成の場合は null)
  final int? index;

  const NewDiaryScreen({
    super.key,
    this.existingDiary, // オプションとして受け取る
    this.index, // オプションとして受け取る
  });

  @override
  State<NewDiaryScreen> createState() => _NewDiaryScreenState();
}

class _NewDiaryScreenState extends State<NewDiaryScreen> {
  // late を使って、initState で初期化することを明示
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // 既存の日記があれば、その内容でコントローラーを初期化
    _titleController = TextEditingController(
      text: widget.existingDiary?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingDiary?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    // 既存の日記なら日付をそのまま使い、新規なら現在時刻を使う
    final newDiary = Diary(
      title: title,
      content: content,
      date: widget.existingDiary?.date ?? DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final String? diariesJson = prefs.getString('diaries');
    List<Diary> diaries = [];

    if (diariesJson != null) {
      final List<dynamic> decodedList = jsonDecode(diariesJson);
      diaries = decodedList.map((item) => Diary.fromJson(item)).toList();
    }

    // 既存の日記を編集する場合
    if (widget.index != null && widget.index! < diaries.length) {
      // 指定されたインデックスの要素を新しい日記で上書きする
      diaries[widget.index!] = newDiary;
    } else {
      // 新規作成の場合
      diaries.add(newDiary);
    }

    final String updatedDiariesJson = jsonEncode(diaries.map((e) => e.toJson()).toList());

    await prefs.setString('diaries', updatedDiariesJson);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面タイトルを、編集モードか新規モードかで切り替える
    final screenTitle = widget.existingDiary == null ? '新しい日記' : '日記の編集';

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
      ),
      body: Padding(
        // ... (body の中身は既存のコードとほぼ同じ) ...
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タイトル入力欄
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // 本文入力欄
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '日記の本文',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDiary,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}