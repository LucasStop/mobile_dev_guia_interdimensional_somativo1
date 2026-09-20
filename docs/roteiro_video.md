# Roteiro de gravação — Guia Interdimensional

Roteiro para o vídeo de entrega (item 7 da rubrica). A tela do app e do
código já está gravada em clipes **sem áudio**; cada integrante grava a
própria narração por fora e a edição junta tudo.

A divisão de quem fala o quê segue o que cada um **commitou de verdade**
(`git log --format='%an %s'`, conferido por arquivo) — cada um explica o
código que efetivamente escreveu.

**Limite:** 6 a 8 minutos (item 8 da rubrica pune -5%/minuto fora do
intervalo). **Rascunho atual: 7:29**, com folga dos dois lados.

---

## Status dos clipes

Pasta `docs/video/` (ignorada pelo git, os `.mov` passam de 100 MB no total).

| Bloco | Clipe | Duração bruta | Quem narra | Status |
|---|---|---|---|---|
| 1 | apresentação (câmera) | 0:04 + 0:10 | os dois | vozes recebidas |
| 2 | `bloco2_stopinski_f1_login` | 0:10 | Stopinski | gravado |
| 2 | `bloco2_stopinski_f2_scroll` | 0:56 | Stopinski | gravado |
| 2 | `bloco2_stopinski_f3_busca` | 0:23 | Stopinski | gravado |
| 2 | `bloco2_stopinski_f4_detalhe` | 0:23 | Stopinski | gravado |
| 2 | `bloco2_bruno_f4_favoritar` | 0:07 | Bruno | gravado |
| 2 | `bloco2_bruno_f5_drawer` | 0:32 | Stopinski (narra) | gravado |
| 2 | `bloco2_bruno_f6_tema` | 0:12 | Bruno | gravado |
| 3 | `bloco3_stopinski` | 2:27 | Stopinski | gravado |
| 3 | `bloco3_bruno` | 2:27 | Bruno | gravado |
| 4 | `bloco4_bruno` | 1:21 | Bruno | gravado |
| 4 | `bloco4_stopinski` | 1:34 | Stopinski | gravado |

Bruto de tela: 10:32. O excesso é pausa reservada para a fala e será
cortado na edição (orçamento abaixo).

### Vozes do Bruno (recebidas)

8 clipes de câmera com áudio em `docs/video/vozes/bruno/`, transcritos em
`transcricao/` (índice e textos em `vozes/bruno/LEIA.md`). Total ~2:21 de
fala. Pendências encontradas na transcrição:

- [x] **Bloco 3, tema (`bloco3_bruno_4_tema_voz`):** regravado. A versão nova
      diz que o `ColorScheme` é definido à mão e que o `flex_color_scheme`
      só refina subtemas, como o código. A versão errada ficou em
      `vozes/bruno/substituidos/`.
- [ ] **Bloco 1:** conferir de ouvido se ele diz "Lucas Bruno e Silva". O
      Whisper sem contexto entendeu "Lucas Brincilla"; com o nome como dica
      saiu certo. O nome tem que bater com a capa do PDF.
- [x] **Bloco 2, menu lateral (F5):** o Stopinski narra (fala abaixo, no
      Bloco 2).
- [x] **Duração:** a fala do Bruno soma ~1:56 (Bloco 1 0:10, Bloco 2 0:09,
      Bloco 3 0:55, Bloco 4 0:42). As falas do Stopinski abaixo foram
      escritas para fechar o vídeo em ~6:40; as falas gravadas ficaram maiores e o rascunho fechou em 7:29.

### Vozes do Stopinski (recebidas)

17 clipes de câmera com áudio em `docs/video/vozes/stopinski/`, transcritos
em `transcricao/` (índice e status em `vozes/stopinski/LEIA.md`). Total
5:58 de fala. Nada precisa ser regravado; três pontos para conferir:

- [ ] **Bloco 3, item 6 (`bloco3_stopinski_6_auth_erros_voz`, 0:13–0:15):** a
      transcrição saiu "como ver o orçamento". O texto do app é "Não foi
      possível completar o pedido". Ouvir e, se for isso, corrigir a
      legenda.
- [ ] **Encerramento:** nenhum dos dois gravou "Obrigado por assistir!". É
      opcional, uns 3 segundos no fim.
- [ ] **Menu lateral (F5):** a fala diz que o contador aparece "nessa parte de
      perfil de menu lateral"; o contador está nos itens Vistos e Favoritos.
      Aceitável, só um reparo opcional.

