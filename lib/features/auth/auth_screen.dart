import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme.dart';
import 'auth_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _tab = 0;
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  // Connexion
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  // Inscription
  final _nameCtrl      = TextEditingController();
  final _emailSignCtrl = TextEditingController();
  final _passSignCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _nameCtrl.dispose(); _emailSignCtrl.dispose();
    _passSignCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _loginValid =>
      _emailCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty;

  bool get _signupValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailSignCtrl.text.isNotEmpty &&
      _passSignCtrl.text.length >= 6 &&
      _passSignCtrl.text == _confirmCtrl.text;

  bool get _appleAvailable => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  Future<void> _run(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _error = null; });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() => _run(
      () => AuthService().signIn(_emailCtrl.text.trim(), _passCtrl.text));
  Future<void> _signUp() => _run(
      () => AuthService().signUp(
          _emailSignCtrl.text.trim(), _passSignCtrl.text, _nameCtrl.text.trim()));
  Future<void> _google() => _run(() => AuthService().signInWithGoogle());
  Future<void> _apple()  => _run(() => AuthService().signInWithApple());

  Future<void> _forgot() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mot de passe oublié',
            style: TextStyle(color: AppTheme.label)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'Entrez votre email pour recevoir un lien de réinitialisation.',
            style: TextStyle(color: AppTheme.sublabel, fontSize: 14),
          ),
          const SizedBox(height: 16),
          AuthField(
            controller: ctrl,
            hint: 'Email',
            icon: Icons.email_outlined,
            type: TextInputType.emailAddress,
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler', style: TextStyle(color: AppTheme.sublabel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Envoyer',
                style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      try {
        await AuthService().resetPassword(ctrl.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email de réinitialisation envoyé !')));
        }
      } catch (e) {
        if (mounted) setState(() => _error = AuthService.errorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const _BackgroundOrbs(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
              ),
              child: Column(children: [
                const SizedBox(height: 44),
                _buildLogo(),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCard(),
                ),
                const SizedBox(height: 28),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.50),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.22),
                  Colors.black.withValues(alpha: 0.70),
                ],
                stops: const [0.15, 1.0],
              ),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  AppTheme.primary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/logo.webp',
                  width: 54,
                  height: 54,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 22),
      const Text(
        'Lumen',
        style: TextStyle(
          color: Colors.white,
          fontSize: 46,
          fontWeight: FontWeight.w800,
          letterSpacing: -2.5,
          height: 1.0,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'PRIEZ  ·  LISEZ  ·  RASSEMBLEZ-VOUS',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.30),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.8,
        ),
      ),
    ]);
  }

  // ── Carte Liquid Glass ────────────────────────────────────
  // Sur Flutter Web, BackdropFilter wrappant un Container avec gradient
  // rend les enfants invisibles (bug CanvasKit). Fix : kIsWeb saute le blur.
  // Sur mobile : Stack + Positioned.fill pour que le blur soit un calque
  // séparé derrière le contenu.
  Widget _buildCard() {
    final glassDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.06),
        ],
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _buildTabSelector(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _tab == 0 ? _buildLoginForm() : _buildSignupForm(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(children: [
            Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.12))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'ou continuer avec',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.12))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: _buildSocialRow(),
        ),
      ],
    );

    // Flutter interdit borderRadius + Border non-uniforme dans BoxDecoration.
    // Solution : ClipRRect externe arrondit tout (y compris la bordure),
    // Container interne dessine la bordure sans borderRadius.
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          // Pas de borderRadius ici — ClipRRect ci-dessus gère l'arrondi
          border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.42), width: 0.8),
            left: BorderSide(
                color: Colors.white.withValues(alpha: 0.16), width: 0.5),
            right: BorderSide(
                color: Colors.white.withValues(alpha: 0.07), width: 0.5),
            bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05), width: 0.5),
          ),
        ),
        child: kIsWeb
            // Web : pas de BackdropFilter — contenu toujours visible
            ? Container(decoration: glassDecoration, child: content)
            // Mobile : blur sur calque séparé, contenu au-dessus
            : Stack(children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(decoration: glassDecoration),
                  ),
                ),
                content,
              ]),
      ),
    );
  }

  // ── Tab selector — fond opaque simple, pas de blur ────────
  Widget _buildTabSelector() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.5,
        ),
      ),
      child: Row(children: [
        _TabPill(
          label: 'Connexion',
          selected: _tab == 0,
          onTap: () => setState(() { _tab = 0; _error = null; }),
        ),
        _TabPill(
          label: 'Inscription',
          selected: _tab == 1,
          onTap: () => setState(() { _tab = 1; _error = null; }),
        ),
      ]),
    );
  }

  // ── Formulaire connexion ──────────────────────────────────
  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthField(
          controller: _emailCtrl,
          hint: 'Email',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
          action: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AuthField(
          controller: _passCtrl,
          hint: 'Mot de passe',
          icon: Icons.lock_outlined,
          obscure: _obscure,
          action: TextInputAction.done,
          onSubmitted: (_) { if (_loginValid) _signIn(); },
          onChanged: (_) => setState(() {}),
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: Colors.white.withValues(alpha: 0.40),
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgot,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              foregroundColor: AppTheme.primary,
            ),
            child: const Text('Mot de passe oublié ?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ),
        if (_error != null) ...[
          AuthErrorBox(message: _error!),
          const SizedBox(height: 12),
        ],
        _PrimaryBtn(
          label: 'Se connecter',
          loading: _loading,
          enabled: _loginValid && !_loading,
          onTap: _signIn,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── Formulaire inscription ────────────────────────────────
  Widget _buildSignupForm() {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthField(
          controller: _nameCtrl,
          hint: 'Prénom',
          icon: Icons.person_outline,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        AuthField(
          controller: _emailSignCtrl,
          hint: 'Email',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        AuthField(
          controller: _passSignCtrl,
          hint: 'Mot de passe',
          icon: Icons.lock_outlined,
          obscure: _obscure,
          onChanged: (_) => setState(() {}),
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: Colors.white.withValues(alpha: 0.40),
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 10),
        AuthField(
          controller: _confirmCtrl,
          hint: 'Confirmer le mot de passe',
          icon: Icons.lock_outlined,
          obscure: _obscure,
          action: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) { if (_signupValid) _signUp(); },
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          AuthErrorBox(message: _error!),
        ],
        const SizedBox(height: 16),
        _PrimaryBtn(
          label: 'Créer mon compte',
          loading: _loading,
          enabled: _signupValid && !_loading,
          onTap: _signUp,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── Boutons sociaux — pas de BackdropFilter imbriqué ──────
  Widget _buildSocialRow() {
    return Row(children: [
      Expanded(
        child: _SocialBtn(
          onTap: _loading ? null : _google,
          label: 'Google',
          icon: const Text(
            'G',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _SocialBtn(
          onTap: (_loading || !_appleAvailable) ? null : _apple,
          label: 'Apple',
          dimmed: !_appleAvailable,
          icon: Icon(
            Icons.apple,
            size: 22,
            color: _appleAvailable
                ? Colors.white
                : Colors.white.withValues(alpha: 0.30),
          ),
        ),
      ),
    ]);
  }
}

// ── Tab pill ──────────────────────────────────────────────
class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: double.infinity,
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                )
              : const BoxDecoration(),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppTheme.label
                    : Colors.white.withValues(alpha: 0.40),
                letterSpacing: -0.2,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bouton principal doré ─────────────────────────────────
class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;
  const _PrimaryBtn({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primary
              : AppTheme.primary.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.40),
                    blurRadius: 22,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Color(0xFF1C1C1E), strokeWidth: 2.0),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Bouton social — fond solide, pas de BackdropFilter ────
class _SocialBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final Widget icon;
  final bool dimmed;
  const _SocialBtn({
    required this.onTap,
    required this.label,
    required this.icon,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: active ? 0.12 : 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: active ? 0.22 : 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: dimmed ? 0.25 : 0.80),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Orbes dorés de fond ───────────────────────────────────
class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Stack(children: [
      Positioned(
        top: -90,
        right: -70,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTheme.primary.withValues(alpha: 0.32),
              AppTheme.primary.withValues(alpha: 0.10),
              Colors.transparent,
            ], stops: const [0.0, 0.45, 1.0]),
          ),
        ),
      ),
      Positioned(
        top: h * 0.35,
        left: -90,
        child: Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTheme.primaryDark.withValues(alpha: 0.28),
              Colors.transparent,
            ]),
          ),
        ),
      ),
      Positioned(
        bottom: -30,
        right: w * 0.08,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTheme.primary.withValues(alpha: 0.14),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ]);
  }
}
