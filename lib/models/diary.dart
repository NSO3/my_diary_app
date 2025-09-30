class Diary {
  final String title;
  final String content;
  final DateTime date;

  Diary({
    required this.title,
    required this.content,
    required this.date,
  });

  // JSONからDiaryオブジェクトを作成するファクトリコンストラクタ
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
    );
  }

  // DiaryオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }
}