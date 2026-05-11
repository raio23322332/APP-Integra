// integration_test/helpers/protocol_test_helpers.dart
//
// Helpers compartilhados para os testes de integração do módulo de Protocolo.
//
// Centraliza lógica de:
//   - Start do app + seleção de tenant
//   - Login com credenciais de teste
//   - Navegação até a lista de protocolos
//   - Abertura da tela de criação de protocolo
//   - Preenchimento e envio do formulário de criação
//   - Abertura do primeiro protocolo existente (detalhe)
//   - Abertura do menu de ações (ProtocolMenuWidget) e seleção de ação
//   - Interação com ConfirmationDialog (cancelar/arquivar)
//   - Interação com CreateAppendixDialog (apenso)
//
// ─────────────────────────────────────────────────────────────────────────
// HISTÓRICO DE CORREÇÕES (abril/2026):
//
// 1. isMenuActionAvailable: antes NÃO fechava o menu quando a ação não
//    estava disponível → deixava o PopupMenu aberto e quebrava o teste
//    seguinte. Agora SEMPRE fecha o menu.
//
// 2. openProtocolMenuAndSelect: antes usava `.last` do finder de key
//    'protocol_menu_item_$action'. Como no código de produção existe tanto
//    `Key('protocol_menu_item_$value')` no PopupMenuItem quanto
//    `Key('protocol_menu_item_row_$value')` no Row interno, o `.last` podia
//    cair no Row (que não recebe o tap corretamente). Agora usamos o finder
//    exato do PopupMenuItem (`.first` após filtrar por hit-testable).
//
// 3. fillAndSubmitAppendixDialog: antes usava `items.first` para selecionar
//    um setor. O DropdownButtonFormField expõe os items tanto no body
//    oculto quanto no overlay, e `.first` acabava pegando o item oculto.
//    Agora filtramos por `hitTestable()` e pegamos o primeiro visível.
//
// 4. ensureVisible num dropdown dentro de Expanded/SingleChildScrollView é
//    frágil. Trocado por scroll manual dentro do dialog.
//
// 5. Novos wrappers `loginAndOpenProtocols` e `prepareProtocolDetail` para
//    reduzir duplicação nos testes.
// ─────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/main.dart' as app;

extension PumpUntil on WidgetTester {
  /// Aguarda até que o [finder] retorne pelo menos 1 elemento ou até atingir
  /// [timeout]. Lança [TestFailure] em caso de timeout.
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

  /// Aguarda até que QUALQUER um dos [finders] encontre um widget ou atinja
  /// [timeout]. Útil quando a UI pode estar em diferentes estados.
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

  /// Retorna true se o widget aparecer dentro do timeout, false caso contrário
  /// (não lança exceção — útil para branches condicionais no teste).
  Future<bool> pumpUntilMaybe(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(step);
      if (any(finder)) return true;
    }
    return false;
  }

  /// Aguarda até que o widget identificado por [finder] DESAPAREÇA da
  /// árvore de widgets. Retorna true se desapareceu, false se timeout.
  Future<bool> pumpUntilGone(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(step);
      if (!any(finder)) return true;
    }
    return false;
  }
}

/// Credenciais default usadas pelos testes (alinhadas ao teste existente
/// `protocol_module_flow_test.dart`). Podem ser sobrescritas ao chamar
/// [loginWithCredentials].
class TestCredentials {
  static const String email = 'dev@example.com';
  static const String password = 'k4hvdQ9TJ9';
}

/// Inicia o app e seleciona o tenant (município). Fica aguardando a tela de
/// login aparecer após a seleção.
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

  // Seleciona o 3º tenant se existir, para manter paridade com o teste
  // principal do módulo de protocolo (que usa o mesmo critério).
  final tenantToSelect =
      tenantCount >= 3 ? tenantCards.at(2) : tenantCards.first;
  await tester.tap(tenantToSelect);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.byKey(const Key('login_email_field')),
    timeout: const Duration(seconds: 30),
  );
}

/// Preenche email/senha e dispara submit. Aguarda navegação para o
/// `nav_profile` (tela principal autenticada).
Future<void> loginWithCredentials(
  WidgetTester tester, {
  String email = TestCredentials.email,
  String password = TestCredentials.password,
}) async {
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    password,
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
  await tester.pumpAndSettle();

  final submitButton = find.byKey(const Key('login_submit_button'));
  expect(submitButton, findsOneWidget);
  await tester.tap(submitButton, warnIfMissed: false);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.byKey(const Key('nav_profile')),
    timeout: const Duration(seconds: 60),
  );
}

