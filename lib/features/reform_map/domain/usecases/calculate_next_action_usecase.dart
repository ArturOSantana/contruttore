import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/next_action_entity.dart';
import '../repositories/reform_map_repository.dart';

/// Use case para calcular a próxima ação recomendada
///
/// Este é o "cérebro" do Mapa da Reforma.
/// Ele analisa tudo que está acontecendo e diz:
/// "Faça isso agora!"
///
/// Como funciona:
/// 1. Olha todas as parcelas - alguma vencendo?
/// 2. Olha os problemas - tem algo crítico?
/// 3. Olha as compras - falta algo importante?
/// 4. Olha os fornecedores - precisa contratar alguém?
/// 5. Olha os documentos - falta guardar algo?
///
/// Resultado: UMA ação por vez
/// Não mostra 10 coisas para fazer.
/// Mostra a MAIS IMPORTANTE agora.
///
/// Exemplo de ações:
/// - "Pagar parcela do porcelanato" (vence amanhã!)
/// - "Contratar eletricista" (fase elétrica começou)
/// - "Comprar quadro elétrico" (obra parada sem isso)
/// - "Guardar ART do eletricista" (documento obrigatório)
@injectable
class CalculateNextActionUseCase implements UseCase<NextActionEntity?, String> {
  final ReformMapRepository repository;

  CalculateNextActionUseCase(this.repository);

  @override
  Future<Either<Failure, NextActionEntity?>> call(String projectId) async {
    return await repository.calculateNextAction(projectId);
  }
}

// Made with Bob
