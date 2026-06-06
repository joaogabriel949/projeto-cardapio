# SESSION_CONTEXT.md — NutriGo (goomer_nutri)

> Atualizado em: 2026-06-05  
> Propósito: contexto de retomada após /compact. Leia este arquivo ao iniciar nova sessão.

---

## O que é o projeto

App de gestão nutricional Android em Flutter/Dart.  
Permite cadastrar pacientes, buscar alimentos (TACO + OpenFoodFacts), criar cardápios e visualizar valores nutricionais com Nutri-Score.

**Stack atual:**
- Flutter 3 / Dart 3
- SQLite via `sqflite` (banco local, versão 4)
- `openfoodfacts` para busca externa
- Google Fonts (Manrope + Inter)
- Tema centralizado com Material Design 3
- Sem gerenciamento de estado (só `setState`)
- Sem Go Router (navegação imperativa)

---

## Estrutura de arquivos relevante

```
lib/
├── main.dart
├── theme/app_theme.dart
├── models/                         ← criados no P2
│   ├── alimento.dart
│   ├── usuario.dart
│   └── cardapio.dart
├── services/                       ← criados no P2
│   └── alimento_service.dart
├── database/
│   ├── db_helper.dart              ← Singleton SQLite, versão 4
│   └── taco_alimentos.json         ← Tabela TACO 4ª ed. (asset)
└── screens/
    ├── login_screen.dart
    ├── home_screen.dart
    ├── novo_alimento_screen.dart
    ├── lista_alimentos_screen.dart
    ├── consultar_screen.dart
    ├── novo_paciente_screen.dart
    ├── criar_cardapio_screen.dart
    ├── buscar_usuarios_screen.dart
    └── cardapios_screen.dart
```

---

## Estado atual do código

### `flutter analyze`: **0 issues** (verificado ao final do P2)

### Padrões adotados (seguir em novas telas/modificações)
- Toda operação assíncrona tem `_isLoading`, mensagem de erro e botão de retry
- Ações destrutivas sempre têm `showDialog` de confirmação
- `mounted` verificado antes de todo `setState` após `await`
- Listas usam tipos `Alimento`/`Usuario`/`Cardapio` — nunca `Map<String, dynamic>` em telas
- Erros de rede: `on SocketException` separado de `catch (e)` genérico
- `dispose()` para todos os controllers
- Sem comentários óbvios

---

## O que foi feito — histórico completo

### P0 — Concluído

| # | Arquivo | O que mudou |
|---|---|---|
| P0.1 | `login_screen.dart` | `Form` + `TextFormField` com validação, loading spinner, `dispose`, "Esqueceu a senha?" → SnackBar |
| P0.2 | `novo_paciente_screen.dart` *(novo)* | Formulário nome/data de nascimento (DatePicker)/foto, salva via `insertUsuario`, loading + erro |
| P0.3 | `criar_cardapio_screen.dart` *(novo)* | Seleciona alimento por refeição via bottom sheet com busca, vincula paciente, salva via `insertCardapio` |
| P0.4 | `lista_alimentos_screen.dart` | Busca em tempo real, estado de erro + retry, diálogo de confirmação antes de excluir |
| P0.5 | `buscar_usuarios_screen.dart` *(novo)* | Lista pacientes com busca + retry |
| P0.5 | `cardapios_screen.dart` *(novo)* | Lista cardápios com nomes via LEFT JOIN |
| P0.5 | `home_screen.dart` | Todos os 6 botões têm navegação real |
| DB | `db_helper.dart` | Adicionados `getTodosUsuarios()` e `getTodosCardapios()` (rawQuery LEFT JOIN) |

### P1 — Concluído

| # | Arquivo | O que mudou |
|---|---|---|
| P1.1 | `consultar_screen.dart` | Reescrita como StatefulWidget com dados reais do DB, busca em tempo real, kcal no chip, retry. Ícone ⚙️ no AppBar navega para `ListaAlimentosScreen` |
| P1.1 | `home_screen.dart` | "Tabela de Alimentos" agora navega para `ConsultarScreen`; `ListaAlimentosScreen` acessível pelo botão de gerenciamento dentro de `ConsultarScreen` |
| P1.2 | `novo_alimento_screen.dart` | `on SocketException` → "Sem conexão. Preencha os dados manualmente." separado de `catch (e)` genérico |

### P2 — Concluído