/// A partir da tela principal autenticada, abre o perfil e acessa
/// "Meus Protocolos". Aguarda a lista de protocolos carregar.
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

  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );

  // Pequena espera para o ViewModel terminar o load inicial.
  await tester.pump(const Duration(seconds: 1));
}

/// Wrapper conveniente: inicia o app, seleciona tenant, faz login e navega
/// para a lista de protocolos. Reduz duplicação em todos os testes.
Future<void> loginAndOpenProtocols(WidgetTester tester) async {
  await startAppAndSelectTenant(tester);
  await loginWithCredentials(tester);
  await openProtocolsFromProfile(tester);
}

/// Abre a tela de criação tocando no FAB da lista de protocolos.
Future<void> openCreateProtocolScreen(WidgetTester tester) async {
  final fab = find.byType(FloatingActionButton);
  await tester.pumpUntil(fab, timeout: const Duration(seconds: 30));
  expect(fab, findsOneWidget);
  await tester.tap(fab);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.byKey(const Key('create_protocol_scaffold')),
    timeout: const Duration(seconds: 30),
  );
}

/// Seleciona o primeiro item VISÍVEL de um `DropdownButtonFormField<String>`.
///
/// Usa `hitTestable()` para filtrar apenas os items do overlay (os items
/// renderizados no body do form ficam invisíveis/offscreen antes do tap, mas
/// ainda estão na árvore — por isso `items.first` cru pega o errado).
Future<void> _pickFirstVisibleDropdownItem(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  // Aguarda TODOS os items serem renderizados (overlay + body)
  await tester.pumpUntil(
    find.byType(DropdownMenuItem<String>),
    timeout: timeout,
  );
  await tester.pump(const Duration(milliseconds: 200));

  // Filtra apenas os hit-testable (visíveis no overlay) — ignora os do body
  final visibleItems = find
      .byType(DropdownMenuItem<String>)
      .hitTestable(at: Alignment.center);

  if (visibleItems.evaluate().isEmpty) {
    // Fallback: nenhum item hit-testable — tenta o primeiro da lista crua
    final rawItems = find.byType(DropdownMenuItem<String>);
    if (rawItems.evaluate().isEmpty) {
      fail('Nenhum item de dropdown encontrado após abrir.');
    }
    await tester.tap(rawItems.first, warnIfMissed: false);
  } else {
    await tester.tap(visibleItems.first, warnIfMissed: false);
  }
  await tester.pumpAndSettle();
}

/// Preenche o formulário de criação de protocolo com dados de teste e submete.
/// Aguarda o retorno à `protocol_list_scaffold`.
Future<void> fillAndSubmitProtocolForm(
  WidgetTester tester, {
  String documentType = 'Requerimento Teste',
  String subject = 'Assunto de teste para criação de protocolo',
  String notes = 'Observações de teste',
}) async {
  await tester.pumpUntil(
    find.byKey(const Key('create_protocol_sector_dropdown')),
    timeout: const Duration(seconds: 30),
  );

  final sectorDropdown = find.byKey(const Key('create_protocol_sector_dropdown'));
  await tester.tap(sectorDropdown);
  await tester.pumpAndSettle();

  await _pickFirstVisibleDropdownItem(tester);

  await tester.enterText(
    find.byKey(const Key('create_protocol_document_type_field')),
    documentType,
  );
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const Key('create_protocol_subject_field')),
    subject,
  );
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const Key('create_protocol_notes_field')),
    notes,
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(
    find.byKey(const Key('create_protocol_submit_button')),
  );
  await tester.pumpAndSettle();
  await tester.drag(
    find.byKey(const Key('create_protocol_scroll')),
    const Offset(0, 300),
  );
  await tester.pumpAndSettle();

  final submitButton = find.byKey(const Key('create_protocol_submit_button'));
  expect(submitButton, findsOneWidget);
  await tester.tap(submitButton, warnIfMissed: false);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_scaffold')),
    timeout: const Duration(seconds: 30),
  );
}

