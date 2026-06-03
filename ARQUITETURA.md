# 🏗️ Arquitetura do Costruttore

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Clean Architecture](#clean-architecture)
3. [Camadas](#camadas)
4. [Fluxo de Dados](#fluxo-de-dados)
5. [State Management](#state-management)
6. [Dependency Injection](#dependency-injection)
7. [Navegação](#navegação)
8. [Persistência](#persistência)
9. [Padrões de Código](#padrões-de-código)
10. [Boas Práticas](#boas-práticas)

---

## 🎯 Visão Geral

O Costruttore segue os princípios da **Clean Architecture** proposta por Robert C. Martin (Uncle Bob), com adaptações para o ecossistema Flutter.

### Princípios Fundamentais

1. **Separação de Responsabilidades**: Cada camada tem uma responsabilidade clara
2. **Independência de Frameworks**: A lógica de negócio não depende do Flutter
3. **Testabilidade**: Todas as camadas podem ser testadas isoladamente
4. **Independência de UI**: A UI pode mudar sem afetar a lógica
5. **Independência de Banco de Dados**: Podemos trocar Firebase por outro sem afetar a lógica

### Diagrama de Camadas

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (Pages, Widgets, Cubits, States)      │
│                                         │
│  Responsabilidade: UI e State          │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│           DOMAIN LAYER                  │
│  (Entities, Repositories, Use Cases)   │
│                                         │
│  Responsabilidade: Regras de Negócio   │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│            DATA LAYER                   │
│  (Models, Repository Impl, Data Sources)│
│                                         │
│  Responsabilidade: Acesso a Dados      │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│         EXTERNAL SOURCES                │
│    (Firebase, Hive, APIs Externas)     │
└─────────────────────────────────────────┘
```

---

## 🏛️ Clean Architecture

### Regra de Dependência

**A regra mais importante**: As dependências sempre apontam para dentro.

```
Presentation → Domain ← Data
```

- **Presentation** depende de **Domain**
- **Data** depende de **Domain**
- **Domain** não depende de ninguém (núcleo puro)

### Por que Clean Architecture?

1. **Manutenibilidade**: Código organizado e fácil de entender
2. **Escalabilidade**: Fácil adicionar novas features
3. **Testabilidade**: Cada camada pode ser testada isoladamente
4. **Flexibilidade**: Fácil trocar implementações (ex: Firebase → Supabase)
5. **Reusabilidade**: Use cases podem ser reutilizados em diferentes UIs

---

## 📦 Camadas

### 1. Domain Layer (Núcleo)

**Localização**: `lib/features/{feature}/domain/`

**Responsabilidade**: Contém a lógica de negócio pura, independente de frameworks.

#### Entities (Entidades)

```dart
// lib/features/financial/domain/entities/expense_entity.dart

class ExpenseEntity extends Equatable {
  final String id;
  final String projectId;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String description;
  final ExpenseStatus status;
  
  const ExpenseEntity({
    required this.id,
    required this.projectId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
  });
  
  @override
  List<Object?> get props => [id, projectId, categoryId, amount, date, description, status];
}
```

**Características**:
- Objetos puros de negócio
- Sem dependências externas
- Imutáveis (final fields)
- Extends Equatable para comparação

#### Repositories (Interfaces)

```dart
// lib/features/financial/domain/repositories/expense_repository.dart

abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String projectId);
  Future<Either<Failure, ExpenseEntity>> getExpenseById(String projectId, String expenseId);
  Future<Either<Failure, void>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> updateExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String projectId, String expenseId);
}
```

**Características**:
- Apenas interfaces (abstract class)
- Retorna Either<Failure, Success> (dartz)
- Não sabe nada sobre implementação

#### Use Cases (Casos de Uso)

```dart
// lib/features/financial/domain/usecases/add_expense_usecase.dart

@injectable
class AddExpenseUseCase implements UseCase<void, ExpenseEntity> {
  final ExpenseRepository repository;
  
  AddExpenseUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(ExpenseEntity expense) async {
    // Validações de negócio
    if (expense.amount <= 0) {
      return Left(ValidationFailure('Valor deve ser maior que zero'));
    }
    
    if (expense.projectId.isEmpty) {
      return Left(ValidationFailure('Projeto é obrigatório'));
    }
    
    // Delega para o repository
    return await repository.addExpense(expense);
  }
}
```

**Características**:
- Uma responsabilidade por use case
- Contém regras de negócio
- Reutilizável em diferentes contextos
- Injetável via GetIt

---

### 2. Data Layer (Implementação)

**Localização**: `lib/features/{feature}/data/`

**Responsabilidade**: Implementa as interfaces do Domain e acessa fontes de dados.

#### Models (Modelos)

```dart
// lib/features/financial/data/models/expense_model.dart

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.projectId,
    required super.categoryId,
    required super.amount,
    required super.date,
    required super.description,
    required super.status,
  });
  
  // Conversão de/para Map (Firestore)
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      categoryId: map['categoryId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] as String,
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExpenseStatus.estimated,
      ),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'categoryId': categoryId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'status': status.name,
    };
  }
  
  // Conversão de/para Entity
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      projectId: entity.projectId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      date: entity.date,
      description: entity.description,
      status: entity.status,
    );
  }
}
```

**Características**:
- Extends Entity
- Métodos toMap() e fromMap()
- Lida com serialização/deserialização
- Conversão entre Entity e Model

#### Repository Implementation

```dart
// lib/features/financial/data/repositories/expense_repository_impl.dart

