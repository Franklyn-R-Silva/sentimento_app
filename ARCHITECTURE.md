# Arquitetura e Guia de Testes 🏗️

Este documento descreve o padrão de projeto e a estratégia de testes adotada para o **Sentimento App**, focada em produtividade para um desenvolvedor solo.

## Padrão de Projeto: MVVM Pragmático

Para um projeto solo, precisamos de um equilíbrio entre organização e velocidade. O padrão escolhido é o **MVVM (Model-View-ViewModel)** adaptado:

### 1. Camadas
- **Model (lib/backend/tables)**: Classes que representam os dados (ex: `EntradasHumorRow`). São imutáveis e simples.
- **Service/Manager (lib/auth, lib/backend)**: Singletons que gerenciam lógica global e persistente (ex: `SupabaseAuthManager`). Não guardam estado do UI.
- **ViewModel (lib/ui/pages/.../model.dart)**: Gerencia o estado e a lógica de uma página específica. Estende `ChangeNotifier` para notificar a View.
- **View (lib/ui/pages/.../page.dart)**: Apenas UI. Escuta o ViewModel através do `Provider` e delega ações.

### 2. Estrutura de Pastas
- `lib/core`: Utilidades, temas e GPS.
- `lib/auth`: Tudo relacionado a login e sessão.
- `lib/backend`: Conexão com Supabase e definições de tabelas.
- `lib/ui/shared`: Componentes reutilizáveis (botões, cards, menus).
- `lib/ui/pages`: Páginas organizadas por funcionalidade, contendo a View e seu ViewModel.

---

## Estratégia de Testes 🧪

Como você trabalha sozinho, os testes devem focar no que mais "quebra" e no que é mais difícil de testar manualmente.

### Prioridade de Testes
1.  **Lógica de Negócio (ViewModels)**: Garantir que cálculos de humor, streaks e validações funcionem.
2.  **Integração (Auth & API)**: Garantir que a comunicação com o Supabase está correta.
3.  **UI Crítica**: Testar fluxos principais como login e cadastro de sentimento.

### Ferramentas
- `flutter_test`: Framework padrão.
- `mocktail`: Para simular (mock) dependências como o Supabase e GPS sem precisar de internet.

### Como Rodar os Testes
Use o comando no terminal:
```bash
flutter test
```

---

## Dicas para o Desenvolvedor Solo ⚡
- **Fail Fast**: Se algo mudar na API do Supabase, seus testes de ViewModel devem pegar o erro antes de você subir o app.
- **Mantenha a View "Burra"**: Se você precisar de um `if` complexo na View, mova para uma função no ViewModel. Isso facilita o teste.
- **Use Mocktail**: Sempre que um teste precisar de internet, use um Mock. Isso deixa os testes rápidos e confiáveis.
