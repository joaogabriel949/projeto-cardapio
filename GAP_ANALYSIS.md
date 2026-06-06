# GAP_ANALYSIS.md — NutriGo (goomer_nutri)

> Gerado em: 2026-06-05  
> Metodologia: comparação entre os padrões definidos em `.agent/` e o estado atual do código em `lib/`.

---

## 1. O que a `.agent/` define como padrão para este projeto

A pasta `.agent/` é um toolkit de agentes de IA (AG Kit). Ela **não é um documento de requisitos de produto**, mas define padrões técnicos e de UX que devem ser seguidos no desenvolvimento. As fontes relevantes para este projeto Flutter são:

| Fonte | O que define |
|---|---|
| `.agent/skills/app-builder/templates/flutter-app/TEMPLATE.md` | Stack obrigatória: Riverpod, Go Router, Dio, Hive, Freezed; clean architecture feature-first |
| `.agent/agents/mobile-developer.md` | Padrões de UX mobile: touch targets, estados de loading/erro, offline, segurança |
| `lib/screens/home_screen.dart` (menu desativado) | Funcionalidades planejadas: Novo Paciente, Criar Cardápio, Buscar Usuários, Cardápios Salvos |

---

## 2. Inventário do código atual

### Telas/Páginas

| Arquivo | Descrição | Estado |
|---|---|---|
| `lib/screens/login_screen.dart` | Tela de login com e-mail/senha | Existe, fake |
| `lib/screens/home_screen.dart` | Menu principal com 6 ações | Existe, 4 desativadas |
| `lib/screens/novo_alimento_screen.dart` | Cadastro com busca TACO + OpenFoodFacts | Existe, funcional |
| `lib/screens/lista_alimentos_screen.dart` | Lista + detalhes nutricionais + Nutri-Score | Existe, funcional |
| `lib/screens/consultar_screen.dart` | Busca de alimentos (protótipo) | Existe, **órfã** — não referenciada em nenhuma rota |

### Modelos / Banco de dados

| Arquivo | Descrição |
|---|---|
| `lib/database/db_helper.dart` | Singleton SQLite com 4 tabelas: `usuarios`, `taco_alimentos`, `alimentos`, `cardapios` |
| `lib/database/taco_alimentos.json` | Tabela TACO 4ª ed. (UNICAMP) embutida como asset |

### Gerenciamento de estado

- **Nenhum**: apenas `StatefulWidget` + `setState`. Sem Provider, Riverpod, BLoC ou qualquer solução de estado.

### Navegação

- **Imperativa pura**: `Navigator.push` / `Navigator.pushReplacement`. Sem Go Router ou qualquer sistema declarativo.

### Integrações

| Integração | Status |
|---|---|
| SQLite via `sqflite` | Ativo |
| OpenFoodFacts via `openfoodfacts` package | Ativo |
| Tabela TACO local (JSON asset) | Ativo |
| Autenticação real | Ausente |
| HTTP genérico (Dio) | Ausente |

### Dependências (`pubspec.yaml`)

```yaml
google_fonts: ^8.1.0
path: ^1.9.1
path_provider: ^2.1.5
sqflite: ^2.4.2+1
openfoodfacts: ^3.20.0
```

Ausentes vs. template: `flutter_riverpod`, `go_router`, `dio`, `hive`, `freezed`.

### Testes

| Arquivo | Cobertura |
|---|---|
| `test/widget_test.dart` | Smoke test básico — apenas verifica que `MaterialApp` renderiza |

---

## 3. Comparação requisitos × implementação

### 3.1 Arquitetura e Stack

| Requisito (`.agent/`) | Status | Observação |
|---|---|---|
| State management: Riverpod 2.0 | ❌ Faltando | Apenas `setState`, sem gerenciamento de estado |
| Navegação: Go Router | ❌ Faltando | `Navigator.push` imperativo |
| HTTP client: Dio | ❌ Faltando | Usa `openfoodfacts` package direto |
| Storage local: Hive | ❌ Faltando | Usa `sqflite` (funcional, mas diverge do padrão) |
| Modelos imutáveis: Freezed | ❌ Faltando | Usa `Map<String, dynamic>` bruto |
| Clean architecture feature-first | ❌ Faltando | Todos os arquivos na raiz de `lib/screens/` e `lib/database/` |
| Camada Domain (entities, use cases) | ❌ Faltando | Lógica direto nas telas |
| Camada Data (repositories, models) | ❌ Faltando | `DatabaseHelper` mistura acesso a dados e mapeamento |

