import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/data/models/protocol_model.dart';
import 'package:integra_app/data/models/sector_model.dart';
import 'package:integra_app/presentation/widgets/protocols/protocol_menu_widget.dart';

void main() {
  group('ProtocolMenuWidget Tests', () {
    late ProtocolModel mockProtocol;
    late SectorModel mockSector;

    setUp(() {
      mockSector = const SectorModel(
        id: 'sector-1',
        name: 'Setor de TI',
        code: 1,
        isActive: true,
      );

      mockProtocol = ProtocolModel(
        id: 'protocol-1',
        number: 'PROT-2024-001',
        year: 2024,
        seq: 1,
        sectorCode: 1,
        dv: 0,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'entrada',
        subject: 'Solicitação de equipamento',
        isConfidential: false,
        isEmergency: false,
        status: 'ATIVO',
        createdAt: '2024-01-15T10:00:00Z',
        sector: mockSector,
      );
    });

    testWidgets('deve renderizar PopupMenuButton com ícone more_vert', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: mockProtocol),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('deve exibir itens de menu básicos', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Abre o menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Verifica itens básicos do menu
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Tramitar'), findsOneWidget);
      expect(find.text('Receber'), findsOneWidget);
      expect(find.text('Comentar'), findsOneWidget);
    });

    testWidgets('deve exibir itens de cancelar e arquivar quando status é ATIVO', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Abre o menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Verifica itens de ação destrutiva
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Arquivar'), findsOneWidget);
    });

    testWidgets('não deve exibir itens de cancelar e arquivar quando status não é ATIVO', (tester) async {
      final canceledProtocol = ProtocolModel(
        id: 'protocol-2',
        number: 'PROT-2024-002',
        year: 2024,
        seq: 2,
        sectorCode: 1,
        dv: 0,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'entrada',
        subject: 'Protocolo cancelado',
        isConfidential: false,
        isEmergency: false,
        status: 'CANCELADO',
        createdAt: '2024-01-15T10:00:00Z',
        sector: mockSector,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: canceledProtocol),
          ),
        ),
      );

      // Abre o menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Não deve exibir itens de ação destrutiva
      expect(find.text('Cancelar'), findsNothing);
      expect(find.text('Arquivar'), findsNothing);
    });

    testWidgets('deve exibir subtítulos descritivos nos itens do menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Abre o menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Verifica subtítulos
      expect(find.text('Alterar informações do protocolo'), findsOneWidget);
      expect(find.text('Enviar para outro setor'), findsOneWidget);
      expect(find.text('Confirmar recebimento'), findsOneWidget);
      expect(find.text('Adicionar observação'), findsOneWidget);
    });

    testWidgets('deve exibir ícones corretos nos itens do menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Abre o menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Verifica ícones
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.send_outlined), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.byIcon(Icons.comment_outlined), findsOneWidget);
    });

    testWidgets('deve ter formato circular no PopupMenuButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: mockProtocol),
          ),
        ),
      );

      final popupMenu = tester.widget<PopupMenuButton<String>>(
        find.byType(PopupMenuButton<String>),
      );

      expect(popupMenu.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('deve ter elevação e sombra configuradas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolMenuWidget(protocol: mockProtocol),
          ),
        ),
      );

      final popupMenu = tester.widget<PopupMenuButton<String>>(
        find.byType(PopupMenuButton<String>),
      );

      expect(popupMenu.elevation, 8);
      expect(popupMenu.shadowColor, isNotNull);
    });
  });
}
