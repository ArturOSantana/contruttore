import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/data/reform_phases_seed_data.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/phase_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';
import '../models/phase_model.dart';

@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProjectRepositoryImpl(this._firestore, this._auth);

  @override
  Future<Either<Failure, ProjectEntity>> createProject(
    ProjectEntity project,
  ) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);

      await _firestore
          .collection('projects')
          .doc(project.id)
          .set(projectModel.toMap());

      // Criar as 9 fases personalizadas baseadas no onboarding
      await _createPersonalizedPhases(project.id, project);

      // Atualizar currentProjectId no usuário
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'currentProjectId': project.id,
        });
      }

      return Right(projectModel);
    } catch (e) {
      return Left(ServerFailure('Erro ao criar projeto: $e'));
    }
  }

  /// Cria as 9 fases personalizadas baseadas no onboarding
  Future<void> _createPersonalizedPhases(
    String projectId,
    ProjectEntity project,
  ) async {
    final defaultPhases = ReformPhasesSeedData.defaultPhases;

    // Determinar qual fase está ativa baseado no momento atual
    final activePhaseNumber = _determineActivePhase(project.currentSituation);

    final batch = _firestore.batch();

    for (final phaseData in defaultPhases) {
      final phaseRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc(phaseData.id);

      // Determinar status da fase
      PhaseStatus status;
      DateTime? startDate;
      DateTime? endDate;

      if (phaseData.order < activePhaseNumber) {
        // Fases anteriores = concluídas
        status = PhaseStatus.done;
        endDate = DateTime.now().subtract(
            Duration(days: (activePhaseNumber - phaseData.order) * 30));
      } else if (phaseData.order == activePhaseNumber) {
        // Fase atual = ativa
        status = PhaseStatus.active;
        startDate = DateTime.now();
      } else {
        // Fases futuras = bloqueadas
        status = PhaseStatus.locked;
      }

      // Personalizar checklist com itens críticos do usuário
      final subtasks = _buildPersonalizedChecklist(
        phaseData,
        project.criticalItems,
      );

      final phaseModel = PhaseModel(
        id: phaseData.id,
        projectId: projectId,
        number: phaseData.order,
        name: phaseData.name,
        description: phaseData.description,
        status: status,
        startDate: startDate,
        endDate: endDate,
        estimatedDurationDays: 30,
        subtasks: subtasks,
        commonMistake: phaseData.commonMistakes,
        expectedSupplierTypes: phaseData.recommendedProfessionals,
        expectedPurchaseCategories: phaseData.suggestedPurchases,
        expectedDocumentTypes: phaseData.expectedDocuments,
      );

      batch.set(phaseRef, phaseModel.toMap());
    }

    await batch.commit();
  }

  /// Determina qual fase deve estar ativa baseado no momento atual do usuário
  int _determineActivePhase(String currentSituation) {
    switch (currentSituation) {
      case 'not_received_keys':
        return 1; // Planejamento da Reforma
      case 'just_received':
        return 2; // Aprovações e Preparação
      case 'planning':
        return 2; // Aprovações e Preparação
      case 'work_started':
        return 3; // Infraestrutura (obra começou)
      case 'finishing':
        return 7; // Acabamentos
      case 'living':
        return 9; // Mudança e Decoração
      default:
        return 1; // Padrão: Planejamento
    }
  }

  /// Constrói checklist personalizado com itens críticos do usuário
  List<SubtaskModel> _buildPersonalizedChecklist(
    PhaseData phaseData,
    List<String> criticalItems,
  ) {
    final subtasks = phaseData.checklist
        .map((item) => SubtaskModel(
              id: item.id,
              name: item.name,
              isDone: false,
              isRequired: item.mandatory,
            ))
        .toList();

    // Se for a fase de Infraestrutura, adicionar itens críticos
    if (phaseData.id == 'infraestrutura' && criticalItems.isNotEmpty) {
      // Ar-condicionado
      if (criticalItems.contains('air_conditioning') &&
          !subtasks.any((s) => s.id == 'ar_condicionado')) {
        subtasks.add(const SubtaskModel(
          id: 'ar_condicionado',
          name: 'Infraestrutura ar-condicionado',
          isDone: false,
          isRequired: true, // Torna obrigatório!
        ));
      }

      // Internet cabeada
      if (criticalItems.contains('wired_internet') &&
          !subtasks.any((s) => s.id == 'internet')) {
        subtasks.add(const SubtaskModel(
          id: 'internet',
          name: 'Cabeamento de internet',
          isDone: false,
          isRequired: true,
        ));
      }

      // Lava-louças
      if (criticalItems.contains('dishwasher') &&
          !subtasks.any((s) => s.id == 'lava_loucas')) {
        subtasks.add(const SubtaskModel(
          id: 'lava_loucas',
          name: 'Ponto para lava-louças',
          isDone: false,
          isRequired: true,
        ));
      }

      // Aquecedor
      if (criticalItems.contains('water_heater') &&
          !subtasks.any((s) => s.id == 'aquecedor')) {
        subtasks.add(const SubtaskModel(
          id: 'aquecedor',
          name: 'Instalação de aquecedor',
          isDone: false,
          isRequired: true,
        ));
      }

      // Automação
      if (criticalItems.contains('automation') &&
          !subtasks.any((s) => s.id == 'automacao')) {
        subtasks.add(const SubtaskModel(
          id: 'automacao',
          name: 'Pontos de automação residencial',
          isDone: false,
          isRequired: true,
        ));
      }

      // Fechadura eletrônica
      if (criticalItems.contains('smart_lock') &&
          !subtasks.any((s) => s.id == 'fechadura_eletronica')) {
        subtasks.add(const SubtaskModel(
          id: 'fechadura_eletronica',
          name: 'Preparação para fechadura eletrônica',
          isDone: false,
          isRequired: true,
        ));
      }

      // Câmeras
      if (criticalItems.contains('cameras') &&
          !subtasks.any((s) => s.id == 'cameras')) {
        subtasks.add(const SubtaskModel(
          id: 'cameras',
          name: 'Pontos para câmeras de segurança',
          isDone: false,
          isRequired: true,
        ));
      }

      // Som ambiente
      if (criticalItems.contains('sound_system') &&
          !subtasks.any((s) => s.id == 'som_ambiente')) {
        subtasks.add(const SubtaskModel(
          id: 'som_ambiente',
          name: 'Cabeamento para som ambiente',
          isDone: false,
          isRequired: true,
        ));
      }

      // Carregador para carro elétrico
      if (criticalItems.contains('ev_charger') &&
          !subtasks.any((s) => s.id == 'carregador_ev')) {
        subtasks.add(const SubtaskModel(
          id: 'carregador_ev',
          name: 'Ponto para carregador de carro elétrico',
          isDone: false,
          isRequired: true,
        ));
      }

      // Aspiração central
      if (criticalItems.contains('central_vacuum') &&
          !subtasks.any((s) => s.id == 'aspiracao_central')) {
        subtasks.add(const SubtaskModel(
          id: 'aspiracao_central',
          name: 'Tubulação para aspiração central',
          isDone: false,
          isRequired: true,
        ));
      }
    }

    return subtasks;
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final projects =
          snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data())).toList();

      return Right(projects);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar projetos: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getProject(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();

      if (!doc.exists) {
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final project = ProjectModel.fromMap(doc.data()!);
      return Right(project);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProject(ProjectEntity project) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);

      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(projectModel.toMap());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar projeto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      // Buscar o projeto para obter o userId
      final projectDoc =
          await _firestore.collection('projects').doc(projectId).get();

      if (!projectDoc.exists) {
        return Left(ServerFailure('Projeto não encontrado'));
      }

      final userId = projectDoc.data()?['userId'] as String?;

      // Deletar o projeto
      await _firestore.collection('projects').doc(projectId).delete();

      // Se este era o projeto atual do usuário, limpar o currentProjectId
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final currentProjectId = userDoc.data()?['currentProjectId'] as String?;

        if (currentProjectId == projectId) {
          await _firestore.collection('users').doc(userId).update({
            'currentProjectId': null,
          });
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar projeto: $e'));
    }
  }
}

// Made with Bob
