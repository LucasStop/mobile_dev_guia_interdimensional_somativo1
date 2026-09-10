import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/data/auth_repository.dart';

/// Tradução de erro do Supabase Auth pra mensagem PT-BR.
///
/// O caso "mensagem desconhecida" é o que trava a regressão: antes o
/// fallback devolvia `e.message` cru pra UI, vazando detalhe interno do
/// Supabase pro usuário final.
void main() {
  group('translateAuthErrorMessage', () {
    test('e-mail já cadastrado', () {
      expect(
        translateAuthErrorMessage('User already registered'),
        'Este e-mail já tem uma conta — tente entrar em vez de cadastrar.',
      );
    });

    test('credenciais inválidas', () {
      expect(
        translateAuthErrorMessage('Invalid login credentials'),
        'E-mail ou senha incorretos.',
      );
    });

    test('e-mail não confirmado', () {
      expect(
        translateAuthErrorMessage('Email not confirmed'),
        'Confirme seu e-mail antes de entrar — veja o link que mandamos pra sua caixa de entrada.',
      );
    });

    test('senha curta', () {
      expect(
        translateAuthErrorMessage('Password should be at least 6 characters'),
        'A senha precisa ter pelo menos 6 caracteres.',
      );
    });

    test('rate limit', () {
      expect(
        translateAuthErrorMessage('Email rate limit exceeded'),
        'Muitas tentativas em pouco tempo. Aguarde um instante e tente de novo.',
      );
    });

    test('mensagem desconhecida vira resposta fixa, sem vazar o texto bruto', () {
      const raw = 'relation "auth.some_internal_table" does not exist';
      final translated = translateAuthErrorMessage(raw);

      expect(translated, 'Não foi possível completar o pedido. Tente novamente em instantes.');
      expect(translated.contains(raw), isFalse);
    });
  });
}
