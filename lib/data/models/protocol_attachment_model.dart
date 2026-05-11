class ProtocolAttachmentModel {
  final String id;
  final String? protocolId;
  final String? protocolAppendixId;
  final String category;
  final String disk;
  final String path;
  final String? directory;
  final String originalName;
  final String filename;
  final String? extension;
  final String? mimeType;
  final int size;
  final String? uploadedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? url;

  const ProtocolAttachmentModel({
    required this.id,
    this.protocolId,
    this.protocolAppendixId,
    required this.category,
    required this.disk,
    required this.path,
    this.directory,
    required this.originalName,
    required this.filename,
    this.extension,
    this.mimeType,
    required this.size,
    this.uploadedBy,
    this.createdAt,
    this.updatedAt,
    this.url,
  });

  factory ProtocolAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ProtocolAttachmentModel(
      id: json['id'] as String? ?? '',
      protocolId: json['protocol_id'] as String?,
      protocolAppendixId: json['protocol_appendix_id'] as String?,
      category: json['category'] as String? ?? 'Documento',
      disk: json['disk'] as String? ?? 'tenant_protocols',
      path: json['path'] as String? ?? '',
      directory: json['directory'] as String?,
      originalName: json['original_name'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      extension: json['extension'] as String?,
      mimeType: json['mime_type'] as String?,
      size: json['size'] as int? ?? 0,
      uploadedBy: json['uploaded_by'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'protocol_id': protocolId,
      'protocol_appendix_id': protocolAppendixId,
      'category': category,
      'disk': disk,
      'path': path,
      'directory': directory,
      'original_name': originalName,
      'filename': filename,
      'extension': extension,
      'mime_type': mimeType,
      'size': size,
      'uploaded_by': uploadedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'url': url,
    };
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get fileExtension {
    if (extension != null) return extension!.toUpperCase();
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
  }
}
