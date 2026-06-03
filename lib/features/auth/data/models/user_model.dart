import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.currentProjectId,
    required super.createdAt,
    super.fcmToken,
  });

  /// Cria um UserModel a partir de um Map (Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      currentProjectId: map['currentProjectId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      fcmToken: map['fcmToken'] as String?,
    );
  }

  /// Cria um UserModel a partir de um Firebase User
  factory UserModel.fromFirebaseUser(
    firebase_auth.User user, {
    String? name,
    String? currentProjectId,
    String? fcmToken,
  }) {
    return UserModel(
      id: user.uid,
      name: name ?? user.displayName ?? user.email?.split('@')[0] ?? 'Usuário',
      email: user.email!,
      currentProjectId: currentProjectId,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      fcmToken: fcmToken,
    );
  }

  /// Converte o UserModel para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currentProjectId': currentProjectId,
      'createdAt': createdAt.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  /// Cria uma cópia do UserModel com campos atualizados
  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? currentProjectId,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

// Made with Bob
