// integration_test/protocol_edit_flow_test.dart
//
// Fluxo de integração: EDIÇÃO DE PROTOCOLO
//
// Passos cobertos:
// 1. Inicia o app e seleciona tenant
// 2. Realiza login com credenciais de teste
// 3. Navega até a lista de protocolos (via perfil -> Meus Protocolos)
// 4. Garante que existe ao menos 1 protocolo (cria se necessário)
// 5. Abre o detalhe do primeiro protocolo
// 6. Abre o menu de ações e seleciona "Editar"
// 7. Valida presença de todos os widgets da tela de edição
// 8. Altera documento, assunto e observações
// 9. Submete a edição e retorna para a tela de detalhes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Edição de Protocolo', () {
    testWidgets(
      'deve abrir o menu, navegar para tela de edição, editar e salvar',
      (tester) async {
        // ── 1. App + tenant ────────────────────────────────────────────────
        await startAppAndSelectTenant(tester);

        // ── 2. Login ───────────────────────────────────────────────────────
        await loginWithCredentials(tester);

        // ── 3. Navega para Protocolos ──────────────────────────────────────
        await openProtocolsFromProfile(tester);

        // ── 4. Garante ao menos 1 protocolo ────────────────────────────────
        final hasProtocol = await ensureAtLeastOneProtocol(tester);
        expect(
          hasProtocol,
          isTrue,
          reason: 'Nenhum protocolo disponível para testar edição.',
        );

        // ── 5. Abre o detalhe do primeiro protocolo ────────────────────────
        await openFirstProtocolDetail(tester);

        // Valida estar na tela de detalhes
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('protocol_menu_button')), findsOneWidget);

        // ── 6. Abre menu -> Editar ─────────────────────────────────────────
        await openProtocolMenuAndSelect(tester, 'edit');

        // ── 7. Tela de edição carregada ────────────────────────────────────
        await tester.pumpUntil(
          find.byKey(const Key('protocol_edit_scaffold')),
          timeout: const Duration(seconds: 30),
        );

        expect(
          find.byKey(const Key('protocol_edit_scaffold')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('protocol_edit_scroll')), findsOneWidget);
        expect(
          find.byKey(const Key('protocol_edit_form_column')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_edit_main_fields_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_edit_document_type_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_edit_subject_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_edit_notes_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_edit_submit_button')),
          findsOneWidget,
        );

        // ── 8. Alterar campos ──────────────────────────────────────────────
        final ts = DateTime.now().millisecondsSinceEpoch;
        final newDocType = 'Requerimento Editado $ts';
        final newSubject = 'Assunto editado pelo teste automatizado ($ts)';
        final newNotes = 'Observações editadas pelo teste ($ts)';

        await tester.enterText(
          find.byKey(const Key('protocol_edit_document_type_field')),
          newDocType,
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('protocol_edit_subject_field')),
          newSubject,
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('protocol_edit_notes_field')),
          newNotes,
        );
        await tester.pumpAndSettle();

        // ── 9. Submeter ────────────────────────────────────────────────────
        await tester.ensureVisible(
          find.byKey(const Key('protocol_edit_submit_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('protocol_edit_submit_button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // Após salvar, a tela deve voltar (pop) e o SnackBar de sucesso deve
        // aparecer. Aguardamos uma das duas condições:
        final backInDetail = await tester.pumpUntilMaybe(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          timeout: const Duration(seconds: 15),
        );
        final backInList = await tester.pumpUntilMaybe(
          find.byKey(const Key('protocol_list_scaffold')),
          timeout: const Duration(seconds: 5),
        );

        expect(
          backInDetail || backInList,
          isTrue,
          reason:
              'Após salvar edição, o app deveria voltar para detalhes ou para a lista.',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
