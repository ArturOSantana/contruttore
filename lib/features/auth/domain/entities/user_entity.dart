import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? currentProjectId;
  final DateTime createdAt;
  final String? fcmToken;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.currentProjectId,
    required this.createdAt,
    this.fcmToken,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? currentProjectId,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    currentProjectId,
    createdAt,
    fcmToken,
  ];
}

// Made with Bob