@Injectable(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore firestore;
  final HiveInterface hive;
  
  ExpenseRepositoryImpl(this.firestore, this.hive);
  
  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(String projectId) async {
    try {
      // Tenta buscar do cache primeiro (offline-first)
      final box = await hive.openBox<Map>('expenses_$projectId');
      if (box.isNotEmpty) {
        final cached = box.values
            .map((map) => ExpenseModel.fromMap(Map<String, dynamic>.from(map)))
            .toList();
        
        // Busca do Firebase em background
        _syncFromFirebase(projectId);
        
        return Right(cached);
      }
      
      // Se não tem cache, busca do Firebase
      final snapshot = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();
      
      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()))
          .toList();
      
      // Salva no cache
      await _cacheExpenses(projectId, expenses);
      
      return Right(expenses);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao buscar despesas'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> addExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      
      await firestore
          .collection('projects')
          .doc(expense.projectId)
          .collection('expenses')
          .doc(expense.id)
          .set(model.toMap());
      
      // Atualiza cache
      await _addToCache(expense.projectId, model);
      
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erro ao adicionar despesa'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  // Métodos privados de cache
  Future<void> _cacheExpenses(String projectId, List<ExpenseModel> expenses) async {
    final box = await hive.openBox<Map>('expenses_$projectId');
    await box.clear();
    for (final expense in expenses) {
      await box.put(expense.id, expense.toMap());
    }
  }
  
  Future<void> _addToCache(String projectId, ExpenseModel expense) async {
    final box = await hive.openBox<Map>('expenses_$projectId');
    await box.put(expense.id, expense.toMap());
  }
  
  Future<void> _syncFromFirebase(String projectId) async {
    // Implementação de sync em background
  }
}
```

**Características**:
- Implementa interface do Domain
- Acessa Firebase e Hive
- Estratégia offline-first
- Tratamento de erros
- Injetável via GetIt

---

### 3. Presentation Layer (UI)

**Localização**: `lib/features/{feature}/presentation/`

**Responsabilidade**: Gerencia estado e renderiza UI.

#### States (Estados)

```dart
// lib/features/financial/presentation/cubit/financial_state.dart

abstract class FinancialState extends Equatable {
  const FinancialState();
  
  @override
  List<Object?> get props => [];
}

class FinancialInitial extends FinancialState {}

class FinancialLoading extends FinancialState {}

class FinancialLoaded extends FinancialState {
  final List<ExpenseEntity> expenses;
  final double totalConfirmed;
  final double totalCommitted;
  final double totalEstimated;
  final double budget;
  
  const FinancialLoaded({
    required this.expenses,
    required this.totalConfirmed,
    required this.totalCommitted,
    required this.totalEstimated,
    required this.budget,
  });
  
  @override
  List<Object?> get props => [expenses, totalConfirmed, totalCommitted, totalEstimated, budget];
}

class FinancialError extends FinancialState {
  final String message;
  
