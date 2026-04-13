import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _pwCtrl      = TextEditingController();
  final _newPwCtrl   = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loadingName  = false;
  bool _loadingEmail = false;
  bool _loadingPw    = false;
  bool _showPw       = false;
  bool _showNewPw    = false;

  String? _nameError;
  String? _emailError;
  String? _pwError;
  String? _nameSuccess;
  String? _emailSuccess;
  String? _pwSuccess;

  final _user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: _user.displayName ?? '');
    _emailCtrl = TextEditingController(text: _user.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Changer le pseudo ─────────────────────────────────
  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Le pseudo ne peut pas être vide.');
      return;
    }
    setState(() { _loadingName = true; _nameError = null; _nameSuccess = null; });
    try {
      await _user.updateDisplayName(name);
      if (mounted) setState(() { _loadingName = false; _nameSuccess = 'Pseudo mis à jour !'; });
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() { _loadingName = false; _nameError = _authMsg(e.code); });
    }
  }

  // ── Changer l'email ───────────────────────────────────
  Future<void> _saveEmail() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _emailError = 'Adresse e-mail invalide.');
      return;
    }
    if (email == _user.email) {
      setState(() => _emailError = 'C\'est déjà votre adresse actuelle.');
      return;
    }
    setState(() { _loadingEmail = true; _emailError = null; _emailSuccess = null; });
    try {
      await _user.verifyBeforeUpdateEmail(email);
      if (mounted) {
        setState(() {
          _loadingEmail = false;
          _emailSuccess = 'Un lien de vérification a été envoyé à $email. Confirmez-le pour finaliser le changement.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() { _loadingEmail = false; _emailError = _authMsg(e.code); });
    }
  }

  // ── Changer le mot de passe ───────────────────────────
  Future<void> _savePassword() async {
    final current = _pwCtrl.text;
    final next    = _newPwCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() => _pwError = 'Veuillez remplir tous les champs.');
      return;
    }
    if (next.length < 6) {
      setState(() => _pwError = 'Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    if (next != confirm) {
      setState(() => _pwError = 'Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() { _loadingPw = true; _pwError = null; _pwSuccess = null; });
    try {
      final cred = EmailAuthProvider.credential(
        email: _user.email!,
        password: current,
      );
      await _user.reauthenticateWithCredential(cred);
      await _user.updatePassword(next);
      if (mounted) {
        _pwCtrl.clear(); _newPwCtrl.clear(); _confirmCtrl.clear();
        setState(() { _loadingPw = false; _pwSuccess = 'Mot de passe modifié avec succès.'; });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() { _loadingPw = false; _pwError = _authMsg(e.code); });
    }
  }

  String _authMsg(String code) {
    switch (code) {
      case 'wrong-password':        return 'Mot de passe actuel incorrect.';
      case 'email-already-in-use':  return 'Cet e-mail est déjà utilisé par un autre compte.';
      case 'invalid-email':         return 'Adresse e-mail invalide.';
      case 'requires-recent-login': return 'Reconnectez-vous d\'abord pour effectuer ce changement.';
      case 'too-many-requests':     return 'Trop de tentatives. Réessayez plus tard.';
      default:                      return 'Une erreur est survenue. Réessayez.';
    }
  }

  Widget _initialsWidget() {
    final initial = (_nameCtrl.text.isNotEmpty
            ? _nameCtrl.text[0]
            : _user.email?[0] ?? '?')
        .toUpperCase();
    return Center(
      child: Text(initial,
          style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 32,
              fontWeight: FontWeight.w800)),
    );
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
            colors: [Color(0xFF1A1000), Color(0xFF000000)],
            stops: [0.0, 0.35],
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
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Modifier le profil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.label,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar (initiales) ───────────────
                    Center(
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B4400), AppTheme.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _initialsWidget(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Pseudo ───────────────────────────
                    _SectionTitle(label: 'Pseudo'),
                    const SizedBox(height: 8),
                    _EditField(
                      controller: _nameCtrl,
                      hint: 'Votre prénom ou pseudo',
                      icon: Icons.person_outline_rounded,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_nameError != null)
                      _StatusLine(text: _nameError!, isError: true),
                    if (_nameSuccess != null)
                      _StatusLine(text: _nameSuccess!, isError: false),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Enregistrer le pseudo',
                      loading: _loadingName,
                      onTap: _saveName,
                    ),

                    const SizedBox(height: 28),

                    // ── Email ────────────────────────────
                    _SectionTitle(label: 'Adresse e-mail'),
                    const SizedBox(height: 8),
                    _EditField(
                      controller: _emailCtrl,
                      hint: 'votre@email.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_emailError != null)
                      _StatusLine(text: _emailError!, isError: true),
                    if (_emailSuccess != null)
                      _StatusLine(text: _emailSuccess!, isError: false),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Changer l\'e-mail',
                      loading: _loadingEmail,
                      onTap: _saveEmail,
                    ),

                    const SizedBox(height: 28),

                    // ── Mot de passe ─────────────────────
                    _SectionTitle(label: 'Mot de passe'),
                    const SizedBox(height: 8),
                    _EditField(
                      controller: _pwCtrl,
                      hint: 'Mot de passe actuel',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_showPw,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _showPw = !_showPw),
                        child: Icon(
                          _showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _EditField(
                      controller: _newPwCtrl,
                      hint: 'Nouveau mot de passe',
                      icon: Icons.lock_outline_rounded,
                      obscure: !_showNewPw,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _showNewPw = !_showNewPw),
                        child: Icon(
                          _showNewPw ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _EditField(
                      controller: _confirmCtrl,
                      hint: 'Confirmer le nouveau mot de passe',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    if (_pwError != null)
                      _StatusLine(text: _pwError!, isError: true),
                    if (_pwSuccess != null)
                      _StatusLine(text: _pwSuccess!, isError: false),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Changer le mot de passe',
                      loading: _loadingPw,
                      onTap: _savePassword,
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

// ── Sous-widgets ──────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

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

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const _EditField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffix,
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
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.label, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
          prefixIcon: Icon(icon, size: 18,
              color: Colors.white.withValues(alpha: 0.35)),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final String text;
  final bool isError;
  const _StatusLine({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFFF6B6B) : AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            size: 14, color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: color, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.30), width: 0.8),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: AppTheme.primary, strokeWidth: 2))
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
        ),
      ),
    );
  }
}
