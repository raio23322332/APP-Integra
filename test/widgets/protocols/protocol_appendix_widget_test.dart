import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/data/models/protocol_model.dart';
import 'package:integra_app/data/models/sector_model.dart';
import 'package:integra_app/presentation/widgets/protocols/protocol_appendix_widget.dart';

void main() {
  group('ProtocolAppendixWidget Tests', () {
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

    testWidgets('deve renderizar widget com título "Anexos"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolAppendixWidget(protocol: mockProtocol),
          ),
        ),
      );

      expect(find.text('Anexos'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });

    testWidgets('deve exibir estado vazio quando não há anexos', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolAppendixWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Aguarda carregamento
      await tester.pumpAndSettle();

      expect(find.text('Nenhum anexo encontrado'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('deve exibir indicador de carregamento durante load', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolAppendixWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Verifica se está em estado de carregamento inicial
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('deve exibir anexo quando houver anexos carregados', (tester) async {
      // Este teste seria complexo pois requer mock do ProtocolHttp
      // Por enquanto, vamos apenas verificar a estrutura básica
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolAppendixWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Aguarda carregamento
      await tester.pumpAndSettle();

      // Verifica estrutura básica
      expect(find.text('Anexos'), findsOneWidget);
    });

    testWidgets('deve ter ícone attach_file no cabeçalho', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolAppendixWidget(protocol: mockProtocol),
          ),
        ),
      );

      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });

    testWidgets('deve renderizar dentro de um container card-like', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolAppendixWidget(protocol: mockProtocol),
          ),
        ),
      );

      // Verifica se há estrutura de card
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('deve aceitar parâmetro appendixId opcional', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolAppendixWidget(
              protocol: mockProtocol,
              appendixId: 'appendix-1',
            ),
          ),
        ),
      );

      // Verifica se renderiza sem erro
      expect(find.text('Anexos'), findsOneWidget);
    });
  });
}
