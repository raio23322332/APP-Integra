import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integra_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Seleciona o primeiro tenant disponível e navega para login
  Future<void> selectFirstTenant(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final firstTenant = find.byType(ListTile).first;
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(firstTenant, findsOneWidget,
        reason: 'Nenhum tenant encontrado para selecionar.');

    await tester.tap(firstTenant);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('field_email')), findsOneWidget,
        reason: 'Não navegou para a tela de login após selecionar o tenant.');
  }

  group('Fluxo de Autenticação - Testes de Integração', () {
    testWidgets('deve realizar o login com sucesso e ser redirecionado',
        (tester) async {
      await selectFirstTenant(tester);

      await tester.enterText(
        find.byKey(const Key('field_email')),
        'user@parnaiba.localhost',
      );
      await tester.enterText(
        find.byKey(const Key('field_password')),
        'password',
      );
      await tester.pumpAndSettle();

      final loginButton = find.byKey(const Key('btn_login'));
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);

      // Maior tempo de espera após login
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Assert dinâmico: espera até o texto da Home aparecer
      final homeTitle = find.text('Destaques para você');
      bool found = false;
      for (int i = 0; i < 10; i++) {
        if (homeTitle.evaluate().isNotEmpty) {
          found = true;
          break;
        }
        await tester.pump(const Duration(seconds: 1));
      }

      expect(found, true,
          reason: 'Não foi redirecionado para a Home Page após o login.');
    });

    testWidgets('deve mostrar erro de SnackBar com credenciais inválidas',
        (tester) async {
      await selectFirstTenant(tester);

      await tester.enterText(
        find.byKey(const Key('field_email')),
        'invalido@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('field_password')),
        'senhaerrada',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_login')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(SnackBar), findsOneWidget);

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

    testWidgets('deve mostrar erro de SnackBar para campos obrigatórios',
        (tester) async {
      await selectFirstTenant(tester);

      await tester.tap(find.byKey(const Key('btn_login')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Preencha o e-mail e a senha para acessar.'),
        findsOneWidget,
      );
    });

    testWidgets('deve navegar para a tela de cadastro ao clicar no botão',
        (tester) async {
      await selectFirstTenant(tester);

      final registerButton = find.widgetWithText(ElevatedButton, 'Cadastre-se');
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Criar Conta'), findsOneWidget);
    });

    testWidgets('deve fazer logout com sucesso e voltar para tela de seleção',
        (tester) async {
      await selectFirstTenant(tester);

      await tester.enterText(
        find.byKey(const Key('field_email')),
        'user@parnaiba.localhost',
      );
      await tester.enterText(
        find.byKey(const Key('field_password')),
        'password',
      );
      await tester.tap(find.byKey(const Key('btn_login')));
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(find.text('Destaques para você'), findsOneWidget);

      final profileTab = find.byIcon(Icons.person);
      expect(profileTab, findsOneWidget);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      expect(find.text('Meu Perfil'), findsOneWidget);

      final logoutButton = find.widgetWithText(ElevatedButton, 'Sair da Conta');
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Selecione o município'), findsOneWidget);
      expect(logoutButton, findsNothing);
    });
  });
}
