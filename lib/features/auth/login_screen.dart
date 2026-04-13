import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    } catch (e) {
      setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().signInWithGoogle();
    } catch (e) {
      setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().signInWithApple();
    } catch (e) {
      setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mot de passe oublié'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Envoyer')),
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

  bool get _showAppleButton =>
      !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    return Column(
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
          controller: _passwordCtrl,
          hint: 'Mot de passe',
          icon: Icons.lock_outlined,
          obscure: _obscure,
          action: TextInputAction.done,
          onSubmitted: (_) => _signIn(),
          onChanged: (_) => setState(() {}),
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),

        // Mot de passe oublié
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              foregroundColor: AppTheme.primary,
            ),
            child: const Text('Mot de passe oublié ?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 4),
          AuthErrorBox(message: _error!),
        ],
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: (_loading || _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty)
              ? null : _signIn,
          child: _loading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(color: Color(0xFF1C1C1E), strokeWidth: 2))
              : const Text('Se connecter'),
        ),

        // Séparateur social
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('ou continuer avec',
                  style: const TextStyle(
                      color: AppTheme.sublabel, fontSize: 13)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),

        // Google
        _SocialButton(
          onPressed: _loading ? null : _signInWithGoogle,
          label: 'Google',
          icon: _googleIcon(),
        ),

        // Apple (iOS / macOS uniquement)
        if (_showAppleButton) ...[
          const SizedBox(height: 12),
          _SocialButton(
            onPressed: _loading ? null : _signInWithApple,
            label: 'Apple',
            icon: const Icon(Icons.apple, size: 20),
            dark: true,
          ),
        ],
      ],
    );
  }

  Widget _googleIcon() {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4285F4),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;
  final bool dark;

  const _SocialButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: dark ? Colors.black : Colors.white,
          foregroundColor: dark ? Colors.white : AppTheme.label,
          side: BorderSide(
            color: dark ? Colors.black : AppTheme.separator,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              'Continuer avec $label',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: dark ? Colors.white : AppTheme.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