/// Garante que a lista de protocolos contém pelo menos 1 item. Se estiver
/// vazia, cria um novo protocolo através do fluxo completo.
/// Retorna `true` se havia/há protocolos após o procedimento.
Future<bool> ensureAtLeastOneProtocol(WidgetTester tester) async {
  // Dá tempo para o load inicial
  await tester.pump(const Duration(seconds: 2));

  final hasList = find.byKey(const Key('protocol_list_view')).evaluate().isNotEmpty;
  final isEmpty = find.text('Nenhum protocolo encontrado').evaluate().isNotEmpty;

  if (hasList && !isEmpty) {
    return true;
  }

  // Lista vazia -> cria um protocolo
  await openCreateProtocolScreen(tester);
  await fillAndSubmitProtocolForm(tester);

  // Após criação, aguarda a lista repopular
  await tester.pump(const Duration(seconds: 2));
  return find.byKey(const Key('protocol_list_view')).evaluate().isNotEmpty;
}

/// Abre o primeiro card da lista de protocolos. Assume que já existe pelo
/// menos um protocolo (use [ensureAtLeastOneProtocol] antes).
Future<void> openFirstProtocolDetail(WidgetTester tester) async {
  await tester.pumpUntil(
    find.byKey(const Key('protocol_list_view')),
    timeout: const Duration(seconds: 30),
  );

  // Os cards têm keys `protocol_list_card_inkwell_<id>`. Pegamos o primeiro
  // InkWell dentro da ListView.
  final inkwells = find.descendant(
    of: find.byKey(const Key('protocol_list_view')),
    matching: find.byType(InkWell),
  );
  await tester.pumpUntil(inkwells, timeout: const Duration(seconds: 10));

  if (inkwells.evaluate().isEmpty) {
    fail('Nenhum card de protocolo encontrado na lista.');
  }
  await tester.tap(inkwells.first);
  await tester.pumpAndSettle();

  // Aguarda entrar na tela de detalhes
  await tester.pumpUntil(
    find.byKey(const Key('protocol_detail_view_scaffold')),
    timeout: const Duration(seconds: 30),
  );
}

/// Wrapper completo: login + protocolos + garante ao menos 1 protocolo +
/// abre detalhe do primeiro. Retorna direto na tela de detalhes.
Future<void> prepareProtocolDetail(WidgetTester tester) async {
  await loginAndOpenProtocols(tester);
  final has = await ensureAtLeastOneProtocol(tester);
  expect(has, isTrue,
      reason: 'Nenhum protocolo disponível. Abortando preparação.');
  await openFirstProtocolDetail(tester);
}

/// Fecha qualquer PopupMenu aberto. Tap num ponto neutro (canto superior
/// esquerdo do viewport — (8, 8)) — essa é a forma recomendada de fechar
/// PopupMenus em testes de integração do Flutter (eles ouvem tap fora).
Future<void> closeOpenPopupMenu(WidgetTester tester) async {
  // Se não houver PopupMenu aberto, não faz nada
  // (verificamos pela presença do overlay padrão do popup)
  // A forma mais confiável é dispatchar um tap fora: primeiro tentamos
  // Navigator.pop (funciona para showMenu/PopupMenuButton que pushou rota),
  // depois fallback de tap em canto vazio.
  try {
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    if (nav.canPop()) {
      nav.pop();
      await tester.pumpAndSettle();
      return;
    }
  } catch (_) {
    // Ignora e usa fallback
  }
  // Fallback: tap num canto neutro
  try {
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
  } catch (_) {
    // Último recurso: envia back
    await tester.pageBack();
    await tester.pumpAndSettle();
  }
}

