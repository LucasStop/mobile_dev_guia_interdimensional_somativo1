# Guia Interdimensional

Catálogo interativo de personagens de **Rick and Morty**, em Flutter.

Projeto Somativo 1 da disciplina **Mobile Development: Framework** — Bacharelado em Sistemas de Informação, PUCPR, 6º período, 2026/2. Professor Mark Joselli.

| | |
|---|---|
| **Equipe** | Lucas Stopinski da Silva · Lucas Bruno e Silva |
| **API** | [Rick and Morty API](https://rickandmortyapi.com) — pública, gratuita, sem chave |
| **Persistência** | Local (`shared_preferences`) |
| **Login** | Local |
| **Entrega** | 20/09/2026 |

## Como rodar

```bash
flutter pub get
flutter run
```

Requer Flutter 3.44+ (Dart 3.12). Nenhuma chave de API ou arquivo de configuração é necessário — a Rick and Morty API é aberta.

O login é local: qualquer usuário com senha de 4 caracteres ou mais abre a sessão.

## Testes

```bash
flutter analyze   # sem issues
flutter test      # 20 testes
```

Os testes cobrem o parsing da API, os limites de paginação, os estados da tela de catálogo e o ciclo de vida das listas persistidas. Nenhum toca a rede: o `RickMortyService` recebe um `http.Client` injetado e as telas recebem o service pronto.

## Estrutura

```
lib/
  main.dart                    providers globais e o gate de sessão
  models/                      character · location · episode
  services/                    rick_morty_service — todo o contato com a API
  data/                        local_storage — shared_preferences
  providers/                   auth · character_list (favoritos e vistos)
  screens/                     login · catalog · character_detail · marked_list
  widgets/                     character_card · character_search_field · loading_view · error_view
  theme/                       app_theme — contraste, alvos de toque, escala de fonte
```

A separação segue as camadas: nenhuma tela conhece `http` ou `SharedPreferences` diretamente, e nenhum service conhece widgets.

## Requisitos funcionais

| RF | Implementado | Arquivo principal |
|---|---|---|
| RF01 — Catálogo em `GridView` com "Carregar Mais" | Sim | `lib/screens/catalog_screen.dart` |
| RF02 — Navegação para detalhes | Sim | `lib/screens/catalog_screen.dart` |
| RF03 — Detalhes com segunda requisição | Sim | `lib/screens/character_detail_screen.dart` |
| RF04 — Favoritos com Provider | Sim | `lib/providers/character_list_provider.dart` |
| RF05 — Tela de favoritos | Sim | `lib/screens/marked_list_screen.dart` |
| RF06 — Persistência local | Sim | `lib/data/local_storage.dart` |
| RF07 — Login e lista de vistos | Sim | `lib/providers/auth_provider.dart`, `lib/screens/login_screen.dart` |
| RF08 — Busca por nome | Sim | `lib/widgets/character_search_field.dart` |
| RF09 — Feedback de UI | Sim | `lib/widgets/loading_view.dart`, `lib/widgets/error_view.dart` |
| RF10 — Acessibilidade | Sim | `lib/theme/app_theme.dart` |

## Decisões que a API impôs

Quatro comportamentos da Rick and Morty API foram verificados por requisição real antes de virarem código:

- **`info.next` é nulo na página 42.** O botão "Carregar Mais" desaparece nesse ponto, em vez de pedir uma página que não existe.
- **A busca responde 404 quando nada bate.** O `RickMortyService` traduz isso em mensagem de tela; nenhum widget lida com código HTTP.
- **`/episode/{id}` muda de formato conforme a quantidade de ids** — objeto para um, array para vários. O service normaliza os dois casos.
- **Personagens como o "Adjudicator Rick" têm origem sem URL.** A tela de detalhes reconhece isso e não tenta buscar o local.

Como a API sempre devolve `image` preenchido, o placeholder de imagem exigido pelo RF01 é acionado pelo `errorBuilder` do `Image.network` — que é o caso que de fato acontece em produção: imagem que não carrega por falha de rede.

## Divisão do trabalho

| Integrante | Responsabilidade |
|---|---|
| Lucas Stopinski da Silva | Camada de dados e API, catálogo com paginação, tela de detalhes, busca, estados de carregamento e erro (RF01, RF02, RF03, RF08, RF09) |
| Lucas Bruno e Silva | Sessão e login, estado global com Provider, persistência local, favoritos, vistos, acessibilidade (RF04, RF05, RF06, RF07, RF10) |

## Uso de IAGen

Durante a preparação deste projeto, os autores usaram Claude (Anthropic) para apoio na estruturação do código, revisão e documentação. Após usar essa ferramenta, os autores revisaram e editaram o conteúdo conforme necessário e assumem total responsabilidade pelo conteúdo.