## Orçamento de tempo (rascunho gerado: 7:29)

O corte automático (`docs/video/flows/monta_corte.py`, saída em
`docs/video/edicao/rascunho_v1.mp4` e `.srt`) fecha em **7:29**, dentro da
faixa de 6:00 a 8:00, com o silêncio das pontas de cada fala já aparado.

| Bloco | Duração | Janela no rascunho |
|---|---|---|
| 1 — Apresentação | 0:11 | 0:00–0:11 |
| 2 — App rodando | 2:01 | 0:11–2:12 |
| 3 — Código | 2:51 | 2:12–5:04 |
| 4 — Técnica | 2:25 | 5:04–7:29 |
| **Total** | **7:29** | limite 8:00 |

A tela é acelerada (até 2,5x) quando a fala é mais curta que o clipe e o
último quadro é congelado quando a fala é mais longa (as maiores pausas
congeladas são o item 2 do Bloco 3, 14s, e o início do Bloco 4 do
Stopinski, 20s). A fala manda no tempo.

---

## Antes de gravar as narrações

- [ ] Nomes ditos no Bloco 1 **exatamente** iguais aos da capa do PDF de
      entrega (penalidade de nota zero individual se não bater):
      "Lucas Stopinski da Silva" e "Lucas Bruno e Silva".
- [ ] Ouvir o clipe correspondente enquanto narra, para a fala acompanhar
      a ação da tela (ex.: dizer "Entrar" quando o botão é tocado).
- [ ] Ambiente silencioso, mesmo microfone e mesma distância nos dois
      narradores, para o volume bater na edição.
- [ ] Um arquivo de áudio por bloco e por pessoa, nomeado igual ao clipe
      com sufixo `_voz` (ex.: `bloco3_bruno_voz.m4a`).
- [ ] Conta usada nas gravações de tela: conta de teste `+seedtest`, alias de
      e-mail do Stopinski (o endereço não é registrado aqui porque o repositório
      é público). O e-mail aparece no menu lateral e na
      tela de Perfil. **Trocar a senha dessa conta depois do vídeo**, porque
      foi digitada durante as gravações.

---

## Bloco 1 — Apresentação (0:00–0:11 no rascunho)

Gravado em câmera, cada um no seu próprio take. Não usa clipe de tela.

| Quem | Fala | Duração |
|---|---|---|
| Stopinski | "Oi, eu sou o Lucas Stopinski da Silva." | ~0:03 |
| Bruno | "E eu sou o Lucas Bruno e Silva. Esse é o Guia Interdimensional, um catálogo de personagens de Rick and Morty, projeto da disciplina de Desenvolvimento Mobile Híbrido." (gravado) | 0:10 |

O nome dito tem que bater com a capa do PDF.

---

## Bloco 2 — App rodando (0:11–2:12 no rascunho)

Clipes de tela com a narração por cima, todos no simulador iPhone 17 com a
barra de status limpa (09:41). **Ordem na timeline:** F1, F2, F3, F4
detalhe, [Bruno: F4 favoritar + F6 tema], F5. O Bruno grava uma fala só
para favoritar e tema, então esses dois clipes ficam juntos, e o F5 vem
depois, quando o Rick já está favoritado e visto.

### Stopinski — RF01/02/03/07/08/09

**F1 — `bloco2_stopinski_f1_login` (~0:11).** "Aqui é o login, obrigatório
antes de acessar o catálogo. Preencho e-mail e senha, toco em Entrar e,
enquanto carrega, o app mostra o indicador de progresso. Se o login estiver errado, aparece uma mensagem clara em português."

**F2 — `bloco2_stopinski_f2_scroll` (~0:13).** "Rolando até o fim, a
próxima página de personagens carrega sozinha, sem botão. E puxando a
lista pra baixo, no topo, o app atualiza a primeira página. Quando a API avisa que não há próxima página, o app para de pedir."

**F3 — `bloco2_stopinski_f3_busca` (~0:15).** "Na busca, eu digito um nome
que tem vários resultados, como Morty, e toco no botão de buscar. A tela
de resultados mostra todos os personagens encontrados, não só o primeiro. E se o nome não existir, o app mostra 'Nenhum personagem encontrado com esse nome', em vez de um erro."

