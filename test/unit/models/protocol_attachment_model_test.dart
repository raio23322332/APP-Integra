import 'package:flutter_test/flutter_test.dart';
import 'package:integra_app/data/models/protocol_attachment_model.dart';

void main() {
  group('ProtocolAttachmentModel', () {
    test('should create ProtocolAttachmentModel from JSON', () {
      // Arrange
      final json = {
        'id': 'attachment-1',
        'protocol_id': 'protocol-1',
        'protocol_appendix_id': 'appendix-1',
        'category': 'Documento',
        'disk': 'tenant_protocols',
        'path': '/path/to/file.pdf',
        'directory': 'uploads',
        'original_name': 'documento_original.pdf',
        'filename': 'documento.pdf',
        'extension': 'pdf',
        'mime_type': 'application/pdf',
        'size': 1024,
        'uploaded_by': 'user-1',
        'created_at': '2024-01-01T10:00:00Z',
        'updated_at': '2024-01-01T11:00:00Z',
        'url': 'https://example.com/file.pdf',
      };

      // Act
      final attachment = ProtocolAttachmentModel.fromJson(json);

      // Assert
      expect(attachment.id, 'attachment-1');
      expect(attachment.protocolId, 'protocol-1');
      expect(attachment.protocolAppendixId, 'appendix-1');
      expect(attachment.category, 'Documento');
      expect(attachment.disk, 'tenant_protocols');
      expect(attachment.path, '/path/to/file.pdf');
      expect(attachment.directory, 'uploads');
      expect(attachment.originalName, 'documento_original.pdf');
      expect(attachment.filename, 'documento.pdf');
      expect(attachment.extension, 'pdf');
      expect(attachment.mimeType, 'application/pdf');
      expect(attachment.size, 1024);
      expect(attachment.uploadedBy, 'user-1');
      expect(attachment.createdAt, '2024-01-01T10:00:00Z');
      expect(attachment.updatedAt, '2024-01-01T11:00:00Z');
      expect(attachment.url, 'https://example.com/file.pdf');
    });

    test('should handle null and missing values in JSON with defaults', () {
      // Arrange
      final json = {
        'id': 'attachment-1',
        'original_name': '',
        'filename': '',
        'size': 0,
      };

      // Act
      final attachment = ProtocolAttachmentModel.fromJson(json);

      // Assert
      expect(attachment.id, 'attachment-1');
      expect(attachment.protocolId, null);
      expect(attachment.protocolAppendixId, null);
      expect(attachment.category, 'Documento'); // default value
      expect(attachment.disk, 'tenant_protocols'); // default value
      expect(attachment.path, ''); // default value
      expect(attachment.directory, null);
      expect(attachment.originalName, '');
      expect(attachment.filename, '');
      expect(attachment.extension, null);
      expect(attachment.mimeType, null);
      expect(attachment.size, 0);
      expect(attachment.uploadedBy, null);
      expect(attachment.createdAt, null);
      expect(attachment.updatedAt, null);
      expect(attachment.url, null);
    });

    test('should convert ProtocolAttachmentModel to JSON', () {
      // Arrange
      final attachment = ProtocolAttachmentModel(
        id: 'attachment-1',
        protocolId: 'protocol-1',
        protocolAppendixId: 'appendix-1',
        category: 'Documento',
        disk: 'tenant_protocols',
        path: '/path/to/file.pdf',
        directory: 'uploads',
        originalName: 'documento_original.pdf',
        filename: 'documento.pdf',
        extension: 'pdf',
        mimeType: 'application/pdf',
        size: 1024,
        uploadedBy: 'user-1',
        createdAt: '2024-01-01T10:00:00Z',
        updatedAt: '2024-01-01T11:00:00Z',
        url: 'https://example.com/file.pdf',
      );

      // Act
      final json = attachment.toJson();

      // Assert
      expect(json['id'], 'attachment-1');
      expect(json['protocol_id'], 'protocol-1');
      expect(json['protocol_appendix_id'], 'appendix-1');
      expect(json['category'], 'Documento');
      expect(json['disk'], 'tenant_protocols');
      expect(json['path'], '/path/to/file.pdf');
      expect(json['directory'], 'uploads');
      expect(json['original_name'], 'documento_original.pdf');
      expect(json['filename'], 'documento.pdf');
      expect(json['extension'], 'pdf');
      expect(json['mime_type'], 'application/pdf');
      expect(json['size'], 1024);
      expect(json['uploaded_by'], 'user-1');
      expect(json['created_at'], '2024-01-01T10:00:00Z');
      expect(json['updated_at'], '2024-01-01T11:00:00Z');
      expect(json['url'], 'https://example.com/file.pdf');
    });

    test('should return correct formatted size for different values', () {
      // Test bytes
      final smallAttachment = ProtocolAttachmentModel(
        id: '1',
        category: 'Test',
        disk: 'test',
        path: '/test',
        originalName: 'small.txt',
        filename: 'small.txt',
        size: 512,
      );
      expect(smallAttachment.formattedSize, '512 B');

      // Test kilobytes
      final mediumAttachment = ProtocolAttachmentModel(
        id: '2',
        category: 'Test',
        disk: 'test',
        path: '/test',
        originalName: 'medium.pdf',
        filename: 'medium.pdf',
        size: 1536, // 1.5 KB
      );
      expect(mediumAttachment.formattedSize, '1.5 KB');

      // Test megabytes
      final largeAttachment = ProtocolAttachmentModel(
        id: '3',
        category: 'Test',
        disk: 'test',
        path: '/test',
        originalName: 'large.mp4',
        filename: 'large.mp4',
        size: 2097152, // 2 MB
      );
      expect(largeAttachment.formattedSize, '2.0 MB');
    });

    test('should return correct file extension', () {
      // Test with explicit extension
      final attachmentWithExtension = ProtocolAttachmentModel(
        id: '1',
        category: 'Test',
        disk: 'test',
        path: '/test',
        originalName: 'document.pdf',
        filename: 'document.pdf',
        extension: 'pdf',
        size: 1024,
      );
      expect(attachmentWithExtension.fileExtension, 'PDF');

      // Test with extension in filename
      final attachmentWithoutExtension = ProtocolAttachmentModel(
        id: '2',
        category: 'Test',
        disk: 'test',
        path: '/test',
        originalName: 'image.jpg',
        filename: 'image.jpg',
        size: 1024,
      );
      expect(attachmentWithoutExtension.fileExtension, 'JPG');

      // Test with no extension
      final attachmentNoExtension = ProtocolAttachmentModel(
        id: '3',
        category: 'Test',
        disk: 'test',
        path: '/test',
        originalName: 'file',
        filename: 'file',
        size: 1024,
      );
      expect(attachmentNoExtension.fileExtension, 'FILE');

      // Test with multiple dots in filename
      final attachmentMultipleDots = ProtocolAttachmentModel(
        id: '4',
        category: 'Test',
        disk: 'test',
        path: '/test',
        originalName: 'archive.tar.gz',
        filename: 'archive.tar.gz',
        size: 1024,
      );
      expect(attachmentMultipleDots.fileExtension, 'GZ');
    });
  });
}
