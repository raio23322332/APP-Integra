# Projeto APP-Integra (Atualizado)

Este projeto Flutter foi atualizado para incluir a funcionalidade de login com a API do Larva, persistência do token de acesso e dados do usuário via `sqflite`, e configuração de acesso.

## Funcionalidades Implementadas

*   **Login com API:** A lógica de login foi implementada no `AuthService` para consumir uma API externa.
*   **Persistência de Credenciais:** O token de acesso e os dados do usuário (e-mail, nome, CPF) são salvos no banco de dados local (`sqflite`) após o login.
*   **Controle de Acesso:** O `AuthViewModel` gerencia o estado de autenticação e o `AppRouter` redireciona o usuário para a tela inicial se estiver logado, ou para a tela de login se não estiver.
*   **Logout:** A função de logout remove as credenciais do banco de dados local.

## ⚠️ Ponto de Atenção: URL da API do Larva

A URL da API do Larva não foi fornecida. Por isso, foi utilizado um **placeholder** no arquivo `lib/services/auth_service.dart`.

**Para que o login funcione, você deve substituir a variável `_baseUrl` pela URL real da sua API:**

```dart
// lib/services/auth_service.dart

class AuthService {
  // ⚠️ SUBSTITUA ESTA URL PELA URL BASE REAL DA SUA API DO LARVA
  static const String _baseUrl = 'https://api.larva.com.br/v1'; 
  static const String _loginEndpoint = '/auth/login';
  // ...
}
```

## Como Rodar o Projeto

1.  **Instale o Flutter:** Certifique-se de ter o Flutter SDK instalado e configurado em sua máquina.
2.  **Navegue até o diretório do projeto:**
    ```bash
    cd /caminho/para/APP-Integra
    ```
3.  **Obtenha as dependências:**
    ```bash
    flutter pub get
    ```
4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

## Teste de Login (Simulação)

Como a API real não está conectada, o login falhará até que a URL seja configurada.

**Para testar a arquitetura:**

1.  Substitua a lógica de requisição no `AuthService` por uma **simulação de sucesso** que retorne um token e dados de usuário fictícios.
2.  Após a substituição, tente fazer o login. Você deve ser redirecionado para a tela inicial e seus dados (fictícios) devem aparecer na tela de perfil.

**Exemplo de Simulação de Sucesso no `lib/services/auth_service.dart`:**

```dart
// lib/services/auth_service.dart

// ... dentro da função login ...

// Simulação de sucesso (REMOVER APÓS CONECTAR A API REAL)
if (email == 'teste@teste.com' && password == '123456') {
  return {
    'success': true,
    'token': 'seu_token_de_acesso_simulado_12345',
    'user': {
      'name': 'Usuário Teste',
      'cpf': '123.456.789-00',
    },
  };
}

// ... o restante da lógica de requisição real ...
```

Ao configurar a URL e a resposta da API, o projeto estará pronto para uso.
