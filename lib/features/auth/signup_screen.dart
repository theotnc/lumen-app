import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import 'auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _passwordCtrl.text.length >= 6 &&
      _passwordCtrl.text == _confirmCtrl.text;

  Future<void> _signUp() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().signUp(
        _emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim());
    } catch (e) {
      setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
            controller: _emailCtrl,
            hint: 'Email',
            icon: Icons.email_outlined,
            type: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          AuthField(
            controller: _passwordCtrl,
            hint: 'Mot de passe',
            icon: Icons.lock_outlined,
            obscure: _obscure,
            onChanged: (_) => setState(() {}),
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
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
            onSubmitted: (_) => _valid ? _signUp() : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AuthErrorBox(message: _error!),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (_loading || !_valid) ? null : _signUp,
            child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Color(0xFF1C1C1E), strokeWidth: 2))
                : const Text('Créer mon compte'),
          ),
        ],
      ),
    );
  }
}
