import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/providers/auth_provider.dart';

import 'support/fakes.dart';

/// Regras de negócio do AuthProvider que não dependem de widget (RF07/RF09).
void main() {
  late FakeAuthRepository repository;
  late AuthProvider provider;

  setUp(() {
    repository = FakeAuthRepository();
    provider = AuthProvider(repository);
  });

  tearDown(() {
    provider.dispose();
    repository.dispose();
  });

  group('sendPasswordReset', () {
    test('e-mail inválido falha sem chamar o repositório', () async {
      await provider.sendPasswordReset('nao-e-email');

      expect(provider.errorMessage, isNotNull);
      expect(provider.passwordResetEmailSent, isFalse);
      expect(repository.lastPasswordResetEmail, isNull);
    });

    test('e-mail válido marca passwordResetEmailSent', () async {
      await provider.sendPasswordReset('user@example.com');

      expect(provider.passwordResetEmailSent, isTrue);
      expect(provider.errorMessage, isNull);
      expect(repository.lastPasswordResetEmail, 'user@example.com');
    });
  });

  group('clearError', () {
    test('limpa o erro deixado por uma tentativa de login anterior', () async {
      await provider.signIn('user@example.com', '');
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });
  });

  group('resendConfirmationEmail', () {
    test('chama o repositório com o e-mail certo', () async {
      await provider.resendConfirmationEmail('user@example.com');

      expect(repository.lastResendEmail, 'user@example.com');
    });
  });

  group('deleteAccount', () {
    test('desloga o usuário', () async {
      expect(provider.isLoggedIn, isTrue);

      await provider.deleteAccount();

      expect(provider.isLoggedIn, isFalse);
    });
  });
}
