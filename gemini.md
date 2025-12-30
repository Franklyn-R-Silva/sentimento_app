# Projeto Sentimento

Este documento serve como contexto para o assistente Gemini sobre o projeto Sentimento App.

## Visão Geral
O Sentimento App é uma aplicação Flutter para acompanhamento diário de humor e bem-estar. O app permite que usuários registrem como estão se sentindo, adicionem notas e visualizem estatísticas sobre seu humor ao longo do tempo.

## Arquitetura
O projeto segue uma arquitetura baseada em **Model-View-ViewModel (MVVM)** simplificada, combinada com o padrão **Repository/Manager** para serviços backend.

- **Views (`ui/pages/`)**: Camada de apresentação. Widgets Flutter que constroem a interface. Devem ser "burros" e apenas reagir a mudanças de estado.
- **Models (`*.model.dart`)**: Gerenciam o estado da View (`ChangeNotifier`, `FlutterFlowModel`). Contêm a lógica de UI, validação de campos e chamadas para serviços. **NÃO devem depender de BuildContext em métodos assíncronos.**
- **Managers (`auth/`, `backend/`)**: Camada de infraestrutura. Gerenciam comunicação com APIs externas (Supabase, etc). Devem retornar Objetos de Domínio ou lançar Exceções, nunca manipular UI diretamente.

## Tecnologias Principais
- **Flutter**: Framework UI.
- **Supabase**: Backend-as-a-Service (Auth, Database, Storage).
- **Provider**: Gerenciamento de estado e injeção de dependência.
- **Mocktail**: Testes unitários e mocks.

## Diretrizes de Código
1.  **Sem BuildContext em Async**: Evitar passar `BuildContext` através de gaps assíncronos. A UI deve ser responsável por mostrar feedback (Snackbars, Dialogs) baseada no resultado das operações do Model.
2.  **Tratamento de Erros**: Managers lançam exceções. Models capturam exceções e retornam estados de erro (Strings ou Enums). Views exibem o erro.
3.  **Testes**: Todos os novos componentes devem ter testes de widget. Lógica de negócios complexa deve ter testes unitários.

## Estrutura de Pastas Relevante
- `lib/ui/`: Telas e widgets.
- `lib/auth/`: Lógica de autenticação.
- `lib/backend/`: Integração com Supabase e banco de dados.
- `test/`: Testes unitários e de widget.
