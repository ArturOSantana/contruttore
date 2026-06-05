import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/problem_entity.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para adicionar um problema na reforma
///
/// Quando algo dá errado na reforma, você registra aqui.
///
/// Exemplos de problemas:
/// - Vazamento na cozinha
/// - Porcelanato chegou errado
/// - Eletricista atrasou 5 dias
/// - Parede ficou torta
/// - Material com defeito
///
/// O que acontece quando você adiciona um problema:
/// 1. Fica registrado no histórico
/// 2. Aparece no Mapa da Reforma
/// 3. Impacta a "saúde" da reforma
/// 4. Pode gerar uma ação urgente
/// 5. Fica vinculado à fase onde aconteceu
///
/// Você pode:
/// - Marcar como resolvido depois
/// - Adicionar fotos do problema
/// - Calcular quanto custou resolver
/// - Ver quanto tempo perdeu
@injectable
class AddProblemUseCase implements UseCase<ProblemEntity, ProblemEntity> {
  final ReformMapRepository repository;

  AddProblemUseCase(this.repository);

  @override
  Future<Either<Failure, ProblemEntity>> call(ProblemEntity problem) async {
    return await repository.addProblem(problem);
  }
}

// Made with Bob