  const FinancialError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class FinancialOperationSuccess extends FinancialState {
  final String message;
  
  const FinancialOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**Características**:
- Estados imutáveis
- Extends Equatable
- Estados específicos para cada situação

#### Cubit (Gerenciador de Estado)

```dart
// lib/features/financial/presentation/cubit/financial_cubit.dart

@injectable
class FinancialCubit extends Cubit<FinancialState> {
  final GetExpensesUseCase _getExpensesUseCase;
  final AddExpenseUseCase _addExpenseUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final GetProjectUseCase _getProjectUseCase;
  
  FinancialCubit(
    this._getExpensesUseCase,
    this._addExpenseUseCase,
    this._updateExpenseUseCase,
    this._deleteExpenseUseCase,
    this._getProjectUseCase,
  ) : super(FinancialInitial());
  
  Future<void> loadFinancialData(String projectId) async {
    emit(FinancialLoading());
    
    // Busca despesas
    final expensesResult = await _getExpensesUseCase(projectId);
    
    // Busca projeto (para orçamento)
    final projectResult = await _getProjectUseCase(projectId);
    
    // Combina resultados
    final result = expensesResult.fold(
      (failure) => Left(failure),
      (expenses) => projectResult.fold(
        (failure) => Left(failure),
        (project) => Right((expenses, project)),
      ),
    );
    
    result.fold(
      (failure) => emit(FinancialError(failure.message)),
      (data) {
        final expenses = data.$1;
        final project = data.$2;
        
        // Calcula totais
        final totalConfirmed = expenses
            .where((e) => e.status == ExpenseStatus.confirmed)
            .fold(0.0, (sum, e) => sum + e.amount);
        
        final totalCommitted = expenses
            .where((e) => e.status == ExpenseStatus.committed)
            .fold(0.0, (sum, e) => sum + e.amount);
        
        final totalEstimated = expenses
            .where((e) => e.status == ExpenseStatus.estimated)
            .fold(0.0, (sum, e) => sum + e.amount);
        
        emit(FinancialLoaded(
          expenses: expenses,
          totalConfirmed: totalConfirmed,
          totalCommitted: totalCommitted,
          totalEstimated: totalEstimated,
          budget: project.totalBudget,
        ));
      },
    );
  }
  
  Future<void> addExpense(ExpenseEntity expense) async {
    final result = await _addExpenseUseCase(expense);
    
    result.fold(
      (failure) => emit(FinancialError(failure.message)),
      (_) {
        emit(const FinancialOperationSuccess('Despesa adicionada com sucesso'));
        loadFinancialData(expense.projectId);
      },
    );
  }
  
  Future<void> deleteExpense(String projectId, String expenseId) async {
    final result = await _deleteExpenseUseCase(
      DeleteExpenseParams(projectId: projectId, expenseId: expenseId),
    );
    
    result.fold(
      (failure) => emit(FinancialError(failure.message)),
      (_) {
        emit(const FinancialOperationSuccess('Despesa excluída com sucesso'));
        loadFinancialData(projectId);
      },
    );
  }
}
```

**Características**:
- Extends Cubit<State>
- Injeta use cases
- Emite estados
- Lógica de apresentação (cálculos, formatação)

#### Pages (Telas)

```dart
// lib/features/financial/presentation/pages/financial_page.dart

class FinancialPage extends StatelessWidget {
  final String projectId;
  
  const FinancialPage({super.key, required this.projectId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financeiro'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocConsumer<FinancialCubit, FinancialState>(
        listener: (context, state) {
          if (state is FinancialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          
          if (state is FinancialOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is FinancialLoading) {
            return const LoadingWidget();
          }
          
          if (state is FinancialError) {
            return ErrorWidgetCustom(
              message: state.message,
              onRetry: () => context.read<FinancialCubit>().loadFinancialData(projectId),
            );
          }
          
          if (state is FinancialLoaded) {
            return _buildContent(context, state);
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, FinancialLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<FinancialCubit>().loadFinancialData(projectId),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _buildSummaryCard(state),
          const SizedBox(height: AppSpacing.l),
          _buildExpensesList(state.expenses),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(FinancialLoaded state) {
    final progress = state.totalConfirmed / state.budget;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Text('Resumo Financeiro', style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gasto:', style: AppTextStyles.bodyMedium),
              Text(
                CurrencyUtils.format(state.totalConfirmed),
                style: AppTextStyles.moneyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orçamento:', style: AppTextStyles.bodyMedium),
              Text(
                CurrencyUtils.format(state.budget),
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ProgressBar(
            value: progress,
            showPercentage: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpensesList(List<ExpenseEntity> expenses) {
    if (expenses.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long,
        title: 'Nenhuma despesa',
        message: 'Adicione sua primeira despesa',
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Despesas', style: AppTextStyles.headingMedium),
        const SizedBox(height: AppSpacing.m),
        ...expenses.map((expense) => _buildExpenseCard(expense)),
      ],
    );
  }
  
  Widget _buildExpenseCard(ExpenseEntity expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: ListTile(
        title: Text(expense.description),
        subtitle: Text(AppDateUtils.formatDate(expense.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyUtils.format(expense.amount),
              style: AppTextStyles.moneyMedium,
            ),
            StatusBadge.expenseStatus(expense.status.name),
          ],
        ),
        onTap: () => _navigateToExpenseDetail(expense),
      ),
    );
  }
  
  Future<void> _navigateToAddExpense(BuildContext context) async {
    await context.push('${RouteNames.expenseCreate}?projectId=$projectId');
    if (context.mounted) {
      context.read<FinancialCubit>().loadFinancialData(projectId);
    }
  }
  
  void _navigateToExpenseDetail(ExpenseEntity expense) {
    // Implementação
  }
}
```

**Características**:
- StatelessWidget (estado no Cubit)
- BlocConsumer para listener + builder
- RefreshIndicator para pull-to-refresh
- Navegação com await + reload
- Widgets reutilizáveis

---

## 🔄 Fluxo de Dados

### Fluxo Completo (Exemplo: Adicionar Despesa)

```
1. USER ACTION
   └─> Usuário clica em "Salvar" no formulário

2. PRESENTATION LAYER
   └─> Page chama: context.read<FinancialCubit>().addExpense(expense)
       └─> Cubit emite: FinancialLoading()
           └─> Cubit chama: _addExpenseUseCase(expense)

3. DOMAIN LAYER
   └─> AddExpenseUseCase valida regras de negócio
       └─> Se válido, chama: repository.addExpense(expense)

4. DATA LAYER
   └─> ExpenseRepositoryImpl converte Entity → Model
       └─> Salva no Firebase: firestore.collection(...).doc(...).set(...)
       └─> Salva no cache: hive.box.put(...)
       └─> Retorna: Right(null) ou Left(Failure)

5. DOMAIN LAYER
   └─> UseCase retorna resultado para Cubit

6. PRESENTATION LAYER
   └─> Cubit recebe resultado
       └─> Se sucesso: emite FinancialOperationSuccess()
       └─> Se erro: emite FinancialError()
       └─> Recarrega dados: loadFinancialData()

7. UI UPDATE
   └─> BlocBuilder reconstrói widget
       └─> Mostra mensagem de sucesso/erro
       └─> Atualiza lista de despesas
```

### Fluxo Offline-First

```
1. USER REQUEST
   └─> Usuário abre tela de despesas

2. REPOSITORY
   └─> Verifica cache local (Hive)
       ├─> Se tem cache:
       │   └─> Retorna dados do cache imediatamente
       │       └─> Sincroniza com Firebase em background
       │
       └─> Se não tem cache:
           └─> Busca do Firebase
               └─> Salva no cache
               └─> Retorna dados

3. UI
   └─> Mostra dados (cache ou Firebase)
       └─> Atualiza quando sync completa (se houver diferença)
```

---

## 🎭 State Management

### Por que Cubit (não BLoC)?

**Cubit** é mais simples que BLoC para a maioria dos casos:

```dart
// Cubit: métodos diretos
cubit.loadData();
cubit.addItem(item);
cubit.deleteItem(id);

// BLoC: eventos
bloc.add(LoadDataEvent());
bloc.add(AddItemEvent(item));
bloc.add(DeleteItemEvent(id));
```

**Quando usar BLoC**:
- Lógica complexa com múltiplos eventos
- Necessidade de transformers (debounce, throttle)
- Replay de eventos

**Quando usar Cubit** (nosso caso):
- Lógica simples e direta
- CRUD básico
- Menos boilerplate

### Padrão de Estados

Sempre ter pelo menos 4 estados:

```dart
abstract class FeatureState {}

class FeatureInitial extends FeatureState {}

class FeatureLoading extends FeatureState {}

class FeatureLoaded extends FeatureState {
  final Data data;
}

class FeatureError extends FeatureState {
  final String message;
}
```

Estados adicionais conforme necessário:

```dart
class FeatureOperationSuccess extends FeatureState {
  final String message;
}

class FeatureEmpty extends FeatureState {}
```

---

## 💉 Dependency Injection

### GetIt + Injectable

**Setup** (`lib/injection_container.dart`):

```dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

**Registro Automático**:

```dart
// Repository
@Injectable(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore firestore;
  final HiveInterface hive;
  
  ExpenseRepositoryImpl(this.firestore, this.hive);
}

// Use Case
@injectable
class AddExpenseUseCase {
  final ExpenseRepository repository;
  
  AddExpenseUseCase(this.repository);
}

// Cubit
@injectable
class FinancialCubit extends Cubit<FinancialState> {
  final GetExpensesUseCase _getExpensesUseCase;
  final AddExpenseUseCase _addExpenseUseCase;
  
  FinancialCubit(this._getExpensesUseCase, this._addExpenseUseCase) 
      : super(FinancialInitial());
}
```

**Uso**:

```dart
// No router
BlocProvider(
  create: (context) => getIt<FinancialCubit>()..loadFinancialData(projectId),
  child: FinancialPage(projectId: projectId),
)
```

### Módulos Externos

```dart
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;
  
  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;
}

@module
abstract class HiveModule {
  @preResolve
  Future<HiveInterface> get hive async {
    await Hive.initFlutter();
    return Hive;
  }
}
```

---

## 🧭 Navegação

### GoRouter

**Configuração** (`lib/app/router/app_router.dart`):

```dart
final router = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.financial,
      name: 'financial',
      builder: (context, state) => const _FinancialPageWrapper(),
    ),
    GoRoute(
      path: RouteNames.expenseCreate,
      name: 'expense-create',
      builder: (context, state) {
        final projectId = state.uri.queryParameters['projectId'] ?? '';
        return BlocProvider(
          create: (context) => getIt<FinancialCubit>()..loadFinancialData(projectId),
          child: AddExpensePage(projectId: projectId),
        );
      },
    ),
  ],
);
```

**Navegação com Reload**:

```dart
// SEMPRE usar await + reload
Future<void> _navigateToAddExpense(BuildContext context) async {
  await context.push('${RouteNames.expenseCreate}?projectId=$projectId');
  
  if (context.mounted) {
    context.read<FinancialCubit>().loadFinancialData(projectId);
  }
}
```

**Wrappers para BlocProvider**:

```dart
class _FinancialPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final projectId = snapshot.data?.fold(
          (failure) => '',
          (user) => user?.currentProjectId ?? '',
        ) ?? '';
        
        return BlocProvider(
          create: (context) => getIt<FinancialCubit>()..loadFinancialData(projectId),
          child: FinancialPage(projectId: projectId),
        );
      },
    );
  }
}
```

---

## 💾 Persistência

### Estratégia Offline-First

```
┌─────────────┐
│   REQUEST   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  CACHE?     │◄─── Hive (Local)
└──────┬──────┘
       │
       ├─ YES ──► Return Cache + Sync Background
       │
       └─ NO ───► Fetch Firebase + Save Cache
