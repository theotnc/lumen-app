import 'package:cloud_firestore/cloud_firestore.dart';

// ── Prière partagée ───────────────────────────────────────
class CommunityPrayer {
  final String id;
  final String text;
  final String authorName;
  final String authorUid;
  final DateTime createdAt;
  final int prayerCount;
  final bool hasPrayed; // calculé côté client

  const CommunityPrayer({
    required this.id,
    required this.text,
    required this.authorName,
    required this.authorUid,
    required this.createdAt,
    required this.prayerCount,
    this.hasPrayed = false,
  });

  factory CommunityPrayer.fromDoc(DocumentSnapshot doc, {bool hasPrayed = false}) {
    final d = doc.data() as Map<String, dynamic>;
    return CommunityPrayer(
      id:          doc.id,
      text:        d['text']        as String? ?? '',
      authorName:  d['author_name'] as String? ?? 'Anonyme',
      authorUid:   d['author_uid']  as String? ?? '',
      createdAt:   (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      prayerCount: d['prayer_count'] as int? ?? 0,
      hasPrayed:   hasPrayed,
    );
  }

  CommunityPrayer copyWith({int? prayerCount, bool? hasPrayed}) => CommunityPrayer(
    id:          id,
    text:        text,
    authorName:  authorName,
    authorUid:   authorUid,
    createdAt:   createdAt,
    prayerCount: prayerCount ?? this.prayerCount,
    hasPrayed:   hasPrayed  ?? this.hasPrayed,
  );
}

// ── Sujet de forum ────────────────────────────────────────
class ForumPost {
  final String id;
  final String title;
  final String body;
  final String authorName;
  final String authorUid;
  final DateTime createdAt;
  final int replyCount;

  const ForumPost({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.authorUid,
    required this.createdAt,
    required this.replyCount,
  });

  factory ForumPost.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id:         doc.id,
      title:      d['title']       as String? ?? '',
      body:       d['body']        as String? ?? '',
      authorName: d['author_name'] as String? ?? 'Anonyme',
      authorUid:  d['author_uid']  as String? ?? '',
      createdAt:  (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replyCount: d['reply_count'] as int? ?? 0,
    );
  }
}

// ── Réponse de forum ──────────────────────────────────────
class ForumReply {
  final String id;
  final String body;
  final String authorName;
  final String authorUid;
  final DateTime createdAt;

  const ForumReply({
    required this.id,
    required this.body,
    required this.authorName,
    required this.authorUid,
    required this.createdAt,
  });

  factory ForumReply.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ForumReply(
      id:         doc.id,
      body:       d['body']        as String? ?? '',
      authorName: d['author_name'] as String? ?? 'Anonyme',
      authorUid:  d['author_uid']  as String? ?? '',
      createdAt:  (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── Utilitaire temps ──────────────────────────────────────
String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1)  return 'À l\'instant';
  if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
  if (diff.inHours < 24)   return 'Il y a ${diff.inHours}h';
  if (diff.inDays < 7)     return 'Il y a ${diff.inDays}j';
  final months = ['jan','fév','mar','avr','mai','juin','jul','aoû','sep','oct','nov','déc'];
  return '${dt.day} ${months[dt.month - 1]}';
}