| # | Arquivo(s) | O que mudou |
|---|---|---|
| P2.1 | `lib/models/alimento.dart` *(novo)* | Classe `Alimento` com `fromMap`/`toMap`, todos os campos nutricionais tipados |
| P2.1 | `lib/models/usuario.dart` *(novo)* | Classe `Usuario` com `fromMap`/`toMap` |
| P2.1 | `lib/models/cardapio.dart` *(novo)* | Classe `Cardapio` com `fromMap`/`toMap`, campos de JOIN opcionais |
| P2.2 | `lib/services/alimento_service.dart` *(novo)* | `AlimentoService.buscar()` encapsula TACO + OpenFoodFacts. Retorna `ResultadoBusca`. Removido de `novo_alimento_screen.dart` |
| P2.2 | `novo_alimento_screen.dart` | 820 → ~600 linhas. Removidos imports `dart:convert`, `flutter/services`, `openfoodfacts`. Removidos `_buscarDadosDaApi` (corpo) e `_autoMapearTipo`. Delegado ao service |
| P2.1 | `consultar_screen.dart` | Usa `List<Alimento>`, `Alimento.fromMap`, `a.nome`, `a.calorias` |
| P2.1 | `lista_alimentos_screen.dart` | Usa `List<Alimento>`, `_confirmarExclusao(Alimento)`, `_mostrarDetalhesNutricionais(Alimento)` |
| P2.1 | `buscar_usuarios_screen.dart` | Usa `List<Usuario>`, `u.nome`, `u.dataNascimento` |
| P2.1 | `cardapios_screen.dart` | Usa `List<Cardapio>`, `c.cafeNome`, `c.pacienteNome` etc. |
| P2.1 | `criar_cardapio_screen.dart` | Usa `List<Alimento>` + `List<Usuario>`. Selections tipadas (`Alimento?`, `Usuario?`). Bottom sheets retornam tipos: `_SeletorAlimentoSheet` → `Alimento`, `_SeletorPacienteSheet` → `Usuario` |

---

## O que ainda falta — P3

### P3 — Refinamento (próximo a implementar — aguarda confirmação do usuário)

| # | Item | Arquivo(s) | Como fazer | Esforço |
|---|---|---|---|---|
| 1 | **Labels de acessibilidade** | Todas as telas | Envolver botões, ícones e ações em `Semantics(label: '...')`. Prioridade: botões de ação do HomeScreen, botões de excluir, chips de NutriScore | Baixo |
| 2 | **Sessão de usuário logado** | `novo_paciente_screen.dart`, `criar_cardapio_screen.dart`, `login_screen.dart` | Criar `lib/core/user_session.dart` como singleton com `int? usuarioId`. Populá-lo no login (quando houver autenticação real) ou após criar paciente. Usar em `CriarCardapioScreen` para pré-selecionar o paciente logado | Médio |
| 3 | **Testes unitários** | `test/db_helper_test.dart`, `test/alimento_service_test.dart` | Adicionar `sqflite_ffi` ao `dev_dependencies`. Testar: insert/query/delete de alimentos e usuários no DB. Testar: `AlimentoService._mapearTipo` e `Alimento.fromMap`/`toMap` | Médio |
| 4 | **Freezed para modelos** | `lib/models/*.dart` | Requer `build_runner` + `freezed` + `freezed_annotation` no `pubspec.yaml`. Substituir classes manuais por `@freezed`. Passo natural após P3.3 | Alto |

---

## Riscos conhecidos (não resolvidos)

| Risco | Detalhe | Quando resolver |
|---|---|---|
| **Migração v3→v4 destrói dados** | `_onUpgrade` em `db_helper.dart` faz `DROP TABLE alimentos` ao atualizar da v3 para v4. Usuários com dados perdem tudo | Antes de qualquer distribuição |
| **Sem sessão de usuário** | `cardapios.usuario_id` fica `null` porque não há conceito de usuário logado | P3.2 |
| **`Map<String, dynamic>` em `_valoresPor100g`** | O mapa de valores por 100g em `novo_alimento_screen.dart` e os `_unidadesDisponiveis` ainda usam `Map<String, dynamic>`. São passados do service como `List<Map<String, dynamic>>`. Não causa erros em runtime mas poderia ser tipado | P3 / futuro |

---

## Como retomar o trabalho

1. Leia este arquivo (`SESSION_CONTEXT.md`)
2. Rode `flutter analyze` — deve retornar `No issues found!`
3. Pergunte ao usuário se pode começar o **P3**

### Estrutura de pastas nova (adicionada no P2)
```
lib/models/alimento.dart   → classe Alimento
lib/models/usuario.dart    → classe Usuario
lib/models/cardapio.dart   → classe Cardapio
lib/services/alimento_service.dart → AlimentoService + ResultadoBusca
```

### Comando de verificação rápida
```powershell
flutter analyze
```
