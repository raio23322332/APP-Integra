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

  Future<void> pumpUntilAny(
    List<Finder> finders, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await pump(step);
      for (final finder in finders) {
        if (any(finder)) return;
      }
    }

    throw TestFailure(
      'Timeout esperando por qualquer um dos widgets: $finders\n'
      'Nenhum apareceu dentro de $timeout.',
    );
  }
}

Future<void> startAppAndSelectTenant(WidgetTester tester) async {
  app.main();
  await tester.pump();

  await tester.pumpUntilAny(
    [
      find.text('Selecione seu município'),
      find.text('Selecione o município'),
      find.byKey(const Key('tenant_select_scaffold')),
    ],
    timeout: const Duration(seconds: 30),
  );

  final tenantCards = find.byType(InkWell);
  await tester.pumpUntil(
    tenantCards,
    timeout: const Duration(seconds: 30),
  );

  final tenantCount = tenantCards.evaluate().length;
  if (tenantCount == 0) {
    fail('Nenhum tenant disponível para seleção.');
  }

  final tenantToSelect = tenantCount >= 3 ? tenantCards.at(2) : tenantCards.first;
  await tester.tap(tenantToSelect);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.byKey(const Key('login_email_field')),
    timeout: const Duration(seconds: 30),
  );
}

Future<void> loginCredentials(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  await tester.pumpAndSettle();

  // Faz scroll até o botão de submit estar visível
  await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
  await tester.pumpAndSettle();

  final submitButton = find.byKey(const Key('login_submit_button'));
  expect(submitButton, findsOneWidget);
  await tester.tap(submitButton, warnIfMissed: false);
  await tester.pumpAndSettle();

  // Aguarda navegação para tela principal (botão de perfil deve aparecer)
  await tester.pumpUntil(
    find.byKey(const Key('nav_profile')),
    timeout: const Duration(seconds: 30),
  );
}

Future<void> openProtocolsFromProfile(WidgetTester tester) async {
  final profileNav = find.byKey(const Key('nav_profile'));
  expect(profileNav, findsOneWidget);
  await tester.tap(profileNav);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.text('Meus Protocolos'),
    timeout: const Duration(seconds: 30),
  );
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();

  // Adicionar log para verificar se a navegação ocorreu
  print('Navegando para protocolos...');
  await tester.pump(const Duration(seconds: 2));

  // Verificar se há algum scaffold na tela
  final scaffolds = find.byType(Scaffold);
  print('Número de scaffolds encontrados: ${scaffolds.evaluate().length}');

  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
}

Future<void> openCreateProtocolScreen(WidgetTester tester) async {
  final fab = find.byType(FloatingActionButton);
  await tester.pumpUntil(
    fab,
    timeout: const Duration(seconds: 30),
  );

  expect(fab, findsOneWidget);
  await tester.tap(fab);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.byKey(const Key('create_protocol_scaffold')),
    timeout: const Duration(seconds: 30),
  );
}

