import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_models.dart';

class CommunityService {
  static final CommunityService _i = CommunityService._();
  factory CommunityService() => _i;
  CommunityService._();

  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid  => _auth.currentUser?.uid;
  String  get _name => _auth.currentUser?.displayName
      ?? _auth.currentUser?.email?.split('@').first
      ?? 'Anonyme';

  // ── Prières ───────────────────────────────────────────────

  Stream<List<CommunityPrayer>> prayersStream() {
    return _db
        .collection('community_prayers')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snap) async {
      final uid = _uid;
      final prayers = <CommunityPrayer>[];
      for (final doc in snap.docs) {
        bool hasPrayed = false;
        if (uid != null) {
          final sub = await doc.reference
              .collection('prayed_by')
              .doc(uid)
              .get();
          hasPrayed = sub.exists;
        }
        prayers.add(CommunityPrayer.fromDoc(doc, hasPrayed: hasPrayed));
      }
      return prayers;
    });
  }

  Future<void> submitPrayer(String text) async {
    if (_uid == null) return;
    await _db.collection('community_prayers').add({
      'text':         text.trim(),
      'author_name':  _name,
      'author_uid':   _uid,
      'created_at':   FieldValue.serverTimestamp(),
      'prayer_count': 0,
    });
  }

  Future<bool> togglePrayer(String prayerId) async {
    final uid = _uid;
    if (uid == null) return false;

    final ref    = _db.collection('community_prayers').doc(prayerId);
    final subRef = ref.collection('prayed_by').doc(uid);
    final sub    = await subRef.get();

    if (sub.exists) return false; // déjà prié

    await Future.wait([
      subRef.set({'prayed_at': FieldValue.serverTimestamp()}),
      ref.update({'prayer_count': FieldValue.increment(1)}),
    ]);
    return true;
  }

  // ── Forum ─────────────────────────────────────────────────

  Stream<List<ForumPost>> postsStream() {
    return _db
        .collection('forum_posts')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(ForumPost.fromDoc).toList());
  }

  Future<void> submitPost(String title, String body) async {
    if (_uid == null) return;
    await _db.collection('forum_posts').add({
      'title':       title.trim(),
      'body':        body.trim(),
      'author_name': _name,
      'author_uid':  _uid,
      'created_at':  FieldValue.serverTimestamp(),
      'reply_count': 0,
    });
  }

  Stream<List<ForumReply>> repliesStream(String postId) {
    return _db
        .collection('forum_posts')
        .doc(postId)
        .collection('replies')
        .orderBy('created_at')
        .snapshots()
        .map((s) => s.docs.map(ForumReply.fromDoc).toList());
  }

  Future<void> submitReply(String postId, String body) async {
    if (_uid == null) return;
    final postRef = _db.collection('forum_posts').doc(postId);
    await Future.wait([
      postRef.collection('replies').add({
        'body':        body.trim(),
        'author_name': _name,
        'author_uid':  _uid,
        'created_at':  FieldValue.serverTimestamp(),
      }),
      postRef.update({'reply_count': FieldValue.increment(1)}),
    ]);
  }
}
