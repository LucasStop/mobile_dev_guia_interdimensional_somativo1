import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Traduz a mensagem de um `AuthException` do Supabase pra PT-BR.
///
/// Mensagens desconhecidas caem num fallback genérico em vez de devolver o
/// texto bruto do Supabase — evita vazar detalhe interno da API pra UI.
String translateAuthErrorMessage(String rawMessage) {
  final message = rawMessage.toLowerCase();
  if (message.contains('already registered') ||
      message.contains('already exists') ||
      message.contains('user already')) {
    return 'Este e-mail já tem uma conta — tente entrar em vez de cadastrar.';
  }
  if (message.contains('invalid login credentials')) {
    return 'E-mail ou senha incorretos.';
  }
  if (message.contains('email not confirmed')) {
    return 'Confirme seu e-mail antes de entrar — veja o link que mandamos pra sua caixa de entrada.';
  }
  if (message.contains('password') &&
      (message.contains('6') || message.contains('short'))) {
    return 'A senha precisa ter pelo menos 6 caracteres.';
  }
  if (message.contains('rate limit') || message.contains('security purposes')) {
    return 'Muitas tentativas em pouco tempo. Aguarde um instante e tente de novo.';
  }
  developer.log('Erro de auth não mapeado: $rawMessage', name: 'AuthRepository');
  return 'Não foi possível completar o pedido. Tente novamente em instantes.';
}

/// Falha de autenticação já traduzida pra uma mensagem que pode ir direto
/// pra tela (RF09), sem a UI precisar conhecer a API do Supabase.
class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}

enum SignUpOutcome { signedIn, awaitingEmailConfirmation }

class SignUpResult {
  final SignUpOutcome outcome;
  const SignUpResult(this.outcome);
}

/// Sessão e cadastro do app (RF07 — autenticação real).
///
/// A implementação real envelopa o Supabase Auth; os testes de widget usam um
/// fake com a mesma interface, porque `Supabase.initialize` exige rede e
/// quebraria a filosofia de testes offline do projeto.
abstract class AuthRepository {
  bool get isLoggedIn;
  String? get userEmail;

  /// Emite `true`/`false` a cada mudança de sessão — login, logout, refresh.
  Stream<bool> get authStateChanges;

  Future<SignUpResult> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  final supabase.SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  bool get isLoggedIn => _client.auth.currentSession != null;

  @override
  String? get userEmail => _client.auth.currentUser?.email;

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((data) => data.session != null);

  @override
  Future<SignUpResult> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      // Com confirmação de e-mail obrigatória (padrão em projeto Supabase
      // hospedado), o cadastro nunca devolve sessão de cara — o usuário só
      // ganha uma depois de clicar no link recebido por e-mail e entrar.
      final outcome = response.session != null
          ? SignUpOutcome.signedIn
          : SignUpOutcome.awaitingEmailConfirmation;
      return SignUpResult(outcome);
    } on supabase.AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on supabase.AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  String _translate(supabase.AuthException e) => translateAuthErrorMessage(e.message);
}
