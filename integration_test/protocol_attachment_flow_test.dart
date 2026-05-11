// integration_test/protocol_attachment_flow_test.dart
//
// Fluxo de integração: ANEXOS (Attachments) do Protocolo
//
// Este teste valida a presença da UI de anexos na tela de detalhes do
// protocolo e verifica que o botão de adicionar anexo está disponível
// dentro do diálogo de criação de apenso (onde o upload é feito hoje).
//
// Passos cobertos:
// 1. Inicia o app e seleciona tenant
// 2. Realiza login com credenciais de teste
// 3. Navega até a lista de protocolos
// 4. Garante que existe ao menos 1 protocolo
// 5. Abre o detalhe do primeiro protocolo
// 6. Rola até a seção de Apensos e valida que a seção de anexos existe
// 7. Abre o CreateAppendixDialog (onde fica o botão de adicionar anexo)
// 8. Valida que o botão "Adicionar" (anexo) está presente
// 9. Fecha o diálogo sem submeter
//
// ─────────────────────────────────────────────────────────────────────────
// CORREÇÕES aplicadas em abril/2026:
//
// 1. Usa `prepareProtocolDetail` do helper (unificado) em vez de replicar
//    login+tenant+protocolos+detail em cada teste.
// 2. Usa `closeCreateAppendixDialog` do helper — antes, o teste fazia o tap
//    direto no botão Cancel, mas não aguardava o diálogo realmente
//    desaparecer, podendo gerar assertions falsos em CI lento.
// 3. Valida o ESTADO da UI (seção existe, botão existe) em uma ordem
//    determinística para evitar flakiness.
//
// Observações importantes:
// - O upload real de arquivos usa `image_picker`/`file_picker` que abrem
//   pickers NATIVOS do sistema (câmera, galeria, sistema de arquivos).
//   Esses pickers saem do contexto do Flutter e não podem ser
//   manipulados via `WidgetTester`.
// - Por isso este teste valida APENAS a UI (presença do botão e estrutura
//   correta). Testes de upload real devem ser feitos com mocks unitários
//   ou manualmente.
// - No `ProtocolAppendixWidget` (lista de anexos), o botão "Adicionar"
//   está comentado no código atual — apenas visualização/exclusão são
//   suportadas nessa lista. Por isso focamos no `CreateAppendixDialog`.
// ─────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Anexos do Protocolo', () {
    testWidgets(
      'deve exibir a seção de apensos e o botão de adicionar anexo no diálogo',
      (tester) async {
        // ── 1/2/3/4/5. App + login + protocolos + detalhe ──────────────────
        await prepareProtocolDetail(tester);

        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
          reason: 'A tela de detalhes deve estar visível antes de testar anexos.',
        );

        // ── 6. Valida seção de Apensos ─────────────────────────────────────
        await scrollToAppendicesSection(tester);
        expect(
          find.byKey(const Key('protocol_appendices_section')),
          findsOneWidget,
          reason: 'A seção "Apensos / Subdocumentos" deve existir.',
        );
        expect(
          find.byKey(const Key('protocol_appendices_new_button')),
          findsOneWidget,
          reason: 'O botão "Novo Apenso" deve estar presente.',
        );

        // ── 7. Abre CreateAppendixDialog ───────────────────────────────────
        await openCreateAppendixDialog(tester);

        // ── 8. Valida botão de adicionar anexo dentro do diálogo ───────────
        expect(
          find.byKey(const Key('create_appendix_add_attachment_button')),
          findsOneWidget,
          reason:
              'O botão para adicionar anexo (image_picker/file_picker) '
              'deve existir no diálogo de criação de apenso.',
        );

        // Valida também que os outros controles do diálogo estão presentes
        // (caso alguma refatoração remova acidentalmente um deles, o teste
        // de anexos também detecta).
        expect(find.byKey(const Key('create_appendix_dialog')), findsOneWidget);
        expect(find.byKey(const Key('create_appendix_title_field')), findsOneWidget);
        expect(find.byKey(const Key('create_appendix_sector_dropdown')), findsOneWidget);
        expect(find.byKey(const Key('create_appendix_submit_button')), findsOneWidget);
        expect(find.byKey(const Key('create_appendix_cancel_button')), findsOneWidget);

        // ── 9. Fecha o diálogo sem submeter ────────────────────────────────
        await closeCreateAppendixDialog(tester);

        expect(
          find.byKey(const Key('create_appendix_dialog')),
          findsNothing,
          reason: 'O diálogo deve ter fechado ao clicar em Cancelar.',
        );
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
          reason: 'A tela de detalhes deve continuar visível após fechar o diálogo.',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
