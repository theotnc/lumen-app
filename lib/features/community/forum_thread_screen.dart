import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/community_models.dart';
import '../../core/services/community_service.dart';
import '../../core/theme.dart';

class ForumThreadScreen extends StatefulWidget {
  final ForumPost post;
  const ForumThreadScreen({super.key, required this.post});

  @override
  State<ForumThreadScreen> createState() => _ForumThreadScreenState();
}

class _ForumThreadScreenState extends State<ForumThreadScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reply() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    _ctrl.clear();
    await CommunityService().submitReply(widget.post.id, text);
    if (mounted) {
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0A00), Color(0xFF000000)],
            stops: [0.0, 0.4],
          ),
        ),
        child: Column(
          children: [
            // AppBar
            _buildAppBar(context),

            // Messages
            Expanded(
              child: StreamBuilder<List<ForumReply>>(
                stream: CommunityService().repliesStream(widget.post.id),
                builder: (context, snap) {
                  final replies = snap.data ?? [];
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: replies.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) return _OriginalPost(post: widget.post);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ReplyBubble(reply: replies[i - 1]),
                      );
                    },
                  );
                },
              ),
            ),

            // Saisie réponse
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 10, 16, keyboard > 0 ? 10 : bottom + 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.07),
                      width: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                            width: 0.5),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _reply(),
                        style: const TextStyle(
                            color: AppTheme.label, fontSize: 14, height: 1.4),
                        decoration: InputDecoration(
                          hintText: 'Votre réponse…',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.28),
                              fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _reply,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _loading
                            ? AppTheme.primary.withValues(alpha: 0.30)
                            : AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    color: Color(0xFF1C1C1E), strokeWidth: 2))
                            : const Icon(Icons.arrow_upward_rounded,
                                color: Color(0xFF1C1C1E), size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 20, 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.30),
            border: Border(
              bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.07), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: AppTheme.label),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.label,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Post original ─────────────────────────────────────────
class _OriginalPost extends StatelessWidget {
  final ForumPost post;
  const _OriginalPost({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.20), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: post.authorName, size: 30),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppTheme.label)),
                  Text(timeAgo(post.createdAt),
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.35))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.body,
            style: TextStyle(
              fontSize: 14, height: 1.6,
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bulle réponse ─────────────────────────────────────────
class _ReplyBubble extends StatelessWidget {
  final ForumReply reply;
  const _ReplyBubble({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(name: reply.authorName, size: 28),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(reply.authorName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppTheme.label)),
                  const SizedBox(width: 8),
                  Text(timeAgo(reply.createdAt),
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.30))),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5),
                ),
                child: Text(
                  reply.body,
                  style: TextStyle(
                    fontSize: 14, height: 1.5,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Avatar initiale ───────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  const _Avatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B4400), AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(initial,
            style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E))),
      ),
    );
  }
}
