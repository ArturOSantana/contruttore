import 'package:equatable/equatable.dart';

/// Fornecedor cadastrado rapidamente no onboarding retroativo
class QuickSupplier extends Equatable {
  final String id;
  final String name;
  final String type; // 'eletricista' | 'pedreiro' | 'marceneiro' | etc
  final String status; // 'active' | 'problem'

  const QuickSupplier({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
  });

  QuickSupplier copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
  }) {
    return QuickSupplier(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, name, type, status];
}

// Made with Bob
