import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service/turnstile_service.dart';
import '../../controller/admin_auth_controller.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  // Le widget managed reste monté tant que l'écran existe : pas de
  // création/destruction à chaque tentative (source du "Cannot find Widget").
  TurnstileController? _turnstileController;
  String? _captchaToken;
  String? _captchaError;

  @override
  void initState() {
    super.initState();
    if (TurnstileService.isConfigured) {
      _turnstileController = TurnstileController();
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _turnstileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(adminAuthControllerProvider);

    ref.listen<AdminAuthState>(adminAuthControllerProvider, (prev, next) {
      if (next is AdminAuthSuccess) {
        context.go('/admin');
      }
      if (next is AdminAuthError) {
        // Un login raté a pu consommer le token : on force une nouvelle
        // vérification avant la prochaine tentative.
        _turnstileController?.refreshToken();
        setState(() => _captchaToken = null);
      }
    });

    final isLoading = authState is AdminAuthLoading;
    final captchaRequired = TurnstileService.isConfigured;
    final canSubmit = !isLoading && (!captchaRequired || _captchaToken != null);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Espace admin',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connecte-toi pour modifier tes tarifs et services.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Email invalide'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? '6 caractères minimum'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (captchaRequired) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: CloudflareTurnstile(
                            siteKey: TurnstileService.siteKey!,
                            baseUrl: Uri.base.origin,
                            controller: _turnstileController,
                            options: TurnstileOptions(
                              theme: TurnstileTheme.auto,
                              size: TurnstileSize.normal,
                              retryAutomatically: true,
                            ),
                            onTokenReceived: (token) {
                              setState(() {
                                _captchaToken = token;
                                _captchaError = null;
                              });
                            },
                            onTokenExpired: () {
                              setState(() => _captchaToken = null);
                            },
                            onError: (error) {
                              setState(() {
                                _captchaToken = null;
                                _captchaError =
                                    'Vérification anti-robot indisponible ($error)';
                              });
                            },
                          ),
                        ),
                        if (_captchaError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _captchaError!,
                            style: TextStyle(
                                color: theme.colorScheme.error, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                      if (authState is AdminAuthError) ...[
                        const SizedBox(height: 12),
                        Text(
                          authState.message,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: canSubmit ? _submit : null,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Se connecter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(adminAuthControllerProvider.notifier).signIn(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          captchaToken: _captchaToken,
        );
  }
}
