import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/community_service.dart';
import '../../core/theme.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  bool _loading = false;

  bool get _valid =>
      _titleCtrl.text.trim().length >= 5 &&
      _bodyCtrl.text.trim().length >= 10;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await CommunityService().submitPost(_titleCtrl.text, _bodyCtrl.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

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
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.30),
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.07),
                          width: 0.5),
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
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: AppTheme.label),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text('Nouvelle discussion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.label,
                              letterSpacing: -0.3,
                            )),
                      ),
                      GestureDetector(
                        onTap: _valid ? _submit : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _valid
                                ? AppTheme.primary
                                : AppTheme.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF1C1C1E), strokeWidth: 2))
                              : const Text('Publier',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1C1C1E),
                                  )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 24, 20,
                    MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    _FieldLabel(label: 'Titre'),
                    const SizedBox(height: 8),
                    _InputBox(
                      controller: _titleCtrl,
                      hint: 'Un titre pour votre message…',
                      maxLines: 2,
                      onChanged: (_) => setState(() {}),
                      autofocus: true,
                    ),

                    const SizedBox(height: 20),

                    // Corps
                    _FieldLabel(label: 'Votre message'),
                    const SizedBox(height: 8),
                    _InputBox(
                      controller: _bodyCtrl,
                      hint: 'Partagez votre réflexion, témoignage ou question…',
                      maxLines: 7,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.35),
          letterSpacing: 1.0,
        ),
      );
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  const _InputBox({
    required this.controller,
    required this.hint,
    required this.maxLines,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.10), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        autofocus: autofocus,
        onChanged: onChanged,
        style: const TextStyle(
            color: AppTheme.label, fontSize: 14, height: 1.55),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
