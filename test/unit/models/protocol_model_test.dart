import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/data/models/protocol_model.dart';

void main() {
  group('ProtocolModel', () {
    test('should create ProtocolModel from JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'number': '123/2024',
        'year': 2024,
        'seq': 123,
        'sector_code': 1,
        'dv': 9,
        'sector_id': 'sector-1',
        'created_by': 'user-1',
        'direction': 'IN',
        'document_type': 'Ofício',
        'subject': 'Assunto do protocolo',
        'notes': 'Observações',
        'origin_protocol': 'OP-001',
        'origin_agency': 'Agência Origem',
        'is_confidential': false,
        'is_emergency': true,
        'status': 'PENDING',
        'registered_at': '2024-01-01T10:00:00Z',
        'created_at': '2024-01-01T09:00:00Z',
        'updated_at': '2024-01-01T11:00:00Z',
        'sector': {
          'id': 'sector-1',
          'name': 'Setor Teste',
          'code': 1,
          'is_active': true,
        },
        'movements': [
          {
            'id': 'movement-1',
            'protocol_id': '1',
            'from_sector_id': 'sector-1',
            'to_sector_id': 'sector-2',
            'moved_by': 'user-1',
            'action': 'FORWARDED',
            'message': 'Tramitação',
            'moved_at': '2024-01-01T10:30:00Z',
            'from_sector': {
              'id': 'sector-1',
              'name': 'Setor Origem',
              'code': 'SO',
            },
            'to_sector': {
              'id': 'sector-2',
              'name': 'Setor Destino',
              'code': 'SD',
            },
          }
        ],
      };

      // Act
      final protocol = ProtocolModel.fromJson(json);

      // Assert
      expect(protocol.id, '1');
      expect(protocol.number, '123/2024');
      expect(protocol.year, 2024);
      expect(protocol.seq, 123);
      expect(protocol.sectorCode, 1);
      expect(protocol.dv, 9);
      expect(protocol.sectorId, 'sector-1');
      expect(protocol.createdBy, 'user-1');
      expect(protocol.direction, 'IN');
      expect(protocol.documentType, 'Ofício');
      expect(protocol.subject, 'Assunto do protocolo');
      expect(protocol.notes, 'Observações');
      expect(protocol.originProtocol, 'OP-001');
      expect(protocol.originAgency, 'Agência Origem');
      expect(protocol.isConfidential, false);
      expect(protocol.isEmergency, true);
      expect(protocol.status, 'PENDING');
      expect(protocol.registeredAt, '2024-01-01T10:00:00Z');
      expect(protocol.createdAt, '2024-01-01T09:00:00Z');
      expect(protocol.updatedAt, '2024-01-01T11:00:00Z');
      expect(protocol.sector?.name, 'Setor Teste');
      expect(protocol.movements?.length, 1);
      expect(protocol.movements?.first.action, 'FORWARDED');
    });

    test('should handle null and missing values in JSON', () {
      // Arrange
      final json = {
        'id': '',
        'number': '',
        'year': 0,
        'seq': 0,
        'sector_code': 0,
        'dv': 0,
        'sector_id': '',
        'created_by': '',
        'direction': '',
        'subject': '',
        'is_confidential': false,
        'is_emergency': false,
        'status': '',
      };

      // Act
      final protocol = ProtocolModel.fromJson(json);

      // Assert
      expect(protocol.id, '');
      expect(protocol.number, '');
      expect(protocol.year, 0);
      expect(protocol.documentType, null);
      expect(protocol.notes, null);
      expect(protocol.originProtocol, null);
      expect(protocol.originAgency, null);
      expect(protocol.sector, null);
      expect(protocol.movements, null);
    });

    test('should convert ProtocolModel to JSON', () {
      // Arrange
      final protocol = ProtocolModel(
        id: '1',
        number: '123/2024',
        year: 2024,
        seq: 123,
        sectorCode: 1,
        dv: 9,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'IN',
        documentType: 'Ofício',
        subject: 'Assunto do protocolo',
        notes: 'Observações',
        originProtocol: 'OP-001',
        originAgency: 'Agência Origem',
        isConfidential: false,
        isEmergency: true,
        status: 'PENDING',
        registeredAt: '2024-01-01T10:00:00Z',
        createdAt: '2024-01-01T09:00:00Z',
        updatedAt: '2024-01-01T11:00:00Z',
      );

      // Act
      final json = protocol.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['number'], '123/2024');
      expect(json['year'], 2024);
      expect(json['document_type'], 'Ofício');
      expect(json['subject'], 'Assunto do protocolo');
      expect(json['notes'], 'Observações');
      expect(json['origin_protocol'], 'OP-001');
      expect(json['origin_agency'], 'Agência Origem');
      expect(json['is_confidential'], false);
      expect(json['is_emergency'], true);
      expect(json['status'], 'PENDING');
    });

    test('should copy ProtocolModel with new values', () {
      // Arrange
      final originalProtocol = ProtocolModel(
        id: '1',
        number: '123/2024',
        year: 2024,
        seq: 123,
        sectorCode: 1,
        dv: 9,
        sectorId: 'sector-1',
        createdBy: 'user-1',
        direction: 'IN',
        subject: 'Assunto original',
        isConfidential: false,
        isEmergency: false,
        status: 'PENDING',
      );

      // Act
      final updatedProtocol = originalProtocol.copyWith(
        subject: 'Assunto atualizado',
        isEmergency: true,
      );

      // Assert
      expect(updatedProtocol.id, '1');
      expect(updatedProtocol.subject, 'Assunto atualizado');
      expect(updatedProtocol.isEmergency, true);
      expect(updatedProtocol.isConfidential, false); // unchanged
      expect(updatedProtocol.status, 'PENDING'); // unchanged
    });
  });

  group('ProtocolMovementModel', () {
    test('should create ProtocolMovementModel from JSON', () {
      // Arrange
      final json = {
        'id': 'movement-1',
        'protocol_id': '1',
        'from_sector_id': 'sector-1',
        'to_sector_id': 'sector-2',
        'moved_by': 'user-1',
        'action': 'FORWARDED',
        'message': 'Tramitação',
        'moved_at': '2024-01-01T10:30:00Z',
        'from_sector': {
          'id': 'sector-1',
          'name': 'Setor Origem',
          'code': 'SO',
        },
        'to_sector': {
          'id': 'sector-2',
          'name': 'Setor Destino',
          'code': 'SD',
        },
      };

      // Act
      final movement = ProtocolMovementModel.fromJson(json);

      // Assert
      expect(movement.id, 'movement-1');
      expect(movement.protocolId, '1');
      expect(movement.fromSectorId, 'sector-1');
      expect(movement.toSectorId, 'sector-2');
      expect(movement.movedBy, 'user-1');
      expect(movement.action, 'FORWARDED');
      expect(movement.message, 'Tramitação');
      expect(movement.movedAt, '2024-01-01T10:30:00Z');
      expect(movement.fromSectorName, 'Setor Origem');
      expect(movement.toSectorName, 'Setor Destino');
      expect(movement.fromSectorCode, 'SO');
      expect(movement.toSectorCode, 'SD');
    });

    test('should handle null values in JSON', () {
      // Arrange
      final json = {
        'id': 'movement-1',
        'protocol_id': '1',
        'moved_by': 'user-1',
        'action': 'REGISTERED',
        'moved_at': '2024-01-01T10:30:00Z',
      };

      // Act
      final movement = ProtocolMovementModel.fromJson(json);

      // Assert
      expect(movement.fromSectorId, null);
      expect(movement.toSectorId, null);
      expect(movement.message, null);
      expect(movement.fromSector, null);
      expect(movement.toSector, null);
      expect(movement.fromSectorName, null);
      expect(movement.toSectorName, null);
      expect(movement.fromSectorCode, null);
      expect(movement.toSectorCode, null);
    });

    test('should convert ProtocolMovementModel to JSON', () {
      // Arrange
      final movement = ProtocolMovementModel(
        id: 'movement-1',
        protocolId: '1',
        fromSectorId: 'sector-1',
        toSectorId: 'sector-2',
        movedBy: 'user-1',
        action: 'FORWARDED',
        message: 'Tramitação',
        movedAt: '2024-01-01T10:30:00Z',
      );

      // Act
      final json = movement.toJson();

      // Assert
      expect(json['id'], 'movement-1');
      expect(json['protocol_id'], '1');
      expect(json['from_sector_id'], 'sector-1');
      expect(json['to_sector_id'], 'sector-2');
      expect(json['moved_by'], 'user-1');
      expect(json['action'], 'FORWARDED');
      expect(json['message'], 'Tramitação');
      expect(json['moved_at'], '2024-01-01T10:30:00Z');
    });

    test('should return correct full description for different actions', () {
      // Test REGISTERED action
      final registeredMovement = ProtocolMovementModel(
        id: '1',
        protocolId: '1',
        movedBy: 'user-1',
        action: 'REGISTERED',
        movedAt: '2024-01-01T10:30:00Z',
        fromSector: {'name': 'Setor Teste'},
      );
      expect(registeredMovement.fullDescription, 'Registrado em Setor Teste');

      // Test FORWARDED action
      final forwardedMovement = ProtocolMovementModel(
        id: '2',
        protocolId: '1',
        movedBy: 'user-1',
        action: 'FORWARDED',
        movedAt: '2024-01-01T10:30:00Z',
        fromSector: {'name': 'Setor Origem'},
        toSector: {'name': 'Setor Destino'},
      );
      expect(forwardedMovement.fullDescription, 'Tramitado de Setor Origem para Setor Destino');

      // Test RECEIVED action
      final receivedMovement = ProtocolMovementModel(
        id: '3',
        protocolId: '1',
        movedBy: 'user-1',
        action: 'RECEIVED',
        movedAt: '2024-01-01T10:30:00Z',
        toSector: {'name': 'Setor Destino'},
      );
      expect(receivedMovement.fullDescription, 'Recebido em Setor Destino');

      // Test COMMENTED action
      final commentedMovement = ProtocolMovementModel(
        id: '4',
        protocolId: '1',
        movedBy: 'user-1',
        action: 'COMMENTED',
        movedAt: '2024-01-01T10:30:00Z',
        fromSector: {'name': 'Setor Teste'},
      );
      expect(commentedMovement.fullDescription, 'Comentado em Setor Teste');

      // Test CANCELED action
      final canceledMovement = ProtocolMovementModel(
        id: '5',
        protocolId: '1',
        movedBy: 'user-1',
        action: 'CANCELED',
        movedAt: '2024-01-01T10:30:00Z',
        fromSector: {'name': 'Setor Teste'},
      );
      expect(canceledMovement.fullDescription, 'Cancelado em Setor Teste');

      // Test ARCHIVED action
      final archivedMovement = ProtocolMovementModel(
        id: '6',
        protocolId: '1',
        movedBy: 'user-1',
        action: 'ARCHIVED',
        movedAt: '2024-01-01T10:30:00Z',
        fromSector: {'name': 'Setor Teste'},
      );
      expect(archivedMovement.fullDescription, 'Arquivado em Setor Teste');

      // Test unknown action
      final unknownMovement = ProtocolMovementModel(
        id: '7',
        protocolId: '1',
        movedBy: 'user-1',
        action: 'UNKNOWN',
        movedAt: '2024-01-01T10:30:00Z',
        fromSector: {'name': 'Setor Teste'},
      );
      expect(unknownMovement.fullDescription, 'UNKNOWN em Setor Teste');
    });
  });
}
