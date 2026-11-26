import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _signup = false;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final state = context.read<AppState>();
    try {
      if (_signup) {
        await state.signup(
            _name.text.trim(), _email.text.trim(), _password.text);
      } else {
        await state.login(_email.text.trim(), _password.text);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _field(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  String? _emailRule(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email';
    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor:
                        dark ? Colors.white12 : const Color(0xFFEFEFEF),
                    child: Icon(Icons.recycling,
                        size: 42,
                        color: dark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text('EcoSort',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Sort right. Recycle more.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 32),
                  if (_signup) ...[
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: _field('Name', Icons.person_outline),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _field('Email', Icons.alternate_email),
                    validator: _emailRule,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    textInputAction:
                        _signup ? TextInputAction.next : TextInputAction.done,
                    decoration: _field('Password', Icons.lock_outline),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  if (_signup) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _field('Confirm password', Icons.lock_outline),
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_signup ? 'CREATE ACCOUNT' : 'LOGIN',
                              style: const TextStyle(letterSpacing: 1.2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_signup ? 'Already have an account?' : 'New here?',
                          style: const TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => setState(() => _signup = !_signup),
                        child: Text(_signup ? 'Log in' : 'Create account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
