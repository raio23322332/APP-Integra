// integration_test/protocol_appendix_flow_test.dart
//
// Fluxo de integração: ADICIONAR APENSO (subdocumento) ao Protocolo
//
// Passos cobertos:
// 1. Inicia o app e seleciona tenant
// 2. Realiza login com credenciais de teste
// 3. Navega até a lista de protocolos (via perfil -> Meus Protocolos)
// 4. Garante que existe ao menos 1 protocolo (cria se necessário)
// 5. Abre o detalhe do primeiro protocolo
// 6. Rola até a seção "Apensos / Subdocumentos"
// 7. Clica em "Novo Apenso"
// 8. Valida presença de todos os widgets do CreateAppendixDialog
// 9. Preenche título, tipo de documento, setor e observações
// 10. Valida que o botão "Adicionar" (arquivo anexo) está presente
//     (não clicamos pois depende de system pickers fora do app)
// 11. Submete o diálogo e aguarda fechamento
// 12. Valida que retornou para a tela de detalhes
//
// ─────────────────────────────────────────────────────────────────────────
// CORREÇÕES aplicadas em abril/2026:
//
// 1. Usa `prepareProtocolDetail` do helper — antes replicava 5 passos.
// 2. Dropdown de setor: o helper agora usa `hitTestable` para pegar apenas
//    o item visível no overlay (antes o `items.first` pegava o item oculto
//    do body do Form, causando falhas intermitentes).
// 3. O cenário "cancelar sem salvar" agora usa `closeCreateAppendixDialog`
//    para garantir que o diálogo realmente desapareceu antes do assert.
// ─────────────────────────────────────────────────────────────────────────
//
// Observações sobre anexos (arquivos):
// - O upload de arquivos para o apenso usa `image_picker`/`file_picker`
//   que abrem pickers nativos do sistema operacional, os quais não são
//   controláveis por testes de integração Flutter.
// - Portanto, este teste valida a presença do UI (botão "Adicionar")
//   mas não executa a seleção de arquivo real.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Apenso (Subdocumento)', () {
    testWidgets(
      'deve abrir o diálogo de novo apenso, preencher e salvar',
      (tester) async {
        // ── 1..5. Setup completo ───────────────────────────────────────────
        await prepareProtocolDetail(tester);
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );

        // ── 6. Rola até seção de Apensos ───────────────────────────────────
        await scrollToAppendicesSection(tester);
        expect(
          find.byKey(const Key('protocol_appendices_section')),
          findsOneWidget,
        );

        // ── 7. Clica em "Novo Apenso" ──────────────────────────────────────
        await openCreateAppendixDialog(tester);

        // ── 8. Valida widgets do diálogo ───────────────────────────────────
        expect(
          find.byKey(const Key('create_appendix_dialog')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_appendix_title_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_appendix_document_type_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_appendix_sector_dropdown')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_appendix_notes_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_appendix_add_attachment_button')),
          findsOneWidget,
          reason: 'O botão de adicionar anexo deve estar visível.',
        );
        expect(
          find.byKey(const Key('create_appendix_submit_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_appendix_cancel_button')),
          findsOneWidget,
        );

        // ── 9/10/11. Preenche e submete ────────────────────────────────────
        final ts = DateTime.now().millisecondsSinceEpoch;
        await fillAndSubmitAppendixDialog(
          tester,
          title: 'Apenso Teste $ts',
          documentType: 'Ofício',
          notes: 'Apenso criado pelo teste automatizado ($ts)',
        );

        // ── 12. Valida retorno para tela de detalhes ───────────────────────
        await tester.pumpUntil(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          timeout: const Duration(seconds: 15),
        );
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_appendix_dialog')),
          findsNothing,
          reason: 'O diálogo deve ter fechado após submit bem-sucedido.',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets(
      'deve abrir o diálogo de novo apenso e cancelar sem salvar',
      (tester) async {
        await prepareProtocolDetail(tester);

        await openCreateAppendixDialog(tester);
        expect(find.byKey(const Key('create_appendix_dialog')), findsOneWidget);

        // Cancela o diálogo (via helper que aguarda o fechamento completo)
        await closeCreateAppendixDialog(tester);

        expect(
          find.byKey(const Key('create_appendix_dialog')),
          findsNothing,
          reason: 'O diálogo deve fechar ao clicar em Cancelar.',
        );
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
