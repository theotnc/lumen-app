'use strict';

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret }       = require('firebase-functions/params');
const admin                  = require('firebase-admin');

admin.initializeApp();

// ─── Secret Manager ───────────────────────────────────────
const groqKey = defineSecret('GROQ_KEY');

// ─── Constantes ───────────────────────────────────────────
const GROQ_URL           = 'https://api.groq.com/openai/v1/chat/completions';
const MODEL              = 'llama-3.1-8b-instant';
const MAX_CALLS_PER_HOUR = 30;
const MAX_HISTORY_LEN    = 10;
const MAX_MSG_LENGTH     = 2000;

const SYSTEM_PROMPT = `Tu es un assistant spirituel catholique bienveillant intégré dans l'application Refuge.
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
- Ne donne jamais de conseils médicaux, juridiques ou financiers.`;

// ─── Callable Function (Gen 2) ────────────────────────────
exports.askAssistant = onCall(
  {
    region:  'europe-west1',
    secrets: [groqKey],
  },
  async (request) => {

    // 1 ── Authentification obligatoire ──────────────────────
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Connexion requise pour utiliser l\'assistant.');
    }
    const uid = request.auth.uid;

    // 2 ── Validation de l'entrée ────────────────────────────
    const history = request.data.history;
    if (!Array.isArray(history) || history.length === 0) {
      throw new HttpsError('invalid-argument', 'Historique invalide.');
    }
    for (const msg of history) {
      if (!msg || typeof msg.role !== 'string' || typeof msg.content !== 'string') {
        throw new HttpsError('invalid-argument', 'Message malformé.');
      }
      if (!['user', 'assistant'].includes(msg.role)) {
        throw new HttpsError('invalid-argument', 'Rôle invalide.');
      }
      if (msg.content.length > MAX_MSG_LENGTH) {
        throw new HttpsError('invalid-argument', 'Message trop long.');
      }
    }

    // 3 ── Rate limiting (30 appels / heure / utilisateur) ───
    const db         = admin.firestore();
    const now        = Date.now();
    const oneHourAgo = now - 3_600_000;
    const rateRef    = db.collection('_rate_limits').doc(uid);

    const limited = await db.runTransaction(async (tx) => {
      const doc    = await tx.get(rateRef);
      const calls  = doc.exists ? (doc.data().calls || []) : [];
      const recent = calls.filter(t => t > oneHourAgo);

      if (recent.length >= MAX_CALLS_PER_HOUR) return true;

      recent.push(now);
      tx.set(rateRef, { calls: recent, uid, updated_at: now });
      return false;
    });

    if (limited) {
      throw new HttpsError(
        'resource-exhausted',
        `Limite de ${MAX_CALLS_PER_HOUR} messages par heure atteinte. Réessayez plus tard.`
      );
    }

    // 4 ── Clé API Groq (Secret Manager) ─────────────────────
    const apiKey = groqKey.value();
    if (!apiKey || !apiKey.startsWith('gsk_')) {
      throw new HttpsError('internal', 'Assistant temporairement indisponible.');
    }

    // 5 ── Appel Groq ─────────────────────────────────────────
    const messages = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...history.slice(-MAX_HISTORY_LEN).map(m => ({
        role:    m.role,
        content: m.content,
      })),
    ];

    let groqResponse;
    try {
      groqResponse = await fetch(GROQ_URL, {
        method:  'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type':  'application/json',
        },
        body: JSON.stringify({
          model:       MODEL,
          messages,
          max_tokens:  600,
          temperature: 0.7,
        }),
        signal: AbortSignal.timeout(30_000),
      });
    } catch (e) {
      throw new HttpsError('internal', 'Impossible de contacter l\'assistant.');
    }

    if (!groqResponse.ok) {
      if (groqResponse.status === 429) {
        throw new HttpsError('resource-exhausted', 'Service temporairement surchargé. Réessayez dans quelques secondes.');
      }
      throw new HttpsError('internal', 'Erreur du service IA.');
    }

    const json = await groqResponse.json();
    const text = json.choices[0].message.content;
    return { text };
  }
);
