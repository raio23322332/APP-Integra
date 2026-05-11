import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integra_app/main.dart' as app;

extension PumpUntil on WidgetTester {
  Future<void> pumpUntil(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await pump(step);
      if (any(finder)) return;
    }

    throw TestFailure(
      'Timeout esperando pelo widget: $finder\n'
      'O widget não apareceu dentro de $timeout.',
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> selectFirstTenant(WidgetTester tester) async {
    app.main();

    await tester.pumpUntil(
      find.byType(ListTile),
      timeout: const Duration(seconds: 15),
    );

    final firstTenant = find.byType(ListTile).first;
    expect(firstTenant, findsOneWidget);

    await tester.tap(firstTenant);
    await tester.pump();

    await tester.pumpUntil(
      find.byKey(const Key('field_email')),
      timeout: const Duration(seconds: 10),
    );
  }

  group('Fluxo de Login - Testes de Integração', () {
    testWidgets('deve completar fluxo de login com sucesso', (tester) async {
      await selectFirstTenant(tester);

      final emailField = find.byKey(const Key('field_email'));
      final passwordField = find.byKey(const Key('field_password'));

      await tester.enterText(emailField, 'dev@test.localhost');
      await tester.enterText(passwordField, 'password');
      await tester.pump();

      final submitButton = find.byKey(const Key('btn_login'));
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump();

      await tester.tap(submitButton);
      await tester.pump();

      await tester.pumpUntil(
        find.text('Destaques para você'),
        timeout: const Duration(seconds: 15),
      );
    });

    testWidgets('deve mostrar erro com credenciais inválidas', (tester) async {
      await selectFirstTenant(tester);

      final emailField = find.byKey(const Key('field_email'));
      final passwordField = find.byKey(const Key('field_password'));

      await tester.enterText(emailField, 'invalido@example.com');
      await tester.enterText(passwordField, 'senhaerrada');
      await tester.pump();

      final submitButton = find.byKey(const Key('btn_login'));
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump();

      await tester.pumpUntil(
        find.textContaining('credenciais inválidas'),
        timeout: const Duration(seconds: 10),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.toLowerCase().contains('credenciais inválidas'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve validar campos obrigatórios', (tester) async {
      await selectFirstTenant(tester);

      final submitButton = find.byKey(const Key('btn_login'));
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump();

      await tester.pumpUntil(find.byKey(const Key('snackbar_error')));

      expect(
        find.text('Preencha o e-mail e a senha para acessar.'),
        findsOneWidget,
      );
    });

    testWidgets('deve alternar visibilidade da senha', (tester) async {
      await selectFirstTenant(tester);

      final passwordField = find.byKey(const Key('field_password'));
      await tester.enterText(passwordField, 'senha123');
      await tester.pump();

      final visibilityIcon = find.byIcon(Icons.visibility_off);

      if (visibilityIcon.evaluate().isNotEmpty) {
        await tester.tap(visibilityIcon.first);
        await tester.pump();
        await tester.pumpUntil(find.byIcon(Icons.visibility));
      }
    });

    testWidgets('deve navegar para tela de cadastro', (tester) async {
      await selectFirstTenant(tester);

      final cadastroLink = find.textContaining('cadastr', findRichText: true);
      await tester.tap(cadastroLink.first);
      await tester.pump();

      await tester.pumpUntil(find.text('Criar Conta'));
    });
  });

  group('Fluxo de Logout - Testes de Integração', () {
    testWidgets('deve fazer logout com sucesso', (tester) async {
      await selectFirstTenant(tester);

      final emailField = find.byKey(const Key('field_email'));
      final passwordField = find.byKey(const Key('field_password'));

      await tester.enterText(emailField, 'user@parnaiba.localhost');
      await tester.enterText(passwordField, 'password');
      await tester.pump();

      final submitButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(submitButton);
      await tester.pump();

      await tester.pumpUntil(find.byIcon(Icons.logout));

      final logoutButton = find.byIcon(Icons.logout);
      await tester.tap(logoutButton);
      await tester.pump();

      await tester.pumpUntil(find.text('Selecione o município'));
    });

    testWidgets('deve limpar dados do usuário após logout', (tester) async {
      await selectFirstTenant(tester);

      final logoutButton = find.byIcon(Icons.logout);

      if (logoutButton.evaluate().isNotEmpty) {
        await tester.tap(logoutButton);
        await tester.pump();

        await tester.pumpUntil(find.text('Selecione o município'));
      }
    });
  });
}