**F4 — `bloco2_stopinski_f4_detalhe` (~0:15).** "Ao tocar num personagem,
abre a tela de detalhe: status, espécie, gênero, última localização,
origem e os episódios em que ele aparece."

### Bruno (gravado, 0:09) — RF04/05/06/07/10

**F4 favoritar + F6 tema — `bloco2_bruno_f4_favoritar` e
`bloco2_bruno_f6_tema`.** "Agora eu vou demonstrar pra vocês que aqui eu
consigo marcar como favorito e como visto, e além disso eu também consigo
trocar o tema entre claro e escuro." Mostrar a estrela e o olho
preenchendo e, em seguida, o tema claro → escuro → claro.

### Stopinski — menu lateral

**F5 — `bloco2_bruno_f5_drawer` (~0:28).** O clipe tem esse nome porque foi
gravado com o roteiro antigo, mas quem narra agora é o Stopinski. "E pelo
menu lateral eu acesso as listas. Em Vistos aparece o personagem que eu
marquei como visto, e em Favoritos, o que eu favoritei; o contador de cada
um aparece no menu. Em Perfil ficam o e-mail da conta e as opções de sair
e de excluir a conta, que aqui eu só mostro, sem usar."

O clipe mostra, nesta ordem: menu aberto (Vistos 1, Favoritos 1), lista de
Vistos com o Rick, lista de Favoritos com o Rick, tela de Perfil e volta ao
catálogo.

---

## Bloco 3 — Explicação de código (2:12–5:04 no rascunho)

Clipes `bloco3_stopinski` e `bloco3_bruno`: VS Code em tela cheia, um
arquivo por vez, já posicionado na linha indicada. Cada um explica o que
**commitou**. A tabela mostra a ordem em que os arquivos aparecem no clipe.

### Stopinski (~1:50)

A coluna "gravado" é quanto o clipe `bloco3_stopinski` segura cada
arquivo; a fala pode ser maior, e a edição segura o quadro.

| # | Arquivo | Linha | Gravado | Fala |
|---|---|---|---|---|
| 1 | `lib/services/rick_morty_service.dart` | 43 | 14s | "O `fetchCharacters` busca uma página de vinte personagens na API do Rick and Morty. Ele monta a URL com o número da página, converte o JSON em objetos e devolve também se existe uma próxima página, que é o que o scroll infinito usa." |
| 2 | `lib/models/character.dart` | 39 | 10s | "O `fromJson` transforma o JSON em objeto Dart e já protege contra campo faltando: se a API não mandar um valor, entra um padrão, como 'unknown', em vez de quebrar o app. A origem de alguns personagens vem sem URL, e o parser trata isso como nulo, pra tela de detalhe não tentar buscar um local que não existe." |
| 3 | `lib/widgets/loading_view.dart` | 4 | 11s | "Esses dois widgets cuidam do carregamento e do erro. No catálogo, um `FutureBuilder` mostra o `LoadingView` enquanto a primeira carga acontece..." |
| 4 | `lib/widgets/error_view.dart` | 5 | 11s | "...e, se falhar, mostra o `ErrorView`, com uma mensagem amigável e um botão de tentar de novo, sem travar a tela." |
| 5 | `lib/data/character_list_repository.dart` | 39 e 63 | 9s + 5s | "Aqui está a defesa em profundidade. Tanto pra buscar quanto pra remover, a consulta filtra pelo `user_id` do usuário logado, além da RLS do banco. Se uma das duas camadas falhar, a outra ainda protege." |
| 6 | `lib/data/auth_repository.dart` | 9 | 12s | "O `translateAuthErrorMessage` recebe a mensagem crua do Supabase e devolve uma frase em português, sem detalhe técnico. O que ele não reconhece vai pro log, e o usuário vê só uma mensagem genérica." *Frase opcional (+6s, ver orçamento):* "E essa função tem seis testes automatizados, inclusive um que garante que mensagem desconhecida vire resposta fixa, sem vazar o texto bruto." |
| 7 | `lib/screens/forgot_password_screen.dart` | 10 | 8s | "Além do pedido, eu implementei a gestão de conta. Em 'esqueci minha senha', o app envia um e-mail de recuperação pelo Supabase..." |
| 8 | `lib/screens/new_password_screen.dart` | 13 | 8s | "...e essa tela deixa o usuário definir uma nova senha, depois de abrir o link recebido." |
| 9 | `lib/screens/profile_screen.dart` | 104 | 9s | "E no Perfil, a exclusão de conta pede confirmação antes, porque apaga a conta e os dados de forma permanente." |

