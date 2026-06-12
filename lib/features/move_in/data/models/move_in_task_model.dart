import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/move_in_task_entity.dart';

/// Modelo Firestore para tarefas do Modo Mudança
class MoveInTaskModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'essentials', 'utilities', 'cleaning', etc
  final bool isCompleted;
  final bool isCritical;
  final bool isCustom; // true se foi adicionado pelo usuário
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoveInTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isCompleted,
    required this.isCritical,
    required this.isCustom,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converte para entidade de domínio
  MoveInTaskEntity toEntity() {
    return MoveInTaskEntity(
      id: id,
      title: title,
      description: description,
      category: _categoryFromString(category),
      isCompleted: isCompleted,
      isCritical: isCritical,
      isCustom: isCustom,
      dueDate: dueDate,
      completedAt: completedAt,
    );
  }

  /// Cria a partir de entidade de domínio
  factory MoveInTaskModel.fromEntity(MoveInTaskEntity entity) {
    return MoveInTaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: _categoryToString(entity.category),
      isCompleted: entity.isCompleted,
      isCritical: entity.isCritical,
      isCustom: entity.isCustom,
      dueDate: entity.dueDate,
      completedAt: entity.completedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Cria a partir do Firestore
  factory MoveInTaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoveInTaskModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      isCompleted: data['isCompleted'] as bool,
      isCritical: data['isCritical'] as bool,
      isCustom: data['isCustom'] as bool? ?? false,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Converte para Map do Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
      'isCritical': isCritical,
      'isCustom': isCustom,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Converte string para categoria
  static MoveInTaskCategory _categoryFromString(String category) {
    switch (category) {
      case 'essentials':
        return MoveInTaskCategory.essentials;
      case 'utilities':
        return MoveInTaskCategory.utilities;
      case 'cleaning':
        return MoveInTaskCategory.cleaning;
      case 'inspection':
        return MoveInTaskCategory.inspection;
      case 'documentation':
        return MoveInTaskCategory.documentation;
      case 'moving':
        return MoveInTaskCategory.moving;
      case 'decoration':
        return MoveInTaskCategory.decoration;
      default:
        return MoveInTaskCategory.essentials;
    }
  }

  /// Converte categoria para string
  static String _categoryToString(MoveInTaskCategory category) {
    switch (category) {
      case MoveInTaskCategory.essentials:
        return 'essentials';
      case MoveInTaskCategory.utilities:
        return 'utilities';
      case MoveInTaskCategory.cleaning:
        return 'cleaning';
      case MoveInTaskCategory.inspection:
        return 'inspection';
      case MoveInTaskCategory.documentation:
        return 'documentation';
      case MoveInTaskCategory.moving:
        return 'moving';
      case MoveInTaskCategory.decoration:
        return 'decoration';
    }
  }

  /// Cria cópia com alterações
  MoveInTaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    bool? isCritical,
    bool? isCustom,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoveInTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isCritical: isCritical ?? this.isCritical,
      isCustom: isCustom ?? this.isCustom,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Made with Bob