/// Abre o menu de ações (ProtocolMenuWidget) e seleciona uma ação pelo value
/// ('edit', 'forward', 'receive', 'comment', 'cancel', 'archive').
///
/// CORREÇÃO: antes o finder usava `.last`, mas existem 2 keys para cada
/// ação (`protocol_menu_item_$value` no PopupMenuItem e
/// `protocol_menu_item_row_$value` no Row interno). Agora usamos o primeiro
/// hit-testable, que é garantidamente o PopupMenuItem (clicável).
Future<void> openProtocolMenuAndSelect(
  WidgetTester tester,
  String action,
) async {
  final menuButton = find.byKey(const Key('protocol_menu_button'));
  await tester.pumpUntil(menuButton, timeout: const Duration(seconds: 10));
  expect(menuButton, findsOneWidget);
  await tester.tap(menuButton);
  await tester.pumpAndSettle();

  final menuItemKey = Key('protocol_menu_item_$action');
  await tester.pumpUntil(
    find.byKey(menuItemKey),
    timeout: const Duration(seconds: 5),
  );

  // Pega o PRIMEIRO hit-testable com essa key — garantidamente o
  // PopupMenuItem (o Row interno tem outra key).
  final hittable = find.byKey(menuItemKey).hitTestable(at: Alignment.center);
  final target =
      hittable.evaluate().isNotEmpty ? hittable.first : find.byKey(menuItemKey).first;

  await tester.tap(target, warnIfMissed: false);
  await tester.pumpAndSettle();
}

/// Verifica se o item de menu identificado por [action] está visível no
/// `ProtocolMenuWidget`. Útil para ações condicionais (cancel/archive que só
/// aparecem quando status == 'ATIVO'). Retorna `true` se encontrado.
///
/// CORREÇÃO: antes, o menu NÃO era fechado quando a ação não estava
/// disponível, deixando o popup aberto e quebrando o teste seguinte.
/// Agora o menu é SEMPRE fechado antes de retornar, independentemente do
/// resultado.
Future<bool> isMenuActionAvailable(
  WidgetTester tester,
  String action,
) async {
  final menuButton = find.byKey(const Key('protocol_menu_button'));
  await tester.pumpUntil(menuButton, timeout: const Duration(seconds: 10));
  await tester.tap(menuButton);
  await tester.pumpAndSettle();

  final menuItem = find.byKey(Key('protocol_menu_item_$action'));
  final found = menuItem.evaluate().isNotEmpty;

  // SEMPRE fecha o menu — independente de ter encontrado ou não.
  await closeOpenPopupMenu(tester);

  return found;
}