### 3.2 Funcionalidades de produto

| Funcionalidade | Status | Observação |
|---|---|---|
| Cadastro de alimentos (TACO + OpenFoodFacts) | ✅ Implementado | Funcional com busca automática |
| Listagem de alimentos com detalhes nutricionais | ✅ Implementado | Modal com Nutri-Score funciona |
| Excluir alimento | 🟡 Parcial | Sem diálogo de confirmação antes de deletar |
| Buscar alimento na lista | ❌ Faltando | Não há campo de busca em `lista_alimentos_screen.dart` |
| Novo Paciente / Cadastro de usuário | ❌ Faltando | Botão desativado no menu |
| Criar Cardápio | ❌ Faltando | Botão desativado; tabela `cardapios` existe no banco mas sem UI |
| Buscar Usuários | ❌ Faltando | Botão desativado no menu |
| Cardápios Salvos | ❌ Faltando | Botão desativado no menu |
| Tela "Consultar" (busca pública) | 🟡 Parcial | Tela existe com dados mock, mas **não está acessível** (nenhuma rota aponta para ela) |

### 3.3 Autenticação

| Requisito | Status | Observação |
|---|---|---|
| Login funcional com validação | ❌ Faltando | Aceita qualquer entrada, sem verificação |
| Recuperação de senha | ❌ Faltando | Botão sem `onPressed` real |
| Tokens em armazenamento seguro | ❌ Faltando | Não há token — nem `flutter_secure_storage` |
| Logout que limpa sessão | 🟡 Parcial | Navega de volta ao login, mas não há sessão real para limpar |

### 3.4 Qualidade mobile (padrões do `mobile-developer.md`)

| Padrão | Status | Observação |
|---|---|---|
| Touch targets ≥ 48dp | 🟡 Parcial | Cards usam `ListTile` (tamanho padrão OK), mas sem auditoria explícita |
| Estado de loading em toda operação assíncrona | 🟡 Parcial | `lista_alimentos` tem loader; `novo_alimento` tem spinner na busca; login sem loading |
| Estado de erro com retry | 🟡 Parcial | `lista_alimentos` mostra mensagem de erro mas sem botão de retry |
| Graceful degradation offline | ❌ Faltando | App quebra silenciosamente ao chamar OpenFoodFacts sem rede |
| Labels de acessibilidade (`Semantics`) | ❌ Faltando | Nenhum `Semantics` ou `Tooltip` nos botões de ação |
| Confirmação antes de ação destrutiva | ❌ Faltando | Exclusão de alimento sem `showDialog` de confirmação |
| `onBackgroundImageError` silencioso | 🟡 Parcial | Captura o erro mas callback vazio — sem log, sem fallback explícito |
| Sem `console.log` / prints em produção | ✅ OK | Sem `print()` desnecessários encontrados |

### 3.5 Testes

| Requisito | Status | Observação |
|---|---|---|
| Testes unitários de modelos/lógica | ❌ Faltando | Zero |
| Testes de widget das telas principais | ❌ Faltando | Apenas smoke test |
| Testes de integração do banco de dados | ❌ Faltando | Zero |

---

## 4. Lista priorizada do que falta

### P0 — Crítico (bloqueia usabilidade básica)

| # | Item | Onde implementar | Esforço |
|---|---|---|---|
| 1 | **Login com validação real** — aceita qualquer string atualmente | `login_screen.dart`: adicionar validação de formato e credenciais (local ou hardcoded para MVP) | Baixo |
| 2 | **Tela de Novo Paciente** — botão completamente sem ação | Nova tela `novo_paciente_screen.dart` + método `insertUsuario` já existe no DB | Médio |
| 3 | **Tela Criar Cardápio** — botão sem ação; tabela existe | Nova tela `criar_cardapio_screen.dart` que consulta `alimentos` e cria registro em `cardapios` | Médio |
| 4 | **Busca na lista de alimentos** — não há campo de busca em `lista_alimentos_screen.dart` | Adicionar `TextField` + filtro em memória ou query com `getAlimentoPorNome()` | Baixo |

