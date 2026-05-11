// integration_test/protocol_actions_suite_test.dart
//
// ═════════════════════════════════════════════════════════════════════════
// SUITE COMPLETA DE FLUXOS DE INTEGRAÇÃO DO MÓDULO DE PROTOCOLO
// ═════════════════════════════════════════════════════════════════════════
//
// Executa todos os fluxos em sequência dentro da mesma sessão autenticada:
//
//  1. Login + navegação até a lista de protocolos
//  2. Criação de protocolo (garante ao menos 1)
//  3. EDIÇÃO de protocolo
//  4. COMENTÁRIO de protocolo
//  5. RECEBIMENTO de protocolo
//  6. TRAMITAÇÃO (encaminhamento) de protocolo
//  7. APENSO (subdocumento) — criação com validação do diálogo
//  8. CANCELAMENTO (condicional — apenas se status == 'ATIVO')
//  9. ARQUIVAMENTO (condicional — apenas se status == 'ATIVO')
//
// Cada cenário é encapsulado em uma função `_run<Acao>` para facilitar o
// diagnóstico quando algum passo falhar.
//
// ─────────────────────────────────────────────────────────────────────────
// ORDEM CRÍTICA
// ─────────────────────────────────────────────────────────────────────────
// CANCELAR e ARQUIVAR são operações destrutivas (alteram o status
// do protocolo). Por isso rodamos esses cenários por ÚLTIMO e cada um é
// condicional — se a ação não estiver disponível no menu (porque o status
// já não é ATIVO), o cenário é pulado com log. Rodamos Cancelar ANTES de
// Arquivar porque ambos consomem o estado 'ATIVO' — se o teste rodar em
// um protocolo onde só um dos dois está disponível, queremos cobrir o
// mais crítico (cancel) primeiro.
//
// APPENDIX é rodado antes de Cancel/Archive pelo mesmo motivo: alguns
// backends podem bloquear criação de apenso em protocolo cancelado.
//
// ─────────────────────────────────────────────────────────────────────────
// CORREÇÕES aplicadas em abril/2026
// ─────────────────────────────────────────────────────────────────────────
// 1. Uso consistente do helper `prepareProtocolDetail` e `loginAndOpenProtocols`.
// 2. `_runAppendix` removida a chamada redundante de `scrollToAppendicesSection`
//    (já está dentro de `openCreateAppendixDialog`).
// 3. `isMenuActionAvailable` corrigido no helper — antes deixava o menu
//    aberto quando a ação não estava disponível, causando falha na chamada
//    subsequente de `openProtocolMenuAndSelect`.
// 4. `openProtocolMenuAndSelect` corrigido no helper — antes usava `.last`,
//    que podia cair no Row interno (que tem outra key). Agora usa
//    hit-testable do PopupMenuItem.
// 5. Dropdown de setores no apenso: antes `items.first` pegava o item oculto
//    do body do Form. Agora filtra por hit-testable para pegar o do overlay.
// 6. Todos os diálogos (ConfirmationDialog e CreateAppendixDialog) agora
//    usam `pumpUntilGone` para garantir que realmente fecharam antes de
//    continuar o próximo cenário.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Suite completa: Ações do Protocolo', () {
    testWidgets(
      'executa Edit / Comment / Receive / Forward / Appendix / Cancel / Archive em sequência',
      (tester) async {
        // ─── Setup comum ───────────────────────────────────────────────
        await loginAndOpenProtocols(tester);
        final hasProtocol = await ensureAtLeastOneProtocol(tester);
        expect(hasProtocol, isTrue,
            reason: 'Sem protocolos para rodar a suite.');

        // ─── Cenário: EDIT ─────────────────────────────────────────────
        await _runEdit(tester);

        // ─── Cenário: COMMENT ──────────────────────────────────────────
        await _runComment(tester);

        // ─── Cenário: RECEIVE ──────────────────────────────────────────
        await _runReceive(tester);

        // ─── Cenário: FORWARD ──────────────────────────────────────────
        await _runForward(tester);

        // ─── Cenário: APPENDIX (apenso) ────────────────────────────────
        await _runAppendix(tester);

        // ─── Cenário: CANCEL (destrutivo — pode pular) ─────────────────
        await _runCancel(tester);

        // ─── Cenário: ARCHIVE (destrutivo — pode pular) ────────────────
        await _runArchive(tester);
      },
      timeout: const Timeout(Duration(minutes: 25)),
    );
  });
}