Só mostrar as telas de conta, sem completar o fluxo (não enviar e-mail
real nem confirmar exclusão).

### Bruno (gravado, 0:55)

A tabela mostra o que o roteiro previa; a fala gravada está em
`vozes/bruno/LEIA.md`.

| # | Arquivo | Linha | Fala |
|---|---|---|---|
| 1 | `lib/providers/character_list_provider.dart` | 13 | "Esse Provider guarda o estado de favoritos e vistos de forma global, em vez de cada tela ter o próprio `setState`. Favoritar num lugar atualiza a lista de Favoritos em outro." |
| 2 | `lib/data/character_list_repository.dart` | 48 | "O `upsert` sincroniza favoritos e vistos com o Supabase, na nuvem." |
| 3 | `lib/main.dart` | 19 e 36 | "Aqui o Supabase é inicializado e os providers são conectados com o Supabase Auth pro login real." |
| 4 | `lib/theme/app_theme.dart` | 71 | "O `ColorScheme` é definido à mão, com contraste calculado, nas variantes clara e escura. O `flex_color_scheme` entra só pra refinar subtemas (diálogo, switch, snackbar). E os botões têm alvo de toque mínimo de 48dp." |
| 5 | `lib/screens/catalog_screen.dart` | 156, 67 e 175 | "O menu lateral (`Drawer`), o scroll infinito (`_onScroll`) e o pull-to-refresh (`RefreshIndicator`) são extras além do obrigatório." |

**Correção em relação à versão anterior do roteiro:** a fala sobre o tema
dizia que o app "usa o `flex_color_scheme` com a paleta da série". O código
diz o contrário (`app_theme.dart:73`): a paleta é um `ColorScheme` manual
e o `flex_color_scheme` só faz o polimento de subtemas. A fala acima está
corrigida.

---

## Bloco 4 — Explicação técnica aprofundada (5:04–7:29 no rascunho)

**Tema: Local vs. Nuvem** (bônus RF06/RF07). O grupo implementou os dois de
verdade: o Bruno começou com `shared_preferences` (commit `3ed93cb`) e
depois migrou para o Supabase. Hoje o `shared_preferences` guarda só a
preferência de tema.

Tela: `bloco4_bruno` e `bloco4_stopinski`, também em VS Code.

### Bruno (gravado, 0:42)

Arquivos na tela: `lib/data/theme_storage.dart` (linha 12, o lado local)
e `lib/data/character_list_repository.dart` (linha 48, o lado nuvem).
A fala gravada está em `vozes/bruno/LEIA.md`.

### Stopinski (~1:25 + encerramento)

Arquivos na tela, nesta ordem: `docs/video/bloco4_rls_policies.md` (as 4
políticas reais do banco: select, insert, update e delete, todas com
`auth.uid() = user_id`; clipe segura 40s), `character_list_repository.dart`
(linha 39, 18s) e `auth_repository.dart` (linha 9, 14s).

Fala sugerida (~1:25): "E é nesse ponto que a nuvem exige mais cuidado que
o local. Com o Supabase, os dados de todos os usuários ficam na mesma
tabela: uma só pras duas listas, em que cada linha guarda o usuário, o
personagem, o tipo (favorito ou visto) e o personagem inteiro em JSON. A
chave primária junta os três, então favoritar duas vezes não duplica, e se
o usuário for apagado, as linhas dele saem junto, em cascata. Por ser
uma tabela compartilhada, a gente precisou de Row Level Security. São quatro políticas,
uma pra cada operação: select, insert, update e delete, todas com a mesma
regra, o `auth.uid()` igual ao `user_id` da linha. Sem sessão, o
`auth.uid()` é nulo e nenhuma linha passa, então a chave anônima que está
no app não lê nem escreve a lista de ninguém. Só que a RLS sozinha não é a
única camada: a gente também filtra por `user_id` direto no client, como
defesa em profundidade. E teve uma coisa que só apareceu com backend real:
a mensagem de erro crua do Supabase não pode vazar pra tela, porque expõe
detalhe interno; por isso a gente traduz e sanitiza antes de mostrar pro
usuário. Além disso, o cadastro só abre sessão depois que o usuário
confirma o e-mail pelo link que recebe."

### Encerramento (~0:03)

"Obrigado por assistir!" — manter o último quadro na tela.

