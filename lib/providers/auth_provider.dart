import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';

/// Estado de sessão do app (RF07 — autenticação real via Supabase Auth).
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  late final StreamSubscription<bool> _authSubscription;

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _awaitingEmailConfirmation = false;
  bool _passwordResetEmailSent = false;

  AuthProvider(this._repository) {
    // A sessão pode mudar por fora de um `signIn` explícito — token
    // expirando, refresh automático do pacote — então a UI escuta o stream
    // em vez de só confiar no retorno das próprias chamadas.
    _authSubscription = _repository.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  bool get isLoggedIn => _repository.isLoggedIn;
  String? get userEmail => _repository.userEmail;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get awaitingEmailConfirmation => _awaitingEmailConfirmation;
  bool get passwordResetEmailSent => _passwordResetEmailSent;

  Future<void> signUp(String email, String password, String confirmPassword) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      _fail('Preencha e-mail e senha.');
      return;
    }
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      _fail('Digite um e-mail válido.');
      return;
    }
    if (password.length < 6) {
      _fail('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (password != confirmPassword) {
      _fail('As senhas não coincidem.');
      return;
    }

    _startSubmitting();
    try {
      final result = await _repository.signUp(trimmedEmail, password);
      _isSubmitting = false;
      _awaitingEmailConfirmation =
          result.outcome == SignUpOutcome.awaitingEmailConfirmation;
      notifyListeners();
    } on AuthFailure catch (e) {
      _fail(e.message);
    }
  }

  Future<void> signIn(String email, String password) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      _fail('Preencha e-mail e senha.');
      return;
    }

    _startSubmitting();
    try {
      await _repository.signIn(trimmedEmail, password);
      _isSubmitting = false;
      notifyListeners();
    } on AuthFailure catch (e) {
      _fail(e.message);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final trimmedEmail = email.trim();

    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      _fail('Digite um e-mail válido.');
      return;
    }

    _startSubmitting();
    try {
      await _repository.sendPasswordResetEmail(trimmedEmail);
      _isSubmitting = false;
      _passwordResetEmailSent = true;
      notifyListeners();
    } on AuthFailure catch (e) {
      _fail(e.message);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _errorMessage = null;
    _awaitingEmailConfirmation = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    _startSubmitting();
    try {
      await _repository.deleteAccount();
      _isSubmitting = false;
      _errorMessage = null;
      notifyListeners();
    } on AuthFailure catch (e) {
      _fail(e.message);
    }
  }

  /// Reenvia o e-mail de confirmação de cadastro. Sem estado próprio no
  /// provider — a tela que chama controla seu próprio feedback local, porque
  /// isso não deve competir com `isSubmitting`/`errorMessage` do formulário
  /// principal.
  Future<void> resendConfirmationEmail(String email) =>
      _repository.resendConfirmationEmail(email);

  /// Limpa erro de uma tela anterior antes de abrir outro fluxo (ex.:
  /// "esqueci minha senha" não deve herdar o erro de um login que falhou).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Volta da tela "verifique seu e-mail" pro formulário de entrar.
  void dismissEmailConfirmationNotice() {
    _awaitingEmailConfirmation = false;
    notifyListeners();
  }

  void _startSubmitting() {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _fail(String message) {
    _isSubmitting = false;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