```

### Hive (Cache Local)

```dart
// Abrir box
final box = await hive.openBox<Map>('expenses_$projectId');

// Salvar
await box.put(expense.id, expense.toMap());

// Buscar
final map = box.get(expense.id);
final expense = ExpenseModel.fromMap(Map<String, dynamic>.from(map));

// Listar todos
final expenses = box.values
    .map((map) => ExpenseModel.fromMap(Map<String, dynamic>.from(map)))
    .toList();

// Limpar
await box.clear();
```

### Firebase (Fonte da Verdade)

```dart
// Buscar coleção
final snapshot = await firestore
    .collection('projects')
    .doc(projectId)
    .collection('expenses')
    .orderBy('date', descending: true)
    .get();

// Buscar documento
final doc = await firestore
    .collection('projects')
    .doc(projectId)
    .collection('expenses')
    .doc(expenseId)
    .get();

// Criar/Atualizar
await firestore
    .collection('projects')
    .doc(projectId)
    .collection('expenses')
    .doc(expenseId)
    .set(data);

// Deletar
await firestore
    .collection('projects')
    .doc(projectId)
    .collection('expenses')
    .doc(expenseId)
    .delete();

// Listener em tempo real
firestore
    .collection('projects')
    .doc(projectId)
    .collection('expenses')
    .snapshots()
    .listen((snapshot) {
      // Atualizar UI
    });