Future<void> fillAndSubmitProtocolForm(WidgetTester tester) async {
  // Aguarda o dropdown de setor carregar
  await tester.pumpUntil(
    find.byKey(const Key('create_protocol_sector_dropdown')),
    timeout: const Duration(seconds: 30),
  );

  // Seleciona o primeiro setor disponível
  final sectorDropdown = find.byKey(const Key('create_protocol_sector_dropdown'));
  await tester.tap(sectorDropdown);
  await tester.pumpAndSettle();
  
  // Aguarda os itens do dropdown aparecerem
  await tester.pumpUntil(
    find.byType(DropdownMenuItem<String>),
    timeout: const Duration(seconds: 5),
  );
  
  // Tenta encontrar e clicar no primeiro DropdownMenuItem pela key
  // As keys são geradas como 'sector_item_{id}', mas não sabemos o ID
  // Então vamos tentar clicar no primeiro item visível do menu
  final menuItems = find.byType(DropdownMenuItem<String>);
  final itemCount = menuItems.evaluate().length;
  print('📊 Itens do dropdown encontrados: $itemCount');
  
  if (itemCount > 0) {
    // Tenta clicar no primeiro item
    try {
      await tester.tap(menuItems.first);
      await tester.pumpAndSettle();
      print('✅ Setor selecionado com sucesso');
    } catch (e) {
      print('❌ Erro ao selecionar setor: $e');
      // Fallback: tenta clicar no texto do primeiro item
      final firstText = find.byType(Text).at(2); // Pula label e hint
      try {
        await tester.tap(firstText);
        await tester.pumpAndSettle();
        print('✅ Setor selecionado via texto');
      } catch (e2) {
        print('❌ Erro ao selecionar via texto: $e2');
        fail('Não foi possível selecionar o setor. O teste não pode continuar.');
      }
    }
  } else {
    fail('Nenhum item de setor encontrado no dropdown. Verifique se os setores estão carregados.');
  }
  
  // Valida que o dropdown ainda está fechado (indica que seleção funcionou)
  await tester.pump(const Duration(milliseconds: 500));
  final dropdownStillOpen = find.byType(DropdownMenuItem<String>).evaluate().isNotEmpty;
  if (dropdownStillOpen) {
    print('⚠️ Dropdown ainda aberto após seleção, tentando fechar');
    await tester.tap(find.byKey(const Key('create_protocol_sector_dropdown')));
    await tester.pumpAndSettle();
  }

  // Preenche o tipo de documento
  final docTypeField = find.byKey(const Key('create_protocol_document_type_field'));
  print('📝 Campo tipo de documento encontrado: ${docTypeField.evaluate().isNotEmpty}');
  await tester.enterText(docTypeField, 'Requerimento Teste');
  await tester.pumpAndSettle();
  print('✅ Tipo de documento preenchido');

  // Preenche o assunto
  final subjectField = find.byKey(const Key('create_protocol_subject_field'));
  print('📝 Campo assunto encontrado: ${subjectField.evaluate().isNotEmpty}');
  await tester.enterText(subjectField, 'Assunto de teste para criação de protocolo');
  await tester.pumpAndSettle();
  print('✅ Assunto preenchido');

  // Preenche observações (opcional)
  final notesField = find.byKey(const Key('create_protocol_notes_field'));
  print('📝 Campo observações encontrado: ${notesField.evaluate().isNotEmpty}');
  await tester.enterText(notesField, 'Observações de teste');
  await tester.pumpAndSettle();
  print('✅ Observações preenchidas');

  // Valida que todos os campos obrigatórios estão presentes
  expect(find.byKey(const Key('create_protocol_direction_dropdown')), findsOneWidget);
  expect(find.byKey(const Key('create_protocol_main_fields_card')), findsOneWidget);
  expect(find.byKey(const Key('create_protocol_origin_card')), findsOneWidget);
  expect(find.byKey(const Key('create_protocol_classification_card')), findsOneWidget);

  // Faz scroll até o botão de submit estar visível
  await tester.ensureVisible(find.byKey(const Key('create_protocol_submit_button')));
  await tester.pumpAndSettle();
  
  // Scroll adicional para garantir que o botão esteja completamente visível
  await tester.drag(find.byKey(const Key('create_protocol_scroll')), Offset(0, 300));
  await tester.pumpAndSettle();

  // Submete o formulário
  final submitButton = find.byKey(const Key('create_protocol_submit_button'));
  expect(submitButton, findsOneWidget);
  await tester.tap(submitButton, warnIfMissed: false);
  await tester.pumpAndSettle();

  // Aguarda o sucesso (retorna para a lista de protocolos)
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Protocolo', () {
    testWidgets('deve navegar para Protocolos e abrir criação de protocolo',
        (tester) async {
      await startAppAndSelectTenant(tester);
      await loginCredentials(
        tester,
        email: 'dev@example.com',
        password: 'k4hvdQ9TJ9',
      );

      await openProtocolsFromProfile(tester);

      // Verificar se a tela carregou corretamente - pode estar carregando, vazia ou com protocolos
      final isLoading = find.text('Carregando protocolos...').evaluate().isNotEmpty;
      final isEmpty = find.text('Nenhum protocolo encontrado').evaluate().isNotEmpty;
      final hasProtocols = find.byType(ListView).evaluate().isNotEmpty;

      expect(isLoading || isEmpty || hasProtocols, isTrue,
          reason: 'A tela de Protocolos deve estar carregando, vazia ou exibindo protocolos.');

      await openCreateProtocolScreen(tester);

      // Valida todos os widgets da tela de criação
      expect(find.byKey(const Key('create_protocol_scaffold')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_scroll')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_sector_consumer')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_sector_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_main_fields_card')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_direction_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_document_type_field')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_subject_field')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_notes_field')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_origin_card')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_origin_protocol_field')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_origin_agency_field')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_classification_card')), findsOneWidget);
      expect(find.byKey(const Key('create_protocol_submit_button')), findsOneWidget);

      // Preenche e submete o formulário
      await fillAndSubmitProtocolForm(tester);

      // Valida que retornou para a lista de protocolos após criação
      expect(find.byKey(const Key('protocol_list_scaffold')), findsOneWidget);
    });
  });
}
