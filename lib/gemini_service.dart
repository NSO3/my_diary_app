import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      // 実際にはアプリがクラッシュする前に適切なエラー処理を行うべきです
      throw Exception("GEMINI_API_KEYが.envファイルに見つかりません。");
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: apiKey,
    );
  }

  // 日記の内容を受け取ってコメントを生成する関数
  Future<String> generateComment(String diaryTitle, String diaryContent) async {
    final prompt = """
    あなたは親切で温かいジャーナリスト（コメンテーター）です。
    以下の日記の内容を読んで、簡潔で、感情に寄り添う温かいコメントを一つだけ生成してください。
    - 専門的な分析やアドバイスは不要です。
    - コメントは最大50文字程度で、日本語でお願いします。

    ---
    タイトル: $diaryTitle
    内容: $diaryContent
    ---
    あなたのコメント:
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      // 返答の前後にある改行や空白を削除してクリーンなコメントを返す
      return response.text?.trim() ?? "コメント生成に失敗しました。"; 
    } catch (e) {
      print("Gemini API Error: $e");
      return "AIコメントの取得中にエラーが発生しました。";
    }
  }
}