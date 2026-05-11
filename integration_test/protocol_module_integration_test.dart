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

  group('Fluxo de Integração: Tenant → Login', () {
    testWidgets('deve selecionar tenant e fazer login', (tester) async {
      print('🏢 INÍCIO: Seleção de Tenant');
      app.main();
      
      // Aguarda inicialização completa do app
      await tester.pump(const Duration(seconds: 5));

      // Aguarda tela de seleção de tenant aparecer
      await tester.pumpUntil(
        find.text('Selecione seu município'),
        timeout: const Duration(seconds: 30),
      );
      print('✅ Tela de seleção de tenant carregada');

      // Verifica se há estado vazio (sem tenants)
      final emptyState = find.byKey(const Key('tenant_empty_state'));
      if (emptyState.evaluate().isNotEmpty) {
        print('❌ ERRO: Nenhum tenant disponível (estado vazio)');
        fail('Nenhum tenant disponível. Verifique a conexão ou a API.');
      }

      // Verifica se há estado de sem resultados de busca
      final noResultsState = find.byKey(const Key('tenant_no_search_results'));
      if (noResultsState.evaluate().isNotEmpty) {
        print('❌ ERRO: Nenhum tenant encontrado na busca');
        fail('Nenhum tenant encontrado na busca.');
      }

      // Verifica se está carregando
      await tester.pump(const Duration(seconds: 2));
      
      // Lista todos os widgets visíveis para diagnóstico
      print('🔍 DIAGNÓSTICO: Widgets visíveis na tela');
      final allWidgets = find.byType(Widget);
      final widgetCount = allWidgets.evaluate().length;
      print('📊 Total de widgets: $widgetCount');

      // Aguarda lista de tenants carregar (usa InkWell com key específica)
      await tester.pumpUntil(
        find.byType(InkWell),
        timeout: const Duration(seconds: 30),
      );
      print('✅ Lista de tenants carregada');

      final tenantList = find.byType(InkWell);
      final tenantCount = tenantList.evaluate().length;
      print('📊 Tenants disponíveis: $tenantCount');

      // Seleciona o terceiro tenant (índice 2)
      final thirdTenant = find.byType(InkWell).at(2);
      if (thirdTenant.evaluate().isNotEmpty) {
        await tester.tap(thirdTenant);
        await tester.pump();
        print('✅ Terceiro tenant selecionado');
      } else {
        // Se não houver terceiro, seleciona o primeiro
        final firstTenant = find.byType(InkWell).first;
        await tester.tap(firstTenant);
        await tester.pump();
        print('✅ Primeiro tenant selecionado (fallback)');
      }

      // ============================================
      // ETAPA 2: Login
      // ============================================
      print('🔐 ETAPA 2: Login');

      // Aguarda campos de login aparecerem
      await tester.pumpUntil(
        find.byKey(const Key('login_email_field')),
        timeout: const Duration(seconds: 15),
      );

      final emailField = find.byKey(const Key('login_email_field'));
      final passwordField = find.byKey(const Key('login_password_field'));

      await tester.enterText(emailField, 'dev@example.com');
      await tester.enterText(passwordField, 'k4hvdQ9TJ9');
      await tester.pump();

      final submitButton = find.byKey(const Key('login_submit_button'));
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump();

      // Tenta novamente se necessário
      await tester.tap(submitButton);
      await tester.pump();

      // Aguarda navegação para home (procura por "Boas-vindas!")
      await tester.pumpUntil(
        find.text('Boas-vindas!'),
        timeout: const Duration(seconds: 30),
      );

      print('✅ Login realizado com sucesso');
      print('🎉 TESTE FINALIZADO: Tenant → Login');
    });

    testWidgets('deve validar navegação tenant para login', (tester) async {
      print('🧭 TESTE: Navegação Tenant → Login');
      app.main();
      
      await tester.pump(const Duration(seconds: 5));

      await tester.pumpUntil(
        find.text('Selecione seu município'),
        timeout: const Duration(seconds: 30),
      );
      expect(find.text('Selecione seu município'), findsOneWidget);
      print('✅ Tela de tenant exibida');

      await tester.pumpUntil(
        find.byType(InkWell),
        timeout: const Duration(seconds: 30),
      );
      
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      await tester.pumpUntil(
        find.byKey(const Key('login_email_field')),
        timeout: const Duration(seconds: 15),
      );
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      print('✅ Tela de login exibida');
      print('🎉 Navegação validada');
    });

    testWidgets('deve validar seleção de múltiplos tenants', (tester) async {
      print('🎯 TESTE: Seleção de múltiplos tenants');
      app.main();
      
      await tester.pump(const Duration(seconds: 5));

      await tester.pumpUntil(
        find.text('Selecione seu município'),
        timeout: const Duration(seconds: 30),
      );

      await tester.pumpUntil(
        find.byType(InkWell),
        timeout: const Duration(seconds: 30),
      );

      final tenantCount = find.byType(InkWell).evaluate().length;
      print('📊 Tenants disponíveis: $tenantCount');
      expect(tenantCount, greaterThan(0));
      print('✅ Tenants listados corretamente');
    });
  });
}
