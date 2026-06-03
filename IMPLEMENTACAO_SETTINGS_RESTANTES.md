# 📋 Implementação - Métodos Restantes do Settings

## 🎯 Objetivo
Implementar as funcionalidades pendentes na página de Settings:
1. Trocar de Projeto
2. Editar Perfil
3. Alterar Senha

---

## 1. TROCAR DE PROJETO

### Arquitetura Necessária

#### 1.1 Use Case - SwitchProjectUseCase
**Arquivo**: `lib/features/auth/domain/usecases/switch_project_usecase.dart`

```dart
class SwitchProjectUseCase {
  final AuthRepository _authRepository;
  
  Future<Either<Failure, void>> call(String projectId) async {
    return await _authRepository.switchProject(projectId);
  }
}
```

#### 1.2 Método no AuthRepository
**Arquivo**: `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
Future<Either<Failure, void>> switchProject(String projectId);
```

**Implementação**: `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
@override
Future<Either<Failure, void>> switchProject(String projectId) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw ServerException('Usuário não autenticado');
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'currentProjectId': projectId});
    
    return const Right(null);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### 1.3 ProjectsListPage
**Arquivo**: `lib/features/projects/presentation/pages/projects_list_page.dart`

**Funcionalidades**:
- Lista todos os projetos do usuário
- Mostra projeto atual com badge "Ativo"
- Botão "Selecionar" em cada projeto
- Botão "Criar Novo Projeto" (vai para onboarding)

#### 1.4 ProjectsListCubit
**Arquivo**: `lib/features/projects/presentation/cubit/projects_list_cubit.dart`

**Estados**:
```dart
abstract class ProjectsListState extends Equatable {}
class ProjectsListInitial extends ProjectsListState {}
class ProjectsListLoading extends ProjectsListState {}
class ProjectsListLoaded extends ProjectsListState {
  final List<ProjectEntity> projects;
  final String currentProjectId;
}
class ProjectsListError extends ProjectsListState {
  final String message;
}
```

**Métodos**:
- `loadProjects()` - Busca todos os projetos do usuário
- `switchProject(String projectId)` - Troca projeto ativo

---

## 2. EDITAR PERFIL

### Arquitetura Necessária

#### 2.1 Use Case - UpdateProfileUseCase
**Arquivo**: `lib/features/auth/domain/usecases/update_profile_usecase.dart`

```dart
class UpdateProfileUseCase {
  final AuthRepository _authRepository;
  
  Future<Either<Failure, void>> call({
    required String name,
    String? photoUrl,
  }) async {
    return await _authRepository.updateProfile(
      name: name,
      photoUrl: photoUrl,
    );
  }
}
```

#### 2.2 Método no AuthRepository
```dart
Future<Either<Failure, void>> updateProfile({
  required String name,
  String? photoUrl,
});
```

**Implementação**:
```dart
@override
Future<Either<Failure, void>> updateProfile({
  required String name,
  String? photoUrl,
}) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw ServerException('Usuário não autenticado');
    
    // Atualizar Firebase Auth
    await user.updateDisplayName(name);
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    
    // Atualizar Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
    
    return const Right(null);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### 2.3 EditProfilePage
**Arquivo**: `lib/features/settings/presentation/pages/edit_profile_page.dart`

**Campos**:
- Nome (obrigatório)
- Email (somente leitura)
- Foto de perfil (opcional - usar image_picker)

**Botões**:
- Salvar
- Cancelar

---

## 3. ALTERAR SENHA

### Arquitetura Necessária

#### 3.1 Use Case - ChangePasswordUseCase
**Arquivo**: `lib/features/auth/domain/usecases/change_password_usecase.dart`

```dart
class ChangePasswordUseCase {
  final AuthRepository _authRepository;
  
  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
```

#### 3.2 Método no AuthRepository
```dart
Future<Either<Failure, void>> changePassword({
  required String currentPassword,
  required String newPassword,
});
```