/// Preenche o `ConfirmationDialog` (usado pelos fluxos de cancelar/arquivar)
/// com [reason] e confirma. Se [reason] for null, apenas confirma.
/// Aguarda o fechamento do diálogo.
Future<void> fillConfirmationDialogAndConfirm(
  WidgetTester tester, {
  String? reason,
}) async {
  await tester.pumpUntil(
    find.byKey(const Key('confirmation_dialog')),
    timeout: const Duration(seconds: 10),
  );

  if (reason != null) {
    final inputField = find.byKey(const Key('confirmation_dialog_input_field'));
    if (inputField.evaluate().isNotEmpty) {
      await tester.enterText(inputField, reason);
      await tester.pumpAndSettle();
    }
  }

  final confirmBtn = find.byKey(const Key('confirmation_dialog_confirm_button'));
  expect(confirmBtn, findsOneWidget);
  await tester.ensureVisible(confirmBtn);
  await tester.pumpAndSettle();
  await tester.tap(confirmBtn, warnIfMissed: false);

  // Aguarda o loader terminar e o diálogo fechar
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Garante que o diálogo realmente desapareceu (às vezes o Navigator.pop
  // duplo — um do dialog, outro da tela — pode deixar transição pendente)
  await tester.pumpUntilGone(
    find.byKey(const Key('confirmation_dialog')),
    timeout: const Duration(seconds: 5),
  );
}

/// Cancela o `ConfirmationDialog` aberto, tocando no botão "Voltar/Cancelar".
Future<void> dismissConfirmationDialog(WidgetTester tester) async {
  final dialog = find.byKey(const Key('confirmation_dialog'));
  if (dialog.evaluate().isEmpty) return;
  await tester.tap(
    find.byKey(const Key('confirmation_dialog_cancel_button')),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}

/// Rola a tela de detalhes até que a seção de "Apensos / Subdocumentos"
/// esteja visível.
Future<void> scrollToAppendicesSection(WidgetTester tester) async {
  await tester.pumpUntil(
    find.byKey(const Key('protocol_detail_view_scroll')),
    timeout: const Duration(seconds: 10),
  );

  final target = find.byKey(const Key('protocol_appendices_new_button'));
  final scrollable = find.byKey(const Key('protocol_detail_view_scroll'));

  for (var i = 0; i < 12; i++) {
    if (target.evaluate().isNotEmpty) {
      try {
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        return;
      } catch (_) {
        // Continua rolando manualmente
      }
    }
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  await tester.pumpUntil(
    target,
    timeout: const Duration(seconds: 10),
  );
}

/// Abre o diálogo `CreateAppendixDialog` a partir da tela de detalhes.
Future<void> openCreateAppendixDialog(WidgetTester tester) async {
  await scrollToAppendicesSection(tester);

  final newBtn = find.byKey(const Key('protocol_appendices_new_button'));
  expect(newBtn, findsOneWidget);
  await tester.tap(newBtn, warnIfMissed: false);
  await tester.pumpAndSettle();

  await tester.pumpUntil(
    find.byKey(const Key('create_appendix_dialog')),
    timeout: const Duration(seconds: 15),
  );

  // Aguarda o _loadSectors() terminar (tem try/catch e seta fallback, mas
  // pode levar algumas centenas de ms). Sem essa espera, o dropdown pode
  // estar sem items quando o tap for executado.
  await tester.pump(const Duration(milliseconds: 800));
}

/// Fecha o diálogo `CreateAppendixDialog` clicando em "Cancelar".
/// Aguarda o diálogo desaparecer.
Future<void> closeCreateAppendixDialog(WidgetTester tester) async {
  final cancel = find.byKey(const Key('create_appendix_cancel_button'));
  if (cancel.evaluate().isEmpty) return;
  await tester.tap(cancel, warnIfMissed: false);
  await tester.pumpAndSettle();
  await tester.pumpUntilGone(
    find.byKey(const Key('create_appendix_dialog')),
    timeout: const Duration(seconds: 5),
  );
}

/// Preenche o diálogo de criação de apenso e submete. Os anexos (arquivos)
/// NÃO são adicionados automaticamente em testes de integração porque
/// dependem de `image_picker`/`file_picker` (system pickers). O teste
/// valida apenas a presença do botão "Adicionar".
///
/// CORREÇÃO: antes usava `items.first` para o setor, o que pegava o item
/// oculto do body (não clicável). Agora usa `_pickFirstVisibleDropdownItem`
/// que filtra por hit-testable no overlay.
Future<void> fillAndSubmitAppendixDialog(
  WidgetTester tester, {
  required String title,
  String? documentType,
  String? notes,
}) async {
  // Título
  await tester.enterText(
    find.byKey(const Key('create_appendix_title_field')),
    title,
  );
  await tester.pumpAndSettle();

  if (documentType != null) {
    await tester.enterText(
      find.byKey(const Key('create_appendix_document_type_field')),
      documentType,
    );
    await tester.pumpAndSettle();
  }

  // Seleciona setor (primeiro VISÍVEL / hit-testable — não o oculto do body).
  // Antes de abrir o dropdown, tentamos garantir visibilidade via drag
  // manual dentro do dialog (ensureVisible é frágil aqui).
  final sectorDropdown = find.byKey(const Key('create_appendix_sector_dropdown'));
  await tester.pumpUntil(sectorDropdown, timeout: const Duration(seconds: 10));

  try {
    await tester.ensureVisible(sectorDropdown);
    await tester.pumpAndSettle();
  } catch (_) {
    // Se ensureVisible falhar, tenta um drag manual no dialog
    final scrollable = find.descendant(
      of: find.byKey(const Key('create_appendix_dialog')),
      matching: find.byType(Scrollable),
    );
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
  }

  await tester.tap(sectorDropdown);
  await tester.pumpAndSettle();

  await _pickFirstVisibleDropdownItem(tester);

  if (notes != null) {
    await tester.enterText(
      find.byKey(const Key('create_appendix_notes_field')),
      notes,
    );
    await tester.pumpAndSettle();
  }

  // Valida que o botão "Adicionar" anexo existe (não vamos clicar por causa
  // dos system pickers, que não funcionam em testes de integração).
  expect(
    find.byKey(const Key('create_appendix_add_attachment_button')),
    findsOneWidget,
  );

  final submit = find.byKey(const Key('create_appendix_submit_button'));
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit, warnIfMissed: false);

  // Aguarda o diálogo fechar (após onAppendixCreated)
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Garante que o diálogo realmente fechou
  await tester.pumpUntilGone(
    find.byKey(const Key('create_appendix_dialog')),
    timeout: const Duration(seconds: 10),
  );
}