```

---

## 📝 Padrões de Código

### Nomenclatura

```dart
// Classes: PascalCase
class ExpenseEntity {}
class FinancialCubit {}

// Arquivos: snake_case
expense_entity.dart
financial_cubit.dart

// Variáveis e métodos: camelCase
final totalAmount = 0.0;
void loadFinancialData() {}

// Constantes: lowerCamelCase
const maxRetries = 3;

// Enums: PascalCase (tipo) + camelCase (valores)
enum ExpenseStatus { confirmed, committed, estimated }
```

### Organização de Imports

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:io';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Packages externos
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// 4. Imports internos (relativos)
import '../../domain/entities/expense_entity.dart';
import '../cubit/financial_cubit.dart';
```

### Comentários

```dart
/// Documentação de classe (três barras)
/// 
/// Explica o propósito da classe e como usá-la.
class ExpenseEntity {
  /// Documentação de propriedade
  final String id;
  
  // Comentário de implementação (duas barras)
  // Explica detalhes internos
  void _privateMethod() {
    // TODO: Implementar validação
  }
}
```

---

## ✅ Boas Práticas

### 1. Sempre Validar Entrada

```dart
// ❌ Ruim
Future<void> addExpense(ExpenseEntity expense) async {
  await repository.addExpense(expense);
}

// ✅ Bom
Future<Either<Failure, void>> addExpense(ExpenseEntity expense) async {
  if (expense.amount <= 0) {
    return Left(ValidationFailure('Valor inválido'));
  }
  
  if (expense.projectId.isEmpty) {
    return Left(ValidationFailure('Projeto obrigatório'));
  }
  
  return await repository.addExpense(expense);
}
```

