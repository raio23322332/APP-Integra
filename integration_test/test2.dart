import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integra_app/main.dart' as app;

/// Extensão utilitária para aguardar até que um widget apareça na tela.
extension PumpUntilExtension on WidgetTester {
  Future<void> pumpUntil(
    Finder finder, {
    Duration timeout = const Duration(seconds: 15),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await pump(step);
      if (any(finder)) return;
    }

    throw TestFailure('Widget não apareceu dentro de $timeout ---> $finder');
  }
}

/// Seleciona o primeiro tenant da lista
Future<void> selectFirstTenant(WidgetTester tester) async {
  // Roda o app REAL (com main.dart)
  app.main();
  await tester.pump();
  
  // Espera carregar tenants
  await tester.pumpUntil(find.byType(ListTile));

  final firstTenant = find.byType(ListTile).first;
  expect(firstTenant, findsOneWidget);

  await tester.tap(firstTenant);
  await tester.pump();

  // Espera tela de Login
  await tester.pumpUntil(find.byKey(const Key('field_email')));
}

/// Faz o fluxo de login completo
Future<void> performLogin(WidgetTester tester) async {
  await selectFirstTenant(tester);

  final emailField = find.byKey(const Key('field_email'));
  final passwordField = find.byKey(const Key('field_password'));

  await tester.enterText(emailField, 'dev@test.localhost');
  await tester.enterText(passwordField, 'password');
  await tester.pump();

  final submitButton = find.byKey(const Key('btn_login'));
  await tester.tap(submitButton);
  await tester.pump();

  await tester.tap(submitButton); // segunda tentativa se houver validação
  await tester.pump();

  // Espera a home renderizar
  await tester.pumpUntil(find.text('Destaques para você'));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxos principais do app', () {
    testWidgets('Fluxo de Login funciona', (tester) async {
      await performLogin(tester);

      expect(find.text('Destaques para você'), findsOneWidget);
    });

    testWidgets('Fluxo de categorias → serviço → detalhes', (tester) async {
      await performLogin(tester);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Categorias'), findsOneWidget);

      final category = find.text('Categoria Teste 1');
      expect(category, findsOneWidget);
      await tester.tap(category);
      await tester.pumpAndSettle();

      expect(find.text('Serviços de Categoria Teste 1'), findsOneWidget);

      final servico = find.text('Serviço 1');
      expect(servico, findsOneWidget);
      await tester.tap(servico);
      await tester.pumpAndSettle();

      expect(find.text('Serviço 1'), findsOneWidget);
    });
  });
}
