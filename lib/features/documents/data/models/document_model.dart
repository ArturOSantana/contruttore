import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.projectId,
    required super.type,
    required super.name,
    required super.fileUrl,
    super.expiryDate,
    super.notes,
    required super.createdAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      projectId: map['projectId'] ?? '',
      type: DocumentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DocumentType.other,
      ),
      name: map['name'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'type': type.name,
      'name': name,
      'fileUrl': fileUrl,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Made with Bob
