import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:contruttore/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:contruttore/features/home/presentation/cubit/home_state.dart';
import 'package:contruttore/features/alerts/domain/usecases/generate_alerts_usecase.dart';

/// Cubit responsável por gerenciar o estado da tela Home
@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;
  final GenerateAlertsUseCase _generateAlertsUseCase;

  HomeCubit(this._getHomeDataUseCase, this._generateAlertsUseCase)
    : super(HomeInitial());

  /// Carrega os dados da Home
  Future<void> loadHomeData() async {
    print('🔵 [HomeCubit] Iniciando carregamento da Home...');
    emit(HomeLoading());

    print('🔵 [HomeCubit] Chamando GetHomeDataUseCase...');
    final result = await _getHomeDataUseCase();

    result.fold(
      (failure) {
        print('❌ [HomeCubit] Erro ao carregar Home: ${failure.message}');
        emit(HomeError(failure.message));
      },
      (data) async {
        print('✅ [HomeCubit] Home carregada com sucesso!');
        print('🔵 [HomeCubit] Projeto: ${data.project.name}');
        print('🔵 [HomeCubit] Usuário: ${data.user.name}');

        // Gerar alertas automaticamente após carregar a home
        print('🔔 [HomeCubit] Gerando alertas automáticos...');
        await _generateAlertsUseCase(data.project.id);
        print('✅ [HomeCubit] Alertas gerados com sucesso!');

        emit(HomeLoaded(data));
      },
    );
  }

  /// Recarrega os dados da Home (pull-to-refresh)
  Future<void> refresh() async {
    await loadHomeData();
  }
}

// Made with Bob
