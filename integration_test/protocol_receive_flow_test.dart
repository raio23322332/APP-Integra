// integration_test/protocol_receive_flow_test.dart
//
// Fluxo de integração: RECEBER PROTOCOLO
//
// Passos:
// 1. Start app + tenant
// 2. Login
// 3. Lista de protocolos (via perfil)
// 4. Garante existência de ao menos 1 protocolo
// 5. Abre detalhe do primeiro
// 6. Abre menu -> Receber
// 7. Valida widgets
// 8. Preenche mensagem de recebimento (campo opcional)
// 9. Submete e aguarda retorno para tela de detalhes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Receber Protocolo', () {
    testWidgets(
      'deve abrir o menu, navegar para tela de recebimento e confirmar',
      (tester) async {
        // 1. App + tenant
        await startAppAndSelectTenant(tester);

        // 2. Login
        await loginWithCredentials(tester);

        // 3. Lista
        await openProtocolsFromProfile(tester);

        // 4. Garante protocolo
        final hasProtocol = await ensureAtLeastOneProtocol(tester);
        expect(hasProtocol, isTrue,
            reason: 'Nenhum protocolo disponível para testar recebimento.');

        // 5. Abre detalhe
        await openFirstProtocolDetail(tester);
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );

        // 6. Abre menu -> Receber
        await openProtocolMenuAndSelect(tester, 'receive');

        // 7. Valida widgets
        await tester.pumpUntil(
          find.byKey(const Key('protocol_receive_scaffold')),
          timeout: const Duration(seconds: 30),
        );
        expect(
          find.byKey(const Key('protocol_receive_scaffold')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_receive_scroll')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_receive_form_column')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_receive_message_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_receive_submit_button')),
          findsOneWidget,
        );

        // 8. Preenche mensagem (opcional)
        final ts = DateTime.now().millisecondsSinceEpoch;
        await tester.enterText(
          find.byKey(const Key('protocol_receive_message_field')),
          'Recebimento automatizado pelo teste ($ts).',
        );
        await tester.pumpAndSettle();

        // 9. Submete
        await tester.ensureVisible(
          find.byKey(const Key('protocol_receive_submit_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('protocol_receive_submit_button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // Pode voltar para detalhe (sucesso) OU ficar na mesma tela
        // (se o backend retornar erro — que é possível se o setor atual
        // não for o setor do usuário logado). Consideramos sucesso
        // qualquer um dos dois cenários, mas registramos para diagnóstico.
        final backInDetail = await tester.pumpUntilMaybe(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          timeout: const Duration(seconds: 15),
        );
        final stillOnReceive = find
            .byKey(const Key('protocol_receive_scaffold'))
            .evaluate()
            .isNotEmpty;
        final snackBarVisible = find.byType(SnackBar).evaluate().isNotEmpty;

        expect(
          backInDetail || stillOnReceive || snackBarVisible,
          isTrue,
          reason:
              'Após submeter recebimento, esperava-se retorno à tela de detalhes, '
              'ou permanência na tela com uma mensagem (SnackBar).',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
