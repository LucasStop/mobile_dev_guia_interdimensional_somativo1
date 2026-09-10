import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/providers/auth_provider.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/screens/profile_screen.dart';
import 'package:provider/provider.dart';

import 'support/fakes.dart';

/// Regressão achada em teste manual: sair (ou excluir a conta) precisa
/// desempilhar a própria tela de perfil. Sem isso, o gate de sessão troca a
/// rota raiz pro login por baixo, mas o Perfil — empilhado por cima — fica
/// preso na tela, mostrando o e-mail sumido em vez de voltar pro login.
void main() {
  Future<void> pumpBehindProfile(WidgetTester tester, AuthProvider auth) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  child: const Text('tela de baixo'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('tela de baixo'));
    await tester.pumpAndSettle();
  }

  testWidgets('sair da conta desempilha a tela de perfil', (tester) async {
    final repository = FakeAuthRepository();
    final auth = AuthProvider(repository);
    addTearDown(() {
      auth.dispose();
      repository.dispose();
    });

    await pumpBehindProfile(tester, auth);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsNothing);
    expect(find.text('tela de baixo'), findsOneWidget);
  });

  testWidgets('excluir conta com sucesso desempilha a tela de perfil', (tester) async {
    final repository = FakeAuthRepository();
    final auth = AuthProvider(repository);
    addTearDown(() {
      auth.dispose();
      repository.dispose();
    });

    await pumpBehindProfile(tester, auth);

    await tester.tap(find.text('Excluir minha conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsNothing);
    expect(find.text('tela de baixo'), findsOneWidget);
  });
}
