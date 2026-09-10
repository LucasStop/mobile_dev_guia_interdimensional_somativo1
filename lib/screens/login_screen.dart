import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';

/// Porta de entrada do app (RF07): sem sessão aberta, o catálogo não aparece.
///
/// Autenticação real via Supabase Auth — três estados possíveis: formulário
/// de entrar, formulário de cadastrar, ou aviso de "verifique seu e-mail"
/// depois de um cadastro (a confirmação é obrigatória, então o cadastro nunca
/// abre sessão na hora).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (_isSignUp) {
      await auth.signUp(
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
    } else {
      await auth.signIn(_emailController.text, _passwordController.text);
    }
    // Login bem-sucedido troca de tela sozinho: o gate em main.dart observa
    // o AuthProvider. Cadastro que exige confirmação fica na mesma tela, só
    // muda pro aviso de e-mail — ver build() abaixo.
  }

  void _toggleMode() {
    setState(() => _isSignUp = !_isSignUp);
    context.read<AuthProvider>().dismissEmailConfirmationNotice();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.awaitingEmailConfirmation) {
      return _EmailConfirmationNotice(
        email: _emailController.text.trim(),
        onBackToLogin: () {
          setState(() => _isSignUp = false);
          auth.dismissEmailConfirmationNotice();
        },
      );
    }

    return _AuthForm(
      isSignUp: _isSignUp,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      isSubmitting: auth.isSubmitting,
      errorMessage: auth.errorMessage,
      onSubmit: _submit,
      onToggleMode: _toggleMode,
    );
  }
}

class _AuthForm extends StatelessWidget {
  final bool isSignUp;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  const _AuthForm({
    required this.isSignUp,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Guia Interdimensional',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSignUp
                        ? 'Crie sua conta para explorar o catálogo de personagens.'
                        : 'Entre para explorar o catálogo de personagens.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'E-mail *',
                      helperText: 'Campo obrigatório',
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    textInputAction:
                        isSignUp ? TextInputAction.next : TextInputAction.done,
                    onSubmitted: isSignUp ? null : (_) => onSubmit(),
                    decoration: const InputDecoration(
                      labelText: 'Senha *',
                      helperText: 'Mínimo de 6 caracteres',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isSignUp) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onSubmit(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha *',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  if (!isSignUp) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordScreen(),
                                  ),
                                ),
                        child: const Text('Esqueci minha senha'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // RF09: o botão vira indicador de progresso enquanto a
                  // chamada ao Supabase está em andamento, e fica desabilitado
                  // pra evitar submissão dupla.
                  FilledButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(isSignUp ? 'Criar conta' : 'Entrar'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isSubmitting ? null : onToggleMode,
                    child: Text(
                      isSignUp
                          ? 'Já tem conta? Entrar'
                          : 'Não tem conta? Cadastre-se',
                    ),
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

/// Estado pós-cadastro: a conta existe no Supabase, mas a sessão só abre
/// depois de o usuário confirmar o e-mail pelo link recebido — isso não dá
/// pra automatizar de dentro do app.
class _EmailConfirmationNotice extends StatefulWidget {
  final String email;
  final VoidCallback onBackToLogin;

  const _EmailConfirmationNotice({
    required this.email,
    required this.onBackToLogin,
  });

  @override
  State<_EmailConfirmationNotice> createState() => _EmailConfirmationNoticeState();
}

class _EmailConfirmationNoticeState extends State<_EmailConfirmationNotice> {
  bool _isResending = false;
  bool _resent = false;
  String? _resendError;

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _resendError = null;
    });
    try {
      await context.read<AuthProvider>().resendConfirmationEmail(widget.email);
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _resent = true;
      });
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _resendError = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = widget.email;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                    semanticLabel: 'Confirmação de e-mail pendente',
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      'Verifique seu e-mail',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    email.isEmpty
                        ? 'Mandamos um link de confirmação pro e-mail que você cadastrou.'
                        : 'Mandamos um link de confirmação para $email.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no link, depois volte aqui e entre normalmente.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (_resendError != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _resendError!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextButton(
                    onPressed: _isResending ? null : _resend,
                    child: Text(
                      _resent
                          ? 'E-mail reenviado'
                          : (_isResending
                              ? 'Reenviando...'
                              : 'Reenviar e-mail de confirmação'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: widget.onBackToLogin,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Já confirmei, entrar'),
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
