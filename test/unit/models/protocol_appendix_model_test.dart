import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/data/models/protocol_appendix_model.dart';

void main() {
  group('ProtocolAppendixModel', () {
    test('should create ProtocolAppendixModel from JSON', () {
      // Arrange
      final json = {
        'id': 'appendix-1',
        'protocol_id': 'protocol-1',
        'order_number': 1,
        'code': 'AP-001',
        'title': 'Apenso Teste',
        'document_type': 'Documento',
        'notes': 'Observações do apenso',
        'sector_id': 'sector-1',
        'created_by': 'user-1',
        'created_at': '2024-01-01T10:00:00Z',
        'updated_at': '2024-01-01T11:00:00Z',
        'sector': {
          'id': 'sector-1',
          'name': 'Setor Teste',
          'code': 1,
          'is_active': true,
        },
        'attachments': [
          {
            'id': 'attachment-1',
            'protocol_id': 'protocol-1',
            'appendix_id': 'appendix-1',
            'category': 'Documento',
            'disk': 'tenant_protocols',
            'path': '/path/to/documento.pdf',
            'original_name': 'documento_original.pdf',
            'filename': 'documento.pdf',
            'extension': 'pdf',
            'mime_type': 'application/pdf',
            'size': 1024,
            'uploaded_by': 'user-1',
            'created_at': '2024-01-01T10:30:00Z',
          }
        ],
      };

      // Act
      final appendix = ProtocolAppendixModel.fromJson(json);

      // Assert
      expect(appendix.id, 'appendix-1');
      expect(appendix.protocolId, 'protocol-1');
      expect(appendix.orderNumber, 1);
      expect(appendix.code, 'AP-001');
      expect(appendix.title, 'Apenso Teste');
      expect(appendix.documentType, 'Documento');
      expect(appendix.notes, 'Observações do apenso');
      expect(appendix.sectorId, 'sector-1');
      expect(appendix.createdBy, 'user-1');
      expect(appendix.createdAt, '2024-01-01T10:00:00Z');
      expect(appendix.updatedAt, '2024-01-01T11:00:00Z');
      expect(appendix.sector?.name, 'Setor Teste');
      expect(appendix.attachments?.length, 1);
      expect(appendix.attachments?.first.filename, 'documento.pdf');
    });

    test('should handle null and missing values in JSON', () {
      // Arrange
      final json = {
        'id': 'appendix-1',
        'protocol_id': 'protocol-1',
        'order_number': 0,
        'code': '',
        'title': '',
        'created_by': '',
      };

      // Act
      final appendix = ProtocolAppendixModel.fromJson(json);

      // Assert
      expect(appendix.id, 'appendix-1');
      expect(appendix.protocolId, 'protocol-1');
      expect(appendix.orderNumber, 0);
      expect(appendix.code, '');
      expect(appendix.title, '');
      expect(appendix.documentType, null);
      expect(appendix.notes, null);
      expect(appendix.sectorId, null);
      expect(appendix.createdAt, null);
      expect(appendix.updatedAt, null);
      expect(appendix.sector, null);
      expect(appendix.attachments, null);
    });

    test('should convert ProtocolAppendixModel to JSON', () {
      // Arrange
      final appendix = ProtocolAppendixModel(
        id: 'appendix-1',
        protocolId: 'protocol-1',
        orderNumber: 1,
        code: 'AP-001',
        title: 'Apenso Teste',
        documentType: 'Documento',
        notes: 'Observações do apenso',
        sectorId: 'sector-1',
        createdBy: 'user-1',
        createdAt: '2024-01-01T10:00:00Z',
        updatedAt: '2024-01-01T11:00:00Z',
      );

      // Act
      final json = appendix.toJson();

      // Assert
      expect(json['id'], 'appendix-1');
      expect(json['protocol_id'], 'protocol-1');
      expect(json['order_number'], 1);
      expect(json['code'], 'AP-001');
      expect(json['title'], 'Apenso Teste');
      expect(json['document_type'], 'Documento');
      expect(json['notes'], 'Observações do apenso');
      expect(json['sector_id'], 'sector-1');
      expect(json['created_by'], 'user-1');
      expect(json['created_at'], '2024-01-01T10:00:00Z');
      expect(json['updated_at'], '2024-01-01T11:00:00Z');
    });

    test('should handle null sector and attachments in JSON conversion', () {
      // Arrange
      final appendix = ProtocolAppendixModel(
        id: 'appendix-1',
        protocolId: 'protocol-1',
        orderNumber: 1,
        code: 'AP-001',
        title: 'Apenso Teste',
        createdBy: 'user-1',
      );

      // Act
      final json = appendix.toJson();

      // Assert
      expect(json['sector'], null);
      expect(json['attachments'], null);
    });
  });
}
