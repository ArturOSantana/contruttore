import '../models/sinapi_reference.dart';

/// Dados de exemplo do SINAPI para referência
/// Em produção, estes dados viriam de uma planilha atualizada mensalmente
final List<SinapiReference> sinapiSeedData = [
  // ELÉTRICA
  SinapiReference(
    code: '74209/001',
    description: 'Ponto de luz, interruptor simples',
    unit: 'un',
    unitPrice: 45.32,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),
  SinapiReference(
    code: '74209/002',
    description: 'Ponto de tomada 2P+T',
    unit: 'un',
    unitPrice: 38.76,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),
  SinapiReference(
    code: '74209/003',
    description: 'Quadro de distribuição 12 disjuntores',
    unit: 'un',
    unitPrice: 487.23,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),

  // HIDRÁULICA
  SinapiReference(
    code: '74220/001',
    description: 'Ponto de água fria PVC',
    unit: 'un',
    unitPrice: 52.18,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),
  SinapiReference(
    code: '74220/002',
    description: 'Ponto de esgoto PVC',
    unit: 'un',
    unitPrice: 48.95,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),

  // REVESTIMENTOS
  SinapiReference(
    code: '87879',
    description: 'Revestimento cerâmico para parede',
    unit: 'm²',
    unitPrice: 68.42,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),
  SinapiReference(
    code: '87880',
    description: 'Revestimento porcelanato para piso',
    unit: 'm²',
    unitPrice: 89.76,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),

  // PINTURA
  SinapiReference(
    code: '88489',
    description: 'Pintura acrílica em parede, 2 demãos',
    unit: 'm²',
    unitPrice: 12.34,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),
  SinapiReference(
    code: '88490',
    description: 'Massa corrida em parede',
    unit: 'm²',
    unitPrice: 8.76,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),

  // MARCENARIA
  SinapiReference(
    code: '92551',
    description: 'Armário de cozinha planejado',
    unit: 'm',
    unitPrice: 1250.00,
    state: 'SP',
    referenceMonth: DateTime(2024, 1),
  ),
];

// Made with Bob