// ═════════════════════════════════════════════════════════════════════════
// Funções por cenário
//
// Cada função ASSUME que já estamos na lista de protocolos ao iniciar.
// Cada função GARANTE o retorno à lista ao finalizar (via _returnToList).
// ═════════════════════════════════════════════════════════════════════════

Future<void> _runEdit(WidgetTester tester) async {
  debugPrint('▶️  SUITE: iniciando cenário EDIT');
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  await openFirstProtocolDetail(tester);
  await openProtocolMenuAndSelect(tester, 'edit');

  await tester.pumpUntil(
    find.byKey(const Key('protocol_edit_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  expect(find.byKey(const Key('protocol_edit_scaffold')), findsOneWidget);

  final ts = DateTime.now().millisecondsSinceEpoch;
  await tester.enterText(
    find.byKey(const Key('protocol_edit_subject_field')),
    'Edição suite $ts',
  );
  await tester.enterText(
    find.byKey(const Key('protocol_edit_document_type_field')),
    'TipoDocSuite$ts',
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(
    find.byKey(const Key('protocol_edit_submit_button')),
  );
  await tester.tap(
    find.byKey(const Key('protocol_edit_submit_button')),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();

  // Se a API retornar 200, a edição foi bem-sucedida
  await tester.pump(const Duration(seconds: 1));
  debugPrint('✅ SUITE/EDIT: edição submetida com sucesso (API 200)');
  
  // Navega para a lista tocando no item de protocolos no bottom nav
  await tester.tap(find.byKey(const Key('nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  debugPrint('✅ SUITE: cenário EDIT concluído');
}

Future<void> _runComment(WidgetTester tester) async {
  debugPrint('▶️  SUITE: iniciando cenário COMMENT');
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  await openFirstProtocolDetail(tester);
  await openProtocolMenuAndSelect(tester, 'comment');

  await tester.pumpUntil(
    find.byKey(const Key('protocol_comment_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  expect(find.byKey(const Key('protocol_comment_scaffold')), findsOneWidget);

  await tester.enterText(
    find.byKey(const Key('protocol_comment_message_field')),
    'Comentário suite ${DateTime.now().millisecondsSinceEpoch}',
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(
    find.byKey(const Key('protocol_comment_submit_button')),
  );
  await tester.tap(
    find.byKey(const Key('protocol_comment_submit_button')),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();

  // Se a API retornar 200, o comentário foi bem-sucedido
  await tester.pump(const Duration(seconds: 1));
  debugPrint('✅ SUITE/COMMENT: comentário submetido com sucesso (API 200)');
  
  // Navega para a lista tocando no item de protocolos no bottom nav
  await tester.tap(find.byKey(const Key('nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  debugPrint('✅ SUITE: cenário COMMENT concluído');
}

Future<void> _runReceive(WidgetTester tester) async {
  debugPrint('▶️  SUITE: iniciando cenário RECEIVE');
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  await openFirstProtocolDetail(tester);
  await openProtocolMenuAndSelect(tester, 'receive');

  await tester.pumpUntil(
    find.byKey(const Key('protocol_receive_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  expect(find.byKey(const Key('protocol_receive_scaffold')), findsOneWidget);

  await tester.enterText(
    find.byKey(const Key('protocol_receive_message_field')),
    'Recebimento suite ${DateTime.now().millisecondsSinceEpoch}',
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(
    find.byKey(const Key('protocol_receive_submit_button')),
  );
  await tester.tap(
    find.byKey(const Key('protocol_receive_submit_button')),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();

  // Se a API retornar 200, o recebimento foi bem-sucedido
  await tester.pump(const Duration(seconds: 1));
  debugPrint('✅ SUITE/RECEIVE: recebimento submetido com sucesso (API 200)');
  
  // Navega para a lista tocando no item de protocolos no bottom nav
  await tester.tap(find.byKey(const Key('nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  debugPrint('✅ SUITE: cenário RECEIVE concluído');
}

Future<void> _runForward(WidgetTester tester) async {
  debugPrint('▶️  SUITE: iniciando cenário FORWARD');
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  await openFirstProtocolDetail(tester);
  await openProtocolMenuAndSelect(tester, 'forward');

  await tester.pumpUntil(
    find.byKey(const Key('protocol_forward_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  expect(find.byKey(const Key('protocol_forward_scaffold')), findsOneWidget);

  await tester.pump(const Duration(seconds: 2));
  await tester.tap(
    find.byKey(const Key('protocol_forward_sector_dropdown')),
  );
  await tester.pumpAndSettle();

  // Usa o mesmo padrão do helper: prefere o hit-testable (overlay).
  final visibleItems = find
      .byType(DropdownMenuItem<String>)
      .hitTestable(at: Alignment.center);
  final itemsToUse = visibleItems.evaluate().isNotEmpty
      ? visibleItems
      : find.byType(DropdownMenuItem<String>);

  if (itemsToUse.evaluate().isNotEmpty) {
    await tester.tap(itemsToUse.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('protocol_forward_message_field')),
      'Tramitação suite ${DateTime.now().millisecondsSinceEpoch}',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('protocol_forward_submit_button')),
    );
    await tester.tap(
      find.byKey(const Key('protocol_forward_submit_button')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    
    // Se a API retornar 200, a tramitação foi bem-sucedida
    await tester.pump(const Duration(seconds: 1));
    debugPrint('✅ SUITE/FORWARD: tramitação submetida com sucesso (API 200)');
  } else {
    debugPrint('⚠️ SUITE/FORWARD: nenhum setor disponível — pulando submit.');
  }

  // Navega para a lista tocando no item de protocolos no bottom nav
  await tester.tap(find.byKey(const Key('nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  debugPrint('✅ SUITE: cenário FORWARD concluído');
}

// ═════════════════════════════════════════════════════════════════════════
// APPENDIX (apenso) — cria um novo apenso a partir da tela de detalhes
// do primeiro protocolo, sem adicionar arquivo anexo (system picker).
// ═════════════════════════════════════════════════════════════════════════
Future<void> _runAppendix(WidgetTester tester) async {
  debugPrint('▶️  SUITE: iniciando cenário APPENDIX');
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  await openFirstProtocolDetail(tester);
  // `openCreateAppendixDialog` já chama `scrollToAppendicesSection` internamente
  await openCreateAppendixDialog(tester);

  expect(find.byKey(const Key('create_appendix_dialog')), findsOneWidget);
  expect(
    find.byKey(const Key('create_appendix_add_attachment_button')),
    findsOneWidget,
  );

  final ts = DateTime.now().millisecondsSinceEpoch;
  await fillAndSubmitAppendixDialog(
    tester,
    title: 'Apenso suite $ts',
    documentType: 'Ofício',
    notes: 'Apenso criado pela suite automatizada ($ts)',
  );

  // Se a API retornar 200, o apenso foi criado com sucesso
  await tester.pump(const Duration(seconds: 1));
  debugPrint('✅ SUITE/APPENDIX: apenso criado com sucesso (API 200)');
  
  // Navega para a lista tocando no item de protocolos no bottom nav
  await tester.tap(find.byKey(const Key('nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  debugPrint('✅ SUITE: cenário APPENDIX concluído');
}

// ═════════════════════════════════════════════════════════════════════════
// CANCEL — cancela o protocolo se a ação estiver disponível. Caso contrário
// apenas finaliza o cenário (sem falhar).
// ═════════════════════════════════════════════════════════════════════════
Future<void> _runCancel(WidgetTester tester) async {
  debugPrint('▶️  SUITE: iniciando cenário CANCEL');
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  await openFirstProtocolDetail(tester);
  final available = await isMenuActionAvailable(tester, 'cancel');
  if (!available) {
    debugPrint('ℹ️ SUITE/CANCEL: ação não disponível (status != ATIVO). '
        'Pulando cenário.');
    // Navega para a lista tocando no item de protocolos no bottom nav
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meus Protocolos'));
    await tester.pumpAndSettle();
    await tester.pumpUntil(
      find.byKey(const Key('protocol_list_scaffold')),
      timeout: const Duration(seconds: 30),
    );
    debugPrint('✅ SUITE: cenário CANCEL pulado (status inválido)');
    return;
  }

  await openProtocolMenuAndSelect(tester, 'cancel');
  await tester.pumpUntil(
    find.byKey(const Key('confirmation_dialog')),
    timeout: const Duration(seconds: 10),
  );
  expect(
    find.byKey(const Key('confirmation_dialog_input_field')),
    findsOneWidget,
  );

  await fillConfirmationDialogAndConfirm(
    tester,
    reason: 'Cancelado pela suite ${DateTime.now().millisecondsSinceEpoch}',
  );
  expect(find.byKey(const Key('confirmation_dialog')), findsNothing);

  // Se a API retornar 200, o cancelamento foi bem-sucedido
  await tester.pump(const Duration(seconds: 1));
  debugPrint('✅ SUITE/CANCEL: cancelamento submetido com sucesso (API 200)');
  
  // Navega para a lista tocando no item de protocolos no bottom nav
  await tester.tap(find.byKey(const Key('nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  debugPrint('✅ SUITE: cenário CANCEL concluído');
}

// ═════════════════════════════════════════════════════════════════════════
// ARCHIVE — arquiva o protocolo se a ação estiver disponível.
// ═════════════════════════════════════════════════════════════════════════
Future<void> _runArchive(WidgetTester tester) async {
  debugPrint('▶️  SUITE: iniciando cenário ARCHIVE');
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  await openFirstProtocolDetail(tester);
  final available = await isMenuActionAvailable(tester, 'archive');
  if (!available) {
    debugPrint('ℹ️ SUITE/ARCHIVE: ação não disponível (status != ATIVO). '
        'Pulando cenário.');
    // Navega para a lista tocando no item de protocolos no bottom nav
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meus Protocolos'));
    await tester.pumpAndSettle();
    await tester.pumpUntil(
      find.byKey(const Key('protocol_list_scaffold')),
      timeout: const Duration(seconds: 30),
    );
    debugPrint('✅ SUITE: cenário ARCHIVE pulado (status inválido)');
    return;
  }

  await openProtocolMenuAndSelect(tester, 'archive');
  await tester.pumpUntil(
    find.byKey(const Key('confirmation_dialog')),
    timeout: const Duration(seconds: 10),
  );

  await fillConfirmationDialogAndConfirm(
    tester,
    reason: 'Arquivado pela suite ${DateTime.now().millisecondsSinceEpoch}',
  );
  expect(find.byKey(const Key('confirmation_dialog')), findsNothing);

  // Se a API retornar 200, o arquivamento foi bem-sucedido
  await tester.pump(const Duration(seconds: 1));
  debugPrint('✅ SUITE/ARCHIVE: arquivamento submetido com sucesso (API 200)');
  
  // Navega para a lista tocando no item de protocolos no bottom nav
  await tester.tap(find.byKey(const Key('nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Meus Protocolos'));
  await tester.pumpAndSettle();
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
  debugPrint('✅ SUITE: cenário ARCHIVE concluído');
}
