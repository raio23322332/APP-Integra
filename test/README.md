# Guia de Testes - Integra App

Este documento descreve a estrutura de testes implementada no aplicativo Integra.

## Estrutura de Testes

### Testes Unitários (`test/`)

Os testes unitários verificam a lógica de negócio, modelos e serviços de forma isolada.

#### Modelos (`test/models/`)
- `user_model_test.dart` - Testes do modelo User
- `tenant_model_test.dart` - Testes do modelo Tenant
- `favorite_model_test.dart` - Testes do modelo Favorite

#### Serviços (`test/services/`)
- `auth_service_test.dart` - Testes do serviço de autenticação

#### ViewModels (`test/viewmodels/`)
- `auth_viewmodel_test.dart` - Testes do AuthViewModel
- `favorite_viewmodel_test.dart` - Testes do FavoriteViewModel

#### Utilitários (`test/utils/`)
- `crypto_utils_test.dart` - Testes de funções de criptografia

### Testes de Widget (`test/widgets/` e `test/views/`)

Os testes de widget verificam a renderização e interação de componentes UI.

#### Widgets (`test/widgets/`)
- `scaffold_with_navbar_test.dart` - Testes do scaffold com navegação
- `login_status_widget_test.dart` - Testes do widget de status de login

#### Views (`test/views/`)
- `login_test.dart` - Testes da tela de login
- `favorites_screen_test.dart` - Testes da tela de favoritos

### Testes de Integração (`integration_test/`)

Os testes de integração verificam fluxos completos do aplicativo.

- `login_flow_test.dart` - Fluxo de login e logout
- `favorites_flow_test.dart` - Fluxo de gerenciamento de favoritos
- `navigation_flow_test.dart` - Fluxo de navegação entre telas

## Como Executar os Testes

### Instalar Dependências

```bash
flutter pub get
```

### Gerar Mocks (necessário para alguns testes)

```bash
flutter pub run build_runner build
```

### Executar Todos os Testes Unitários e de Widget

```bash
flutter test
```

### Executar um Teste Específico

```bash
flutter test test/models/user_model_test.dart
```

### Executar Testes com Cobertura

```bash
flutter test --coverage
```

### Visualizar Relatório de Cobertura

```bash
# Instalar lcov (Linux/Mac)
sudo apt-get install lcov  # Linux
brew install lcov          # Mac

# Gerar relatório HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
open coverage/html/index.html  # Mac
xdg-open coverage/html/index.html  # Linux
```

### Executar Testes de Integração

```bash
# Android
flutter test integration_test/login_flow_test.dart

# iOS
flutter test integration_test/login_flow_test.dart

# Chrome (web)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d chrome
```

## Estrutura de um Teste

### Teste Unitário

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/data/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    test('deve criar um User com todos os campos', () {
      // Arrange
      final user = User(
        email: 'teste@example.com',
        token: 'token123',
      );

      // Act & Assert
      expect(user.email, 'teste@example.com');
      expect(user.token, 'token123');
    });
  });
}
```

### Teste de Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/views/login.dart';

void main() {
  testWidgets('deve renderizar campos de email e senha', (tester) async {
    // Arrange & Act
    await tester.pumpWidget(MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
  });
}
```

### Teste de Integração

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integra_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('deve completar fluxo de login', (tester) async {
    // Arrange
    app.main();
    await tester.pumpAndSettle();

    // Act
    await tester.enterText(find.byType(TextField).first, 'email@test.com');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Home'), findsOneWidget);
  });
}
```

## Boas Práticas

1. **Organize os testes** seguindo a mesma estrutura do código fonte
2. **Use mocks** para isolar dependências externas
3. **Teste casos de sucesso e falha**
4. **Mantenha testes independentes** - cada teste deve poder rodar isoladamente
5. **Use nomes descritivos** - o nome do teste deve descrever o que está sendo testado
6. **Siga o padrão AAA** - Arrange, Act, Assert
7. **Evite lógica complexa** nos testes
8. **Mantenha alta cobertura** de código (meta: >80%)

## Troubleshooting

### Erro: "Mock classes not found"

Execute o build_runner para gerar os mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro: "Integration test driver not found"

Crie o arquivo `test_driver/integration_test.dart`:
```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

### Testes lentos

- Use `pumpAndSettle()` com timeout: `await tester.pumpAndSettle(Duration(seconds: 5))`
- Considere usar `pump()` em vez de `pumpAndSettle()` quando apropriado
- Execute testes em paralelo: `flutter test --concurrency=4`

## Recursos Adicionais

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Test Coverage](https://docs.flutter.dev/testing/code-coverage)
