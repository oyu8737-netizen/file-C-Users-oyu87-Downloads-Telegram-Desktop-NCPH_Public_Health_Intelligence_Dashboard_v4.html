import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/cloud_service.dart';
import '../state/settings_state.dart';

/// Нэвтрэх / Бүртгүүлэх. "Account-гүй үргэлжлүүлэх" сонголттой.
class AuthScreen extends StatefulWidget {
  final CloudService cloud;

  const AuthScreen({super.key, required this.cloud});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = SettingsScope.strings(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_signUp) {
        await widget.cloud.signUp(_email.text, _password.text, _name.text);
      } else {
        await widget.cloud.signIn(_email.text, _password.text);
      }
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code, s);
    } catch (e) {
      _error = s.networkError;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _forgot() async {
    final s = SettingsScope.strings(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_email.text.contains('@')) {
      setState(() => _error = s.enterEmailFirst);
      return;
    }
    try {
      await widget.cloud.resetPassword(_email.text);
      messenger.showSnackBar(SnackBar(content: Text(s.resetSent)));
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authError(e.code, s));
    }
  }

  static String _authError(String code, S s) => switch (code) {
        'invalid-email' => s.errInvalidEmail,
        'email-already-in-use' => s.errEmailInUse,
        'weak-password' => s.errWeakPassword,
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          s.errWrongLogin,
        'too-many-requests' => s.errTooMany,
        'network-request-failed' => s.networkError,
        _ => '${s.errGeneric} ($code)',
      };

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final s = SettingsScope.strings(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            settings.setMongolian(!settings.mongolian),
                        child: Text(settings.mongolian ? 'English' : 'Монгол'),
                      ),
                    ),
                    const Text('🏠', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 64)),
                    Text('Tiny Room',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium),
                    Text(s.tagline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: false, label: Text(s.signIn)),
                        ButtonSegment(value: true, label: Text(s.signUp)),
                      ],
                      selected: {_signUp},
                      onSelectionChanged: (v) => setState(() {
                        _signUp = v.first;
                        _error = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (_signUp) ...[
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                            labelText: s.nameLabel,
                            border: const OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.errRequired
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                          labelText: s.emailLabel,
                          border: const OutlineInputBorder()),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? s.errInvalidEmail
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: s.passwordLabel,
                          helperText: _signUp ? s.passwordHint : null,
                          border: const OutlineInputBorder()),
                      validator: (v) =>
                          (v == null || v.length < 6) ? s.errWeakPassword : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_signUp ? s.signUp : s.signIn),
                    ),
                    if (!_signUp)
                      TextButton(
                          onPressed: _forgot, child: Text(s.forgotPassword)),
                    const Divider(height: 32),
                    OutlinedButton(
                      onPressed: () => settings.setAuthSkipped(true),
                      child: Text(s.continueWithout),
                    ),
                    const SizedBox(height: 4),
                    Text(s.continueWithoutHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
