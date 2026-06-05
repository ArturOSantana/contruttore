import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:contruttore/app/theme/app_colors.dart';
import 'package:contruttore/app/theme/app_spacing.dart';
import 'package:contruttore/app/theme/app_text_styles.dart';
import 'package:contruttore/app/router/route_names.dart';
import 'package:contruttore/features/home/presentation/cubit/home_cubit.dart';
import 'package:contruttore/features/home/presentation/cubit/home_state.dart';
import 'package:contruttore/features/home/domain/entities/home_data_entity.dart';
import 'package:contruttore/features/home/domain/entities/next_action_entity.dart';
import 'package:contruttore/features/home/domain/entities/financial_summary_entity.dart';
import 'package:contruttore/features/home/domain/entities/alert_entity.dart';
import 'package:contruttore/features/home/domain/entities/weather_entity.dart';
import 'package:contruttore/core/utils/currency_utils.dart';

/// Tela Home - Hub central do aplicativo
/// Responde "O que está acontecendo?" e "O que devo fazer agora?"
class HomePage extends StatefulWidget {
  final String? refreshKey;

  const HomePage({super.key, this.refreshKey});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _lastRefreshKey;

  @override
  void initState() {
    super.initState();
    _lastRefreshKey = widget.refreshKey;
    // Carregar dados da home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().loadHomeData();
    });
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o refreshKey mudou, recarregar
    if (widget.refreshKey != _lastRefreshKey) {
      _lastRefreshKey = widget.refreshKey;
      context.read<HomeCubit>().loadHomeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return _buildErrorState(state.message);
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(state.data),
                    SizedBox(height: AppSpacing.lg),
                    if (state.data.nextAction != null) ...[
                      _buildNextActionCard(state.data.nextAction!),
                      SizedBox(height: AppSpacing.lg),
                    ],
                    _buildFinancialSummary(state.data.financialSummary),
                    SizedBox(height: AppSpacing.lg),
                    if (state.data.activeAlerts.isNotEmpty) ...[
                      _buildActiveAlerts(state.data.activeAlerts),
                      SizedBox(height: AppSpacing.lg),
                    ],
                    _buildModulesGrid(),
                    SizedBox(height: AppSpacing.lg),
                    if (state.data.weather != null)
                      _buildWeatherWarning(state.data.weather!),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Costruttore',
        style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        // Badge de notificações
        IconButton(
          icon: Badge(
            label: const Text('3'),
            backgroundColor: AppColors.error,
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () => context.push(RouteNames.alerts),
        ),
        // Avatar do usuário
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.md),
          child: GestureDetector(
            onTap: () => context.push(RouteNames.settings),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 18,
              child: const Icon(
                Icons.person,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(HomeDataEntity data) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    final firstName = data.user.name.split(' ').first;
    final monthsUntilDelivery = _calculateMonthsUntilDelivery(
      data.project.deliveryDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, $firstName', style: AppTextStyles.headlineLarge),
        SizedBox(height: AppSpacing.xs),
        Text(
          '${data.project.name} · Entrega em $monthsUntilDelivery meses',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  int _calculateMonthsUntilDelivery(DateTime deliveryDate) {
    final now = DateTime.now();
    final difference = deliveryDate.difference(now);
    return (difference.inDays / 30).ceil();
  }

  Widget _buildNextActionCard(NextActionEntity action) {
    return Card(
      elevation: AppSpacing.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () => context.push(action.route),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.primary,
                    size: AppSpacing.iconSm,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'PRÓXIMA AÇÃO',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(action.title, style: AppTextStyles.titleLarge),
              SizedBox(height: AppSpacing.xs),
              Text(
                '${action.deadline != null ? "Prazo: ${action.deadline} · " : ""}${action.phaseName ?? ""}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'VER DETALHES',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(FinancialSummaryEntity summary) {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () => context.push(RouteNames.financial),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumo Financeiro', style: AppTextStyles.titleMedium),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Total comprometido: ${CurrencyUtils.format(summary.totalCommitted)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: LinearProgressIndicator(
                  value: summary.percentage / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    summary.percentage > 80
                        ? AppColors.warning
                        : AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                '${summary.percentage.toStringAsFixed(0)}% do orçamento',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Clique para ver detalhes',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAlerts(List<AlertEntity> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alertas Ativos', style: AppTextStyles.titleMedium),
        SizedBox(height: AppSpacing.sm),
        ...alerts.map(
          (alert) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Card(
              elevation: AppSpacing.elevationSm,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(
                  color: _getAlertColor(alert.priority),
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: alert.actionRoute != null
                    ? () => context.push(alert.actionRoute!)
                    : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        _getAlertIcon(alert.type),
                        color: _getAlertColor(alert.priority),
                        size: AppSpacing.iconMd,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          alert.title,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      if (alert.actionRoute != null)
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: AppSpacing.iconSm,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return AppColors.error;
      case AlertPriority.high:
        return AppColors.warning;
      case AlertPriority.medium:
        return AppColors.info;
      case AlertPriority.low:
        return AppColors.textSecondary;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.payment:
        return Icons.payment;
      case AlertType.task:
        return Icons.task_alt;
      case AlertType.phase:
        return Icons.construction;
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.document:
        return Icons.description;
      case AlertType.other:
        return Icons.info_outline;
    }
  }

  Widget _buildModulesGrid() {
    final modules = [
      {
        'icon': Icons.map,
        'label': 'Mapa da Reforma',
        'route': RouteNames.reformMap
      },
      {
        'icon': Icons.attach_money,
        'label': 'Financeiro',
        'route': RouteNames.financial,
      },
      {
        'icon': Icons.people,
        'label': 'Fornecedores',
        'route': RouteNames.suppliers,
      },
      {'icon': Icons.book, 'label': 'Diário', 'route': RouteNames.diary},
      {
        'icon': Icons.shopping_cart,
        'label': 'Compras',
        'route': RouteNames.shopping,
      },
      {
        'icon': Icons.favorite,
        'label': 'Desejos',
        'route': RouteNames.wishlist,
      },
      {
        'icon': Icons.payment,
        'label': 'Parcelas',
        'route': RouteNames.payments,
      },
      {
        'icon': Icons.description,
        'label': 'Documentos',
        'route': RouteNames.documents,
      },
      {
        'icon': Icons.menu_book,
        'label': 'Glossário',
        'route': RouteNames.glossary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          elevation: AppSpacing.elevationSm,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: InkWell(
            onTap: () => context.push(module['route'] as String),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  module['icon'] as IconData,
                  size: AppSpacing.iconLg,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  module['label'] as String,
                  style: AppTextStyles.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherWarning(WeatherEntity weather) {
    return Card(
      color: weather.isCritical ? AppColors.warningLight : AppColors.infoLight,
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.cloud,
              color: weather.isCritical ? AppColors.warning : AppColors.info,
              size: AppSpacing.iconMd,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weather.warning, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              'Erro ao carregar dados',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            // Já está na home
            break;
          case 1:
            context.push(RouteNames.reformMap);
            break;
          case 2:
            context.push(RouteNames.financial);
            break;
          case 3:
            context.push(RouteNames.suppliers);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Financeiro',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Fornecedores',
        ),
      ],
    );
  }
}

// Made with Bob