**Implementação**:
```dart
@override
Future<Either<Failure, void>> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw ServerException('Usuário não autenticado');
    
    // Reautenticar usuário
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    
    // Alterar senha
    await user.updatePassword(newPassword);
    
    return const Right(null);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      return const Left(ServerFailure('Senha atual incorreta'));
    }
    return Left(ServerFailure(e.message ?? 'Erro ao alterar senha'));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### 3.3 ChangePasswordPage
**Arquivo**: `lib/features/settings/presentation/pages/change_password_page.dart`

**Campos**:
- Senha atual (obrigatório, obscureText)
- Nova senha (obrigatório, obscureText, mínimo 6 caracteres)
- Confirmar nova senha (obrigatório, deve ser igual à nova senha)

**Validações**:
- Senha atual não pode estar vazia
- Nova senha mínimo 6 caracteres
- Confirmar senha deve ser igual à nova senha
- Nova senha deve ser diferente da atual

**Botões**:
- Salvar
- Cancelar

---

## 📋 Ordem de Implementação

### Fase 1: Trocar de Projeto (PRIORIDADE ALTA)
1. ✅ Adicionar método `switchProject` no AuthRepository
2. ✅ Criar SwitchProjectUseCase
3. ✅ Criar GetUserProjectsUseCase
4. ✅ Criar ProjectsListCubit
5. ✅ Criar ProjectsListPage
6. ✅ Adicionar rota `/projects`
7. ✅ Atualizar botão "Trocar de Projeto" em Settings
8. ✅ Testar fluxo completo

### Fase 2: Editar Perfil
1. ✅ Adicionar método `updateProfile` no AuthRepository
2. ✅ Criar UpdateProfileUseCase
3. ✅ Criar EditProfilePage
4. ✅ Adicionar rota `/settings/profile`
5. ✅ Atualizar botão "Editar Perfil" em Settings
6. ✅ Testar fluxo completo

### Fase 3: Alterar Senha
1. ✅ Adicionar método `changePassword` no AuthRepository
2. ✅ Criar ChangePasswordUseCase
3. ✅ Criar ChangePasswordPage
4. ✅ Adicionar rota `/settings/change-password`
5. ✅ Atualizar botão "Alterar Senha" em Settings
6. ✅ Testar fluxo completo

---

## 🧪 Testes Necessários

### Trocar de Projeto
- [ ] Lista mostra todos os projetos do usuário
- [ ] Projeto atual tem badge "Ativo"
- [ ] Consegue trocar para outro projeto
- [ ] Após trocar, Home recarrega com dados do novo projeto
- [ ] Todas as páginas mostram dados do projeto correto

### Editar Perfil
- [ ] Campos preenchidos com dados atuais
- [ ] Consegue alterar nome
- [ ] Consegue adicionar/alterar foto
- [ ] Dados salvos no Firebase Auth e Firestore
- [ ] Nome atualizado aparece na Home

### Alterar Senha
- [ ] Valida senha atual
- [ ] Valida nova senha (mínimo 6 caracteres)
- [ ] Valida confirmação de senha
- [ ] Erro se senha atual incorreta
- [ ] Sucesso ao alterar senha
- [ ] Consegue fazer login com nova senha

---

## 📁 Arquivos a Criar/Modificar

### Novos Arquivos
1. `lib/features/auth/domain/usecases/switch_project_usecase.dart`
2. `lib/features/auth/domain/usecases/update_profile_usecase.dart`
3. `lib/features/auth/domain/usecases/change_password_usecase.dart`
4. `lib/features/projects/domain/usecases/get_user_projects_usecase.dart`
5. `lib/features/projects/presentation/cubit/projects_list_cubit.dart`
6. `lib/features/projects/presentation/cubit/projects_list_state.dart`
7. `lib/features/projects/presentation/pages/projects_list_page.dart`
8. `lib/features/settings/presentation/pages/edit_profile_page.dart`
9. `lib/features/settings/presentation/pages/change_password_page.dart`

### Arquivos a Modificar
1. `lib/features/auth/domain/repositories/auth_repository.dart` - Adicionar 3 métodos
2. `lib/features/auth/data/repositories/auth_repository_impl.dart` - Implementar 3 métodos
3. `lib/app/router/route_names.dart` - Adicionar 3 rotas
4. `lib/app/router/app_router.dart` - Configurar 3 rotas
5. `lib/features/settings/presentation/pages/settings_page.dart` - Atualizar botões
6. `lib/injection_container.dart` - Registrar novos use cases

---

**Estimativa de Tempo**: 2-3 horas
**Complexidade**: Média
**Prioridade**: Alta (funcionalidade essencial)