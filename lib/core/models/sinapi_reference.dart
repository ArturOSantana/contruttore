import 'package:equatable/equatable.dart';

/// Referência de preço SINAPI para comparação
class SinapiReference extends Equatable {
  final String code;
  final String description;
  final String unit;
  final double unitPrice;
  final String state; // UF
  final DateTime referenceMonth;

  const SinapiReference({
    required this.code,
    required this.description,
    required this.unit,
    required this.unitPrice,
    required this.state,
    required this.referenceMonth,
  });

  @override
  List<Object?> get props => [
    code,
    description,
    unit,
    unitPrice,
    state,
    referenceMonth,
  ];

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'unit': unit,
      'unitPrice': unitPrice,
      'state': state,
      'referenceMonth': referenceMonth.toIso8601String(),
    };
  }

  factory SinapiReference.fromMap(Map<String, dynamic> map) {
    return SinapiReference(
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      state: map['state'] ?? 'SP',
      referenceMonth: DateTime.parse(map['referenceMonth']),
    );
  }
}

// Made with Bob
