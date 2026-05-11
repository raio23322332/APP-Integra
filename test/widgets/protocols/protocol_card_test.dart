import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/data/models/protocol_model.dart';
import 'package:integra_app/data/models/sector_model.dart';
import 'package:integra_app/presentation/widgets/protocols/protocol_card.dart';

void main() {
  group('ProtocolCard Widget Tests', () {
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

    testWidgets('deve renderizar ProtocolCard com informações básicas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verifica se o número do protocolo é exibido
      expect(find.text('PROT-2024-001'), findsOneWidget);

      // Verifica se o assunto é exibido
      expect(find.text('Solicitação de equipamento'), findsOneWidget);

      // Verifica se o status é exibido
      expect(find.text('ATIVO'), findsOneWidget);

      // Verifica se o setor é exibido
      expect(find.text('Setor de TI'), findsOneWidget);
    });

    testWidgets('deve chamar onTap quando o card é pressionado', (tester) async {
      bool onTapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () => onTapCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(onTapCalled, true);
    });

    testWidgets('deve exibir ícone correto baseado no status ATIVO', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.check_circle);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('deve exibir ícone correto baseado no status CANCELADO', (tester) async {
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
            body: ProtocolCard(
              protocol: canceledProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.cancel);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('deve exibir ícone correto baseado no status ARQUIVADO', (tester) async {
      final archivedProtocol = ProtocolModel(
        id: 'protocol-3',
        number: 'PROT-2024-003',
        year: 2024,
        seq: 3,
        sectorCode: 1,
        dv: 0,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'entrada',
        subject: 'Protocolo arquivado',
        isConfidential: false,
        isEmergency: false,
        status: 'ARQUIVADO',
        createdAt: '2024-01-15T10:00:00Z',
        sector: mockSector,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: archivedProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.archive);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('deve exibir indicador de confidencial quando isConfidential é true', (tester) async {
      final confidentialProtocol = ProtocolModel(
        id: 'protocol-4',
        number: 'PROT-2024-004',
        year: 2024,
        seq: 4,
        sectorCode: 1,
        dv: 0,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'entrada',
        subject: 'Protocolo confidencial',
        isConfidential: true,
        isEmergency: false,
        status: 'ATIVO',
        createdAt: '2024-01-15T10:00:00Z',
        sector: mockSector,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: confidentialProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Confidencial'), findsWidgets);
      expect(find.byIcon(Icons.lock), findsWidgets);
    });

    testWidgets('deve exibir indicador de urgente quando isEmergency é true', (tester) async {
      final emergencyProtocol = ProtocolModel(
        id: 'protocol-5',
        number: 'PROT-2024-005',
        year: 2024,
        seq: 5,
        sectorCode: 1,
        dv: 0,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'entrada',
        subject: 'Protocolo urgente',
        isConfidential: false,
        isEmergency: true,
        status: 'ATIVO',
        createdAt: '2024-01-15T10:00:00Z',
        sector: mockSector,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: emergencyProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Urgente'), findsWidgets);
      expect(find.byIcon(Icons.priority_high), findsWidgets);
    });

    testWidgets('deve exibir ambos indicadores quando confidencial e urgente', (tester) async {
      final bothProtocol = ProtocolModel(
        id: 'protocol-6',
        number: 'PROT-2024-006',
        year: 2024,
        seq: 6,
        sectorCode: 1,
        dv: 0,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'entrada',
        subject: 'Protocolo confidencial e urgente',
        isConfidential: true,
        isEmergency: true,
        status: 'ATIVO',
        createdAt: '2024-01-15T10:00:00Z',
        sector: mockSector,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: bothProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Confidencial'), findsWidgets);
      expect(find.text('Urgente'), findsWidgets);
    });

    testWidgets('deve exibir botão de ação quando onEdit é fornecido', (tester) async {
      bool onEditCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
              onEdit: () => onEditCalled = true,
            ),
          ),
        ),
      );

      final editButton = find.byTooltip('Editar');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pump();

      expect(onEditCalled, true);
    });

    testWidgets('deve exibir botão de apensar quando onAppendix é fornecido', (tester) async {
      bool onAppendixCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
              onAppendix: () => onAppendixCalled = true,
            ),
          ),
        ),
      );

      final appendixButton = find.byTooltip('Apensar');
      expect(appendixButton, findsOneWidget);

      await tester.tap(appendixButton);
      await tester.pump();

      expect(onAppendixCalled, true);
    });

    testWidgets('deve exibir botão de tramitar quando onForward é fornecido', (tester) async {
      bool onForwardCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
              onForward: () => onForwardCalled = true,
            ),
          ),
        ),
      );

      final forwardButton = find.byTooltip('Tramitar');
      expect(forwardButton, findsOneWidget);

      await tester.tap(forwardButton);
      await tester.pump();

      expect(onForwardCalled, true);
    });

    testWidgets('deve exibir botão de cancelar quando onCancel é fornecido', (tester) async {
      bool onCancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
              onCancel: () => onCancelCalled = true,
            ),
          ),
        ),
      );

      final cancelButton = find.byTooltip('Cancelar');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pump();

      expect(onCancelCalled, true);
    });

    testWidgets('deve exibir botão de arquivar quando onArchive é fornecido', (tester) async {
      bool onArchiveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
              onArchive: () => onArchiveCalled = true,
            ),
          ),
        ),
      );

      final archiveButton = find.byTooltip('Arquivar');
      expect(archiveButton, findsOneWidget);

      await tester.tap(archiveButton);
      await tester.pump();

      expect(onArchiveCalled, true);
    });

    testWidgets('não deve exibir ações quando nenhum callback é fornecido', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byTooltip('Editar'), findsNothing);
      expect(find.byTooltip('Apensar'), findsNothing);
      expect(find.byTooltip('Tramitar'), findsNothing);
      expect(find.byTooltip('Cancelar'), findsNothing);
      expect(find.byTooltip('Arquivar'), findsNothing);
    });

    testWidgets('deve formatar data corretamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      // A data 2024-01-15 deve ser formatada como 15/1/2024
      expect(find.textContaining('15/1/2024'), findsOneWidget);
    });

    testWidgets('deve ter key correta para identificar o widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolCard(
              protocol: mockProtocol,
              onTap: () {},
            ),
          ),
        ),
      );

      final cardFinder = find.byKey(const ValueKey('protocol_card_widget_protocol-1'));
      expect(cardFinder, findsOneWidget);
    });
  });
}
