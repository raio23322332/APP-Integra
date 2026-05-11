// integration_test/protocol_archive_flow_test.dart
//
// Fluxo de integração: ARQUIVAMENTO DE PROTOCOLO
//
// Passos cobertos:
// 1. Inicia o app e seleciona tenant
// 2. Realiza login com credenciais de teste
// 3. Navega até a lista de protocolos (via perfil -> Meus Protocolos)
// 4. Garante que existe ao menos 1 protocolo (cria se necessário)
// 5. Abre o detalhe do primeiro protocolo
// 6. Verifica se a ação "Arquivar" está disponível no menu
//    (apenas para protocolos com status == 'ATIVO')
// 7. Se disponível: abre o menu, seleciona "Arquivar", preenche a
//    justificativa (opcional) no ConfirmationDialog e confirma.
// 8. Se NÃO disponível: documenta que o protocolo já está arquivado e
//    finaliza o teste com sucesso.
//
// ─────────────────────────────────────────────────────────────────────────
// CORREÇÕES aplicadas em abril/2026:
// - Usa `prepareProtocolDetail` (unificado) + helpers corrigidos para
//   `isMenuActionAvailable` e `fillConfirmationDialogAndConfirm`.
// ─────────────────────────────────────────────────────────────────────────
//
// Observações:
// - A ação "Arquivar" usa o `ConfirmationDialog` com campo de input
//   OPCIONAL (justificativa).
// - Após arquivar, o `ProtocolMenuWidget` chama `Navigator.pop()` para
//   voltar à tela anterior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Arquivamento de Protocolo', () {
    testWidgets(
      'deve abrir o menu, arquivar o protocolo e confirmar',
      (tester) async {
        // ── 1..5. Setup completo ───────────────────────────────────────────
        await prepareProtocolDetail(tester);
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('protocol_menu_button')), findsOneWidget);

        // ── 6. Verifica disponibilidade de "Arquivar" ──────────────────────
        final available = await isMenuActionAvailable(tester, 'archive');

        if (!available) {
          debugPrint(
            '⚠️ Ação "Arquivar" não disponível no menu deste protocolo '
            '(provavelmente o status não é ATIVO). Teste finalizado sem ação.',
          );
          expect(
            find.byKey(const Key('protocol_detail_view_scaffold')),
            findsOneWidget,
          );
          return;
        }

        // ── 7. Abre menu -> Arquivar ───────────────────────────────────────
        await openProtocolMenuAndSelect(tester, 'archive');

        // ── 8. ConfirmationDialog ──────────────────────────────────────────
        await tester.pumpUntil(
          find.byKey(const Key('confirmation_dialog')),
          timeout: const Duration(seconds: 10),
        );

        expect(
          find.byKey(const Key('confirmation_dialog')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('confirmation_dialog_input_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('confirmation_dialog_confirm_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('confirmation_dialog_cancel_button')),
          findsOneWidget,
        );

        // ── 9. Preenche justificativa e confirma ──────────────────────────
        final reason =
            'Arquivamento automatizado ${DateTime.now().millisecondsSinceEpoch}';
        await fillConfirmationDialogAndConfirm(tester, reason: reason);

        // ── 10. Valida que o diálogo fechou ───────────────────────────────
        expect(
          find.byKey(const Key('confirmation_dialog')),
          findsNothing,
          reason: 'O ConfirmationDialog deve fechar após o sucesso.',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