### 2. Tratar Todos os Erros

```dart
// ❌ Ruim
final expenses = await repository.getExpenses(projectId);
emit(FinancialLoaded(expenses));

// ✅ Bom
final result = await repository.getExpenses(projectId);
result.fold(
  (failure) => emit(FinancialError(failure.message)),
  (expenses) => emit(FinancialLoaded(expenses)),
);
```

### 3. Usar Const Sempre que Possível

```dart
// ❌ Ruim
return SizedBox(height: 16);

// ✅ Bom
return const SizedBox(height: AppSpacing.m);
```

### 4. Extrair Widgets Complexos

```dart
// ❌ Ruim
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info),
            SizedBox(width: 8),
            Text('Mensagem'),
          ],
        ),
      ),
    ],
  );
}

// ✅ Bom
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildInfoCard(),
    ],
  );
}

Widget _buildInfoCard() {
  return Container(
    padding: const EdgeInsets.all(AppSpacing.m),
    child: Row(
      children: [
        const Icon(Icons.info),
        const SizedBox(width: AppSpacing.xs),
        const Text('Mensagem'),
      ],
    ),
  );
}
```

### 5. Usar Extension Methods

```dart
// lib/core/extensions/string_extensions.dart
extension StringExtensions on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// Uso
if (email.isValidEmail) {
  // ...
}
```

### 6. Usar Sealed Classes para Estados

```dart
// ❌ Ruim
abstract class FinancialState {}
class FinancialLoading extends FinancialState {}
class FinancialLoaded extends FinancialState {}

// ✅ Bom (Dart 3.0+)
sealed class FinancialState {}
class FinancialLoading extends FinancialState {}
class FinancialLoaded extends FinancialState {}

// Benefício: exhaustive checking
switch (state) {
  case FinancialLoading():
    return LoadingWidget();
  case FinancialLoaded():
    return ContentWidget();
  // Compilador garante que todos os casos estão cobertos
}
```

### 7. Usar Records para Retornos Múltiplos

```dart
// ❌ Ruim
class FinancialSummary {
  final double total;
  final int count;
  FinancialSummary(this.total, this.count);
}

// ✅ Bom (Dart 3.0+)
(double total, int count) calculateSummary(List<Expense> expenses) {
  final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
  return (total, expenses.length);
}

// Uso
final (total, count) = calculateSummary(expenses);
```

---

## 🎯 Conclusão

Esta arquitetura garante:

✅ **Separação clara de responsabilidades**
✅ **Código testável e manutenível**
✅ **Fácil adicionar novas features**
✅ **Independência de frameworks**
✅ **Escalabilidade**

**Lembre-se**: A arquitetura é um meio, não um fim. O objetivo é entregar valor ao usuário com código de qualidade.

---

**Última atualização**: 02/06/2026
**Versão**: 1.0.0