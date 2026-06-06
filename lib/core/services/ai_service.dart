import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

// ── Message de conversation ───────────────────────────────
class ChatMessage {
  final String role;    // 'user' | 'assistant'
  final String content;
  final DateTime time;
  final bool isError;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? time,
    this.isError = false,
  }) : time = time ?? DateTime.now();
}

// ── Service IA Groq ───────────────────────────────────────
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  static const _url = 'https://api.groq.com/openai/v1/chat/completions';

  // ── Rate limiting ─────────────────────────────────────────
  static const _maxMessagesPerSession = 30;
  static const _minSecondsBetweenCalls = 4;

  int _sessionCount = 0;
  DateTime? _lastCallTime;

  bool get _keyConfigured =>
      AppConfig.groqApiKey.isNotEmpty &&
      AppConfig.groqApiKey.startsWith('gsk_');

  static const _systemPrompt = '''
Tu es un assistant spirituel catholique bienveillant intégré dans l'application Refuge.
Ton rôle est d'aider les utilisateurs à découvrir et comprendre la foi catholique, en particulier les personnes n'ayant jamais eu d'éducation religieuse.

Tes règles :
- Réponds toujours en français, avec bienveillance, clarté et pédagogie.
- Adapte ton niveau à celui d'un grand débutant, sauf si l'utilisateur montre qu'il est avancé.
- Explique les termes techniques catholiques simplement quand tu les utilises.
- Sois fidèle à l'enseignement de l'Église catholique romaine.
- Évite les sujets politiques, les polémiques et les controverses internes à l'Église.
- Encourage la prière, la participation à la messe et la rencontre d'une communauté locale.
- Quand tu cites un passage biblique, donne la référence exacte (ex : Jn 3,16).
- Sois concis : 3 à 5 phrases maximum, sauf si l'utilisateur demande plus de détails.
- Si tu ne sais pas quelque chose, dis-le honnêtement plutôt que d'inventer.
- Ne donne jamais de conseils médicaux, juridiques ou financiers.
''';

  // ── Envoi d'un message ────────────────────────────────────
  Future<(String, bool)> sendMessage(List<ChatMessage> history) async {
    if (!_keyConfigured) {
      return ('L\'assistant spirituel n\'est pas encore disponible.', true);
    }

    if (_sessionCount >= _maxMessagesPerSession) {
      return ('Vous avez atteint la limite de messages pour cette session. Relancez l\'application pour continuer.', true);
    }

    if (_lastCallTime != null) {
      final elapsed = DateTime.now().difference(_lastCallTime!).inSeconds;
      if (elapsed < _minSecondsBetweenCalls) {
        final wait = _minSecondsBetweenCalls - elapsed;
        return ('Patientez encore $wait seconde${wait > 1 ? 's' : ''} avant d\'envoyer un nouveau message.', true);
      }
    }

    _lastCallTime = DateTime.now();
    _sessionCount++;

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      ...history.takeLast(10).map((m) => {
        'role': m.role,
        'content': m.content,
      }),
    ];

    try {
      final resp = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer ${AppConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': AppConfig.groqModel,
          'messages': messages,
          'max_tokens': 600,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final text = (data['choices'] as List).first['message']['content'] as String;
        return (text, false);
      }
      if (resp.statusCode == 401) {
        return ('Clé API invalide. Contactez le support.', true);
      }
      if (resp.statusCode == 429) {
        return ('Trop de questions envoyées. Attendez quelques secondes et réessayez.', true);
      }
      return ('Une erreur est survenue. Réessayez dans un moment.', true);
    } on Exception {
      return ('Impossible de contacter l\'assistant. Vérifiez votre connexion internet.', true);
    }
  }

  int get remainingMessages => _maxMessagesPerSession - _sessionCount;
}

extension<T> on List<T> {
  List<T> takeLast(int n) =>
      length <= n ? this : sublist(length - n);
}
