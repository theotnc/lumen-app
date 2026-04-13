import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/community_service.dart';
import '../../core/theme.dart';

class NewPrayerScreen extends StatefulWidget {
  const NewPrayerScreen({super.key});

  @override
  State<NewPrayerScreen> createState() => _NewPrayerScreenState();
}

class _NewPrayerScreenState extends State<NewPrayerScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  bool get _valid => _ctrl.text.trim().length >= 10;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await CommunityService().submitPrayer(_ctrl.text);
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
            // AppBar
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
                        child: Text('Partager une prière',
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
                              : const Text('Envoyer',
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
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.20),
                            width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🙏', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Partagez une intention de prière avec la communauté. Les autres membres pourront prier avec vous.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Champ texte
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                            width: 0.5),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        maxLines: 8,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          color: AppTheme.label,
                          fontSize: 15,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Seigneur, je vous confie...\n\nÉcrivez votre intention de prière',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 15,
                            height: 1.6,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      '${_ctrl.text.trim().length} caractères (min. 10)',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.30)),
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
