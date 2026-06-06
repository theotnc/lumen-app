/// Clés API de l'application.
class AppConfig {
  // Clé Groq — commence par "gsk_"
  // Clé à remplacer — ne jamais committer la vraie clé dans git
  static const groqApiKey = 'REMPLACER_PAR_CLE_GROQ';

  // Modèle utilisé — rapide, gratuit, bon français
  static const groqModel = 'llama-3.1-8b-instant';
}
