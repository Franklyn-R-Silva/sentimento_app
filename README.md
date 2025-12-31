# 📱 Sentimento App

O **Sentimento App** é uma aplicação robusta desenvolvida em Flutter focada no monitoramento emocional, gestão de metas pessoais e registro de memórias. O projeto utiliza uma arquitetura moderna e escalável para proporcionar uma experiência fluida ao usuário final.

---

## 🚀 Funcionalidades Principais

O aplicativo oferece um conjunto completo de ferramentas para o bem-estar:

* **Registro de Humor**: Acompanhamento diário do estado emocional com suporte a tags e notas.
* **Diário Pessoal**: Visualização em calendário das entradas de humor e reflexões.
* **Gestão de Metas**: Sistema de check-in de hábitos e metas com anéis de progresso.
* **Fotos Anuais**: Registro de momentos especiais com localização GPS e seleção de humor.
* **Estatísticas Detalhadas**: Dashboards com gráficos de distribuição de humor e streaks de consistência.
* **Ferramentas de Apoio**: Exercícios de respiração guiados e acesso rápido a contatos de emergência.
* **Notificações**: Lembretes personalizados e notificações via Firebase Cloud Messaging.

---

## 🏗️ Arquitetura e Tecnologias

O projeto adota o padrão **MVVM (Model-View-ViewModel) Pragmático**, estruturado para facilitar a manutenção por desenvolvedores solo:

### Tecnologias Utilizadas:

* **Framework**: Flutter (SDK ^3.10.3).
* **Backend & Auth**: Supabase (Database & Realtime).
* **Notificações & Core**: Firebase (Cloud Messaging).
* **Gerência de Estado**: Provider.
* **Navegação**: GoRouter.
* **Banco de Dados Local**: Shared Preferences.

### Estrutura de Camadas:

1. **Model**: Representação imutável dos dados (ex: `lib/backend/tables`).
2. **ViewModel**: Lógica de negócio e gestão de estado da página (ex: `lib/ui/pages/.../model.dart`).
3. **View**: Interface de usuário reativa (ex: `lib/ui/pages/.../page.dart`).
4. **Service/Manager**: Singletons para serviços globais como autenticação e notificações.

---

## ⚙️ Configuração do Ambiente

### Pré-requisitos

* Flutter SDK instalado.
* Conta no Supabase e Firebase configurada.

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/Franklyn-R-Silva/sentimento_app.git

```


2. Instale as dependências:
```bash
flutter pub get

```


3. Configure as variáveis de ambiente:
* Renomeie o arquivo `.env.exemple` para `.env`.
* Preencha com suas credenciais do Supabase e Firebase.



---

## 🧪 Testes

A estratégia de testes prioriza a lógica de negócio e integrações críticas:

* **Ferramentas**: `flutter_test` e `mocktail` para simulação de dependências.
* **Execução**:
```bash
flutter test

```



---

## 🛠️ Estrutura de Pastas

* `lib/auth`: Gestão de sessão e provedores de autenticação Supabase.
* `lib/backend`: Definições de tabelas e serviços de dados.
* `lib/core`: Utilidades, temas, constantes e componentes base.
* `lib/services`: Serviços de notificação e toasts.
* `lib/ui/pages`: Páginas organizadas por funcionalidade (Home, Stats, Journal, Goals, etc).
* `lib/ui/shared`: Componentes de UI reutilizáveis.

---

## ✒️ Autor

**Franklyn R. Silva**

* Repositório: [Franklyn-R-Silva/sentimento_app](https://github.com/Franklyn-R-Silva/sentimento_app.git)
