// integration_test/protocol_comment_flow_test.dart
//
// Fluxo de integração: COMENTAR PROTOCOLO
//
// Passos:
// 1. Start app + tenant
// 2. Login
// 3. Lista de protocolos (via perfil)
// 4. Garante que existe ao menos 1 protocolo
// 5. Abre detalhe do primeiro
// 6. Abre menu -> Comentar
// 7. Valida widgets da tela
// 8. Testa validação (campo vazio)
// 9. Preenche comentário e submete
// 10. Valida retorno à tela de detalhes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Comentar Protocolo', () {
    testWidgets(
      'deve abrir o menu, navegar para tela de comentário, validar e enviar',
      (tester) async {
        // 1. App + tenant
        await startAppAndSelectTenant(tester);

        // 2. Login
        await loginWithCredentials(tester);

        // 3. Lista de protocolos
        await openProtocolsFromProfile(tester);

        // 4. Garante protocolo
        final hasProtocol = await ensureAtLeastOneProtocol(tester);
        expect(hasProtocol, isTrue,
            reason: 'Nenhum protocolo disponível para testar comentário.');

        // 5. Abrir detalhe
        await openFirstProtocolDetail(tester);
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );

        // 6. Abrir menu -> Comentar
        await openProtocolMenuAndSelect(tester, 'comment');

        // 7. Valida widgets
        await tester.pumpUntil(
          find.byKey(const Key('protocol_comment_scaffold')),
          timeout: const Duration(seconds: 30),
        );
        expect(
          find.byKey(const Key('protocol_comment_scaffold')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_comment_scroll')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_comment_form_column')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_comment_message_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_comment_submit_button')),
          findsOneWidget,
        );

        // 8. Testa validação: submeter com campo vazio
        await tester.tap(
          find.byKey(const Key('protocol_comment_submit_button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // Deve permanecer na tela, pois o validador exige conteúdo
        expect(
          find.byKey(const Key('protocol_comment_scaffold')),
          findsOneWidget,
          reason:
              'Ao tentar enviar comentário vazio, a tela não deve navegar.',
        );

        // 9. Preenche e envia
        final ts = DateTime.now().millisecondsSinceEpoch;
        final comment = 'Comentário automático do teste de integração ($ts).';

        await tester.enterText(
          find.byKey(const Key('protocol_comment_message_field')),
          comment,
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.byKey(const Key('protocol_comment_submit_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('protocol_comment_submit_button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // 10. Deve voltar pra detalhe (ou ficar em uma SnackBar de sucesso)
        final backInDetail = await tester.pumpUntilMaybe(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          timeout: const Duration(seconds: 15),
        );

        expect(
          backInDetail,
          isTrue,
          reason:
              'Após enviar comentário, deveria retornar à tela de detalhes.',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