### P1 — Importante (UX e consistência)

| # | Item | Onde implementar | Esforço |
|---|---|---|---|
| 5 | **Confirmação antes de deletar alimento** | `lista_alimentos_screen.dart:265` — envolver `deleteAlimento` num `showDialog` | Baixo |
| 6 | **Tela Buscar Usuários** — botão sem ação | Nova tela `buscar_usuarios_screen.dart` usando `getUsuarioPorNome()` | Baixo |
| 7 | **Tela Cardápios Salvos** — botão sem ação | Nova tela `cardapios_screen.dart` usando `getCardapiosPorUsuario()` | Baixo |
| 8 | **Conectar `consultar_screen.dart`** — tela órfã, nunca acessada | Adicionar rota no menu ou remover o arquivo | Baixo |
| 9 | **Estado de erro com retry** em `lista_alimentos_screen.dart` | `lista_alimentos_screen.dart:199` — substituir texto por botão "Tentar novamente" | Baixo |
| 10 | **Handling offline** em `novo_alimento_screen.dart` | Envolver chamada OpenFoodFacts em try/catch com mensagem amigável (parte já tem, revisar) | Baixo |

### P2 — Melhoria (arquitetura e manutenibilidade)

| # | Item | Onde implementar | Esforço |
|---|---|---|---|
| 11 | **Modelos tipados com classe Dart** em vez de `Map<String, dynamic>` | Criar `lib/models/alimento.dart`, `usuario.dart`, `cardapio.dart` | Médio |
| 12 | **Separar lógica de negócio das telas** — `novo_alimento_screen.dart` tem 820 linhas com lógica misturada | Extrair para `lib/services/alimento_service.dart` ou similar | Médio |
| 13 | **Gerenciamento de estado** (Provider ou Riverpod) | Criar providers para lista de alimentos e usuário logado | Alto |
| 14 | **Navegação declarativa** (Go Router) | Substituir `Navigator.push` por rotas nomeadas | Alto |
| 15 | **Testes unitários** para `DatabaseHelper` e lógica de mapeamento TACO→campos | `test/` — criar `alimento_test.dart`, `db_helper_test.dart` | Médio |

### P3 — Refinamento (acessibilidade e polish)

| # | Item | Onde implementar | Esforço |
|---|---|---|---|
| 16 | **Labels de acessibilidade** nos botões de ação | Envolver widgets principais em `Semantics(label: ...)` | Baixo |
| 17 | **Loading state no login** | `login_screen.dart` — adicionar `CircularProgressIndicator` durante `_login()` | Baixo |
| 18 | **Freezed para modelos imutáveis** | Requer `build_runner` — substituir classes Dart simples por `@freezed` | Alto |

---

## 5. Riscos e inconsistências

| Risco | Descrição |
|---|---|
| **`consultar_screen.dart` morta** | Arquivo existe, tem UI parcial, mas não é acessível por nenhuma rota. Será mantida ou removida? |
| **SQLite vs. Hive** | O template `.agent/` recomenda Hive; o projeto usa SQLite. SQLite é mais adequado para dados relacionais (cardápios ↔ usuários ↔ alimentos com FK), então SQLite pode ser a escolha certa — mas há divergência do padrão documentado. |
| **`Map<String, dynamic>` pervasivo** | Toda a camada de dados usa mapas brutos. Erros de chave (typo em `'proteinas'` vs `'proteínas'`) só aparecem em runtime. Risco crescente à medida que o schema evolui. |
| **Migração v3→v4 destrói dados** | `_onUpgrade` faz `DROP TABLE IF EXISTS alimentos` na migração para v4. Usuários com dados reais perdem tudo ao atualizar. Precisa de estratégia de backup/copy-on-migrate. |
| **Autenticação sem identidade** | A tabela `usuarios` existe, `cardapios` tem `usuario_id`, mas o app nunca sabe quem está logado. Cardápios criados não poderão ser atribuídos a um usuário específico até isso ser resolvido. |
| **`novo_alimento_screen.dart` com 820 linhas** | Tela "deus" com UI, lógica de negócio, parsing de JSON e chamada de API. Alto risco de regressão ao adicionar features. |

---

## Próximo passo

**Por qual lacuna você quer começar?**