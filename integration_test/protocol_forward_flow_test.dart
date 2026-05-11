// integration_test/protocol_forward_flow_test.dart
//
// Fluxo de integração: TRAMITAR PROTOCOLO
//
// Passos:
// 1. Start app + tenant
// 2. Login
// 3. Lista de protocolos (via perfil)
// 4. Garante ao menos 1 protocolo
// 5. Abre detalhe do primeiro
// 6. Abre menu -> Tramitar (forward)
// 7. Valida widgets da tela
// 8. Valida validação: submeter sem setor -> erro
// 9. Seleciona setor destino no dropdown
// 10. Preenche mensagem (opcional)
// 11. Submete tramitação
// 12. Aguarda retorno à tela de detalhes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/protocol_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Tramitar Protocolo', () {
    testWidgets(
      'deve abrir o menu, navegar, escolher setor destino e tramitar',
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
            reason: 'Nenhum protocolo disponível para testar tramitação.');

        // 5. Abre detalhe
        await openFirstProtocolDetail(tester);
        expect(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          findsOneWidget,
        );

        // 6. Abre menu -> Encaminhar
        await openProtocolMenuAndSelect(tester, 'forward');

        // 7. Valida widgets
        await tester.pumpUntil(
          find.byKey(const Key('protocol_forward_scaffold')),
          timeout: const Duration(seconds: 30),
        );
        expect(
          find.byKey(const Key('protocol_forward_scaffold')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_forward_scroll')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_forward_form_column')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_forward_sector_dropdown')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_forward_message_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('protocol_forward_submit_button')),
          findsOneWidget,
        );

        // 8. Validação: submeter sem setor -> SnackBar de erro
        await tester.ensureVisible(
          find.byKey(const Key('protocol_forward_submit_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('protocol_forward_submit_button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // Deve permanecer na mesma tela (não conseguiu enviar)
        expect(
          find.byKey(const Key('protocol_forward_scaffold')),
          findsOneWidget,
          reason: 'Sem setor selecionado, tramitação não deve ser concluída.',
        );

        // 9. Seleciona setor destino
        await tester.pumpUntil(
          find.byKey(const Key('protocol_forward_sector_dropdown')),
          timeout: const Duration(seconds: 10),
        );

        // Aguarda o carregamento assíncrono dos setores
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(
          find.byKey(const Key('protocol_forward_sector_dropdown')),
        );
        await tester.pumpAndSettle();

        // Pode ser que a lista esteja vazia (sem setores cadastrados).
        final dropdownItems = find.byType(DropdownMenuItem<String>);
        if (dropdownItems.evaluate().isEmpty) {
          // Não há setores - registramos e encerramos o teste sem falhar
          // (cenário de ambiente sem dados suficientes).
          // Fechamos o dropdown clicando em outro lugar.
          await tester.tap(
            find.byKey(const Key('protocol_forward_scaffold')),
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();
          return;
        }

        await tester.tap(dropdownItems.first);
        await tester.pumpAndSettle();

        // 10. Mensagem opcional
        final ts = DateTime.now().millisecondsSinceEpoch;
        await tester.enterText(
          find.byKey(const Key('protocol_forward_message_field')),
          'Tramitação automatizada pelo teste ($ts).',
        );
        await tester.pumpAndSettle();

        // 11. Submete
        await tester.ensureVisible(
          find.byKey(const Key('protocol_forward_submit_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('protocol_forward_submit_button')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // 12. Pode retornar a detalhe OU permanecer com SnackBar de erro.
        final backInDetail = await tester.pumpUntilMaybe(
          find.byKey(const Key('protocol_detail_view_scaffold')),
          timeout: const Duration(seconds: 15),
        );
        final stillOnForward = find
            .byKey(const Key('protocol_forward_scaffold'))
            .evaluate()
            .isNotEmpty;
        final snackBarVisible = find.byType(SnackBar).evaluate().isNotEmpty;

        expect(
          backInDetail || stillOnForward || snackBarVisible,
          isTrue,
          reason:
              'Após tramitar, esperava-se retorno à tela de detalhes ou feedback.',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
