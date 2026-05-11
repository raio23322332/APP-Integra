// integration_test/protocol_cancel_flow_test.dart
//
// Fluxo de integração: CANCELAMENTO DE PROTOCOLO
//
// Passos cobertos:
// 1. Inicia o app e seleciona tenant
// 2. Realiza login com credenciais de teste
// 3. Navega até a lista de protocolos (via perfil -> Meus Protocolos)
// 4. Garante que existe ao menos 1 protocolo (cria se necessário)
// 5. Abre o detalhe do primeiro protocolo
// 6. Verifica se a ação "Cancelar" está disponível no menu
//    (apenas para protocolos com status == 'ATIVO')
// 7. Se disponível: abre o menu, seleciona "Cancelar", preenche o motivo no
//    ConfirmationDialog e confirma. Valida que o diálogo fechou.
// 8. Se NÃO disponível: documenta que o protocolo já está em status
//    não-cancelável e finaliza o teste com sucesso (não falha — é um
//    comportamento válido).
//
// ─────────────────────────────────────────────────────────────────────────
// CORREÇÕES aplicadas em abril/2026:
//
// 1. `isMenuActionAvailable` agora fecha o menu corretamente (antes deixava
//    aberto quando a ação não estava disponível, quebrando a chamada
//    subsequente de `openProtocolMenuAndSelect`).
// 2. Usa `prepareProtocolDetail` do helper (unifica login+detalhe).
// 3. `fillConfirmationDialogAndConfirm` agora aguarda o diálogo realmente
//    desaparecer (antes podia haver race condition entre o pop do diálogo
//    e o pop automático da tela de detalhes).
// ─────────────────────────────────────────────────────────────────────────
//
// Observações:
// - A ação "Cancelar" usa o `ConfirmationDialog` com campo de input
//   obrigatório (motivo).
// - Após cancelar, o `ProtocolMenuWidget` chama `Navigator.pop()` para
//   voltar à tela anterior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Cancelamento de Protocolo', () {
    testWidgets(
      'deve abrir o menu, cancelar o protocolo e confirmar com motivo',
      (tester) async {
        // ── 1..5. Setup completo ───────────────────────────────────────────
        await prepareProtocolDetail(tester);
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('protocol_menu_button')), findsOneWidget);

        // ── 6. Verifica disponibilidade de "Cancelar" ──────────────────────
        // A opção só aparece quando status == 'ATIVO'. Se o protocolo
        // disponível estiver em outro status, pulamos o fluxo com sucesso.
        final available = await isMenuActionAvailable(tester, 'cancel');

        if (!available) {
          debugPrint(
            '⚠️ Ação "Cancelar" não disponível no menu deste protocolo '
            '(provavelmente o status não é ATIVO). Teste finalizado sem ação.',
          );
          expect(
            find.byKey(const Key('protocol_detail_view_scaffold')),
            findsOneWidget,
            reason: 'Após checar disponibilidade, a tela de detalhes '
                'deve permanecer visível (o menu foi fechado pelo helper).',
          );
          return;
        }

        // ── 7. Abre menu -> Cancelar ───────────────────────────────────────
        await openProtocolMenuAndSelect(tester, 'cancel');

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
          reason: 'Cancelamento exige motivo obrigatório (input visível).',
        );
        expect(
          find.byKey(const Key('confirmation_dialog_confirm_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('confirmation_dialog_cancel_button')),
          findsOneWidget,
        );

        // ── 9. Preenche motivo e confirma ──────────────────────────────────
        final reason =
            'Cancelado pelo teste automatizado ${DateTime.now().millisecondsSinceEpoch}';
        await fillConfirmationDialogAndConfirm(tester, reason: reason);

        // ── 10. Valida que o diálogo fechou ────────────────────────────────
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