---

## Pós-produção: plano de edição

### 1. Organização

Copiar tudo para uma pasta do projeto de edição, mantendo os nomes:
clipes de tela (`bloco2_*`, `bloco3_*`, `bloco4_*`), áudios (`*_voz`) e o
Bloco 1 em câmera (`bloco1_*`).

### 2. Ordem na timeline

Bloco 1 (Stopinski, Bruno) → Bloco 2 (F1, F2, F3, F4 detalhe, F4 favoritar +
F6 tema, F5) → Bloco 3 Stopinski → Bloco 3 Bruno → Bloco 4 Bruno →
Bloco 4 Stopinski → encerramento.

### 3. Sincronia

Os clipes de tela não têm áudio, então não há marcador de sincronia. A
narração é alinhada **pela ação**: o clipe grava por tempo real, mas o
`simctl` comprime trechos parados, então os tempos não batem com a fala.
Ajustar cada trecho pela ação na tela (ex.: o toque em "Entrar", a página 2
chegando, a estrela preenchendo) e segurar o último quadro quando a fala for
maior que o clipe.

### 4. Tratamento de vídeo

- Cortar cada clipe no início e no fim útil, sem tela parada sobrando.
- As gravações de app são 1206x2622 (retrato) e as de código 2048x1330
  (paisagem). Escolher um enquadramento: quadro 16:9 com o celular
  centralizado (fundo neutro ou desfoque) nos blocos do app.
- O Perfil e o menu lateral mostram o e-mail da conta; se incomodar,
  desfocar esse trecho.

### 5. Tratamento de áudio

- Normalizar o volume entre os dois narradores.
- Reduzir ruído de fundo com o denoise do editor, se precisar.
- Cortar respiros longos e erros de fala.

### 6. Transcrição e legenda

- **Transcrever o áudio real gravado**, não copiar as falas sugeridas
  daqui, porque o que foi dito vai divergir.
- Subir o vídeo montado como **não-listado** no YouTube Studio, gerar a
  legenda automática, baixar o `.srt`, revisar e corrigir manualmente
  (termos técnicos: Provider, Supabase, RLS, FutureBuilder, widget,
  Flutter, Dart, `shared_preferences`, `flex_color_scheme`) e só depois
  mudar para público.
- Alternativa sem YouTube: CapCut ou DaVinci Resolve, que transcrevem
  localmente.
- Depois de corrigir o texto, conferir se a legenda ainda está sincronizada.

### 7. Verificação final antes de publicar

Assistir o vídeo inteiro:

- [ ] Nomes completos do Bloco 1 batem com a capa do PDF.
- [ ] Os 4 blocos aparecem na ordem certa, aproximadamente em
      0:00–0:11 / 0:11–2:12 / 2:12–5:04 / 5:04–7:29 (rascunho).
- [ ] Duração total entre 6:00 e 8:00 (rascunho 7:29).
- [ ] Áudio audível e sincronizado nos dois narradores.
- [ ] A fala do tema (Bloco 3, Bruno) diz que o `ColorScheme` é manual.
- [ ] Legenda sem erro de português nem de termo técnico.
- [ ] Nenhuma tela preta, travamento ou corte falho.
- [ ] Nenhuma janela fora do app ou do editor aparece no vídeo.
- [ ] Exportado em 1080p.
- [ ] Upload como **Público** no YouTube (a rubrica exige público, não
      não-listado, na versão final).

---

## Pós-gravação: checklist de entrega

1. [x] `docs/Somativo1_Flutter_Entrega.pdf` atualizado: link do YouTube
   (Seção 1, clicável) `https://youtu.be/C1bUGOo5SoE`, minuto da explicação
   técnica (Seção 4) **5:04 – 7:29**, e Seção 7 trocada pela linha do tempo
   real do vídeo.
2. [x] Vídeo enviado com 7:29 de duração, dentro dos 6 a 8 minutos.
3. [x] Legenda em português (Brasil) anexada e publicada no YouTube
   (`guia_interdimensional_final.pt-BR.srt`), com a sincronia conferida no
   início, no Bloco 3 e no Bloco 4.
4. [ ] Visibilidade **Público** (a rubrica exige público; o vídeo foi enviado
   como não listado).
5. [ ] Trocar a senha da conta de gravação (`+seedtest`) e, se quiser, apagar
   os favoritos/vistos do Rick Sanchez que ficaram nela.
