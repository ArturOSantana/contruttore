import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../entities/shopping_item_entity.dart';

@injectable
class GenerateSuggestionsUseCase {
  final Uuid _uuid;

  GenerateSuggestionsUseCase(this._uuid);

  List<ShoppingItemEntity> call({
    required String projectId,
    required int phaseNumber,
  }) {
    final suggestions = <ShoppingItemEntity>[];
    final now = DateTime.now();

    // Fase 9 - Instalações
    if (phaseNumber == 9) {
      suggestions.addAll([
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Tomadas',
          category: ShoppingCategory.electrical,
          quantity: 20,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Interruptores',
          category: ShoppingCategory.electrical,
          quantity: 10,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Fio elétrico 2,5mm',
          category: ShoppingCategory.electrical,
          quantity: 100,
          unit: 'm',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Eletrodutos',
          category: ShoppingCategory.electrical,
          quantity: 50,
          unit: 'm',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Disjuntores',
          category: ShoppingCategory.electrical,
          quantity: 8,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Torneiras',
          category: ShoppingCategory.plumbing,
          quantity: 4,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Registros',
          category: ShoppingCategory.plumbing,
          quantity: 6,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Sifão',
          category: ShoppingCategory.plumbing,
          quantity: 3,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Tubo PVC',
          category: ShoppingCategory.plumbing,
          quantity: 30,
          unit: 'm',
          isPurchased: false,
          createdAt: now,
        ),
      ]);
    }

    // Fase 10 - Revestimentos
    if (phaseNumber == 10) {
      suggestions.addAll([
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Piso',
          category: ShoppingCategory.flooring,
          quantity: 50,
          unit: 'm²',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Revestimento de banheiro',
          category: ShoppingCategory.coating,
          quantity: 20,
          unit: 'm²',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Argamassa AC-II',
          category: ShoppingCategory.coating,
          quantity: 10,
          unit: 'sc',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Rejunte',
          category: ShoppingCategory.coating,
          quantity: 5,
          unit: 'kg',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Perfis de acabamento',
          category: ShoppingCategory.coating,
          quantity: 20,
          unit: 'm',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Rodapé',
          category: ShoppingCategory.flooring,
          quantity: 40,
          unit: 'm',
          isPurchased: false,
          createdAt: now,
        ),
      ]);
    }

    // Fase 11 - Pintura
    if (phaseNumber == 11) {
      suggestions.addAll([
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Tinta acrílica',
          category: ShoppingCategory.painting,
          quantity: 20,
          unit: 'L',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Massa corrida',
          category: ShoppingCategory.painting,
          quantity: 10,
          unit: 'kg',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Selador',
          category: ShoppingCategory.painting,
          quantity: 5,
          unit: 'L',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Lixa',
          category: ShoppingCategory.painting,
          quantity: 20,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
        ShoppingItemEntity(
          id: _uuid.v4(),
          projectId: projectId,
          name: 'Fita crepe',
          category: ShoppingCategory.painting,
          quantity: 10,
          unit: 'un',
          isPurchased: false,
          createdAt: now,
        ),
      ]);
    }

    return suggestions;
  }
}

// Made with Bob
