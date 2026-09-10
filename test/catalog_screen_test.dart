import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/data/theme_storage.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/providers/auth_provider.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/providers/character_list_provider.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/providers/theme_provider.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/screens/catalog_screen.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/services/rick_morty_service.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/widgets/character_card.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/widgets/error_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

/// Testes da tela principal (RF01, RF09).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> character(int id, String name) => {
        'id': id,
        'name': name,
        'status': 'Alive',
        'species': 'Human',
        'gender': 'Male',
        'image': '',
        'origin': {'name': 'Earth', 'url': ''},
        'location': {'name': 'Citadel'},
        'episode': const <String>[],
      };

  /// Monta a tela com os providers reais, mas com armazenamento em memória e
  /// um cliente HTTP controlado.
  Future<void> pumpCatalog(
    WidgetTester tester, {
    required Future<http.Response> Function(http.Request) respond,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await ThemeStorage.open();
    final service = RickMortyService(client: MockClient(respond));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(FakeAuthRepository())),
          ChangeNotifierProvider(
            create: (_) => FavoritesProvider(FakeCharacterListRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => WatchedProvider(FakeCharacterListRepository()),
          ),
          ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ],
        child: MaterialApp(home: CatalogScreen(service: service)),
      ),
    );
  }

  http.Response jsonResponse(Object body, {int statusCode = 200}) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  testWidgets('mostra o indicador de progresso antes de a lista chegar',
      (tester) async {
    await pumpCatalog(
      tester,
      respond: (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return jsonResponse({
          'info': {'next': null},
          'results': [character(1, 'Rick Sanchez')],
        });
      },
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('renderiza um card por personagem retornado', (tester) async {
    await pumpCatalog(
      tester,
      respond: (_) async => jsonResponse({
        'info': {'next': 'https://example.test/character?page=2'},
        'results': [
          character(1, 'Rick Sanchez'),
          character(2, 'Morty Smith'),
        ],
      }),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CharacterCard), findsNWidgets(2));
    expect(find.text('Rick Sanchez'), findsOneWidget);
  });

  testWidgets('esconde "Carregar Mais" na última página', (tester) async {
    await pumpCatalog(
      tester,
      respond: (_) async => jsonResponse({
        'info': {'next': null},
        'results': [character(826, 'Butter Robot')],
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('Carregar Mais'), findsNothing);
    expect(find.text('Você chegou ao fim do catálogo.'), findsOneWidget);
  });

  testWidgets('rolar até o fim busca a página seguinte automaticamente',
      (tester) async {
    // Contagem de chamadas em vez de contar CharacterCard: o GridView só
    // constrói os itens visíveis, então "quantos cards existem" não reflete
    // quantas páginas já chegaram numa lista de 20+ itens.
    var requests = 0;
    await pumpCatalog(
      tester,
      respond: (_) async {
        requests++;
        return jsonResponse({
          'info': {
            'next': requests == 1 ? 'https://example.test/?page=2' : null,
          },
          // Página cheia pra garantir que a grade role, senão não há como
          // simular "chegar perto do fim" da lista.
          'results': List.generate(
            20,
            (i) => character(requests * 100 + i, 'Página $requests item $i'),
          ),
        });
      },
    );
    await tester.pumpAndSettle();
    expect(requests, 1);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100000));
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('Carregar Mais'), findsNothing);
  });

  testWidgets('puxar pra baixo recarrega a primeira página', (tester) async {
    var loads = 0;
    await pumpCatalog(
      tester,
      respond: (_) async {
        loads++;
        return jsonResponse({
          'info': {'next': null},
          'results': [character(loads, 'Carga $loads')],
        });
      },
    );
    await tester.pumpAndSettle();
    expect(loads, 1);

    await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.text('Carga 2'), findsOneWidget);
  });

  testWidgets('falha de rede vira mensagem amigável com opção de repetir',
      (tester) async {
    await pumpCatalog(
      tester,
      respond: (_) async => jsonResponse({'error': 'boom'}, statusCode: 500),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('a busca continua acessível mesmo com o catálogo em erro',
      (tester) async {
    await pumpCatalog(
      tester,
      respond: (_) async => jsonResponse({'error': 'boom'}, statusCode: 500),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Buscar personagem'), findsOneWidget);
  });
}
