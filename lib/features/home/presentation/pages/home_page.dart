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
              color: AppColors.primary,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.md,
                ),
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
                    if (state.data.weather != null) ...[
                      SizedBox(height: AppSpacing.lg),
                      _buildWeatherWarning(state.data.weather!),
                    ],
                    SizedBox(height: AppSpacing.xxl),
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
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.construction,
              size: AppSpacing.iconSm,
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Costruttore',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        // Badge de notificações
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final alertCount =
                state is HomeLoaded ? state.data.activeAlerts.length : 0;

            return IconButton(
              icon: Badge(
                label: Text('$alertCount'),
                backgroundColor: AppColors.error,
                isLabelVisible: alertCount > 0,
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
              onPressed: () => context.push(RouteNames.alerts),
              tooltip: 'Notificações',
            );
          },
        ),
        // Avatar do usuário
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.md),
          child: GestureDetector(
            onTap: () => context.push(RouteNames.settings),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: AppSpacing.iconSm,
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
    String emoji;
    if (hour < 12) {
      greeting = 'Bom dia';
      emoji = '☀️';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
      emoji = '🌤️';
    } else {
      greeting = 'Boa noite';
      emoji = '🌙';
    }

    final firstName = data.user.name.split(' ').first;
    final monthsUntilDelivery = _calculateMonthsUntilDelivery(
      data.project.deliveryDate,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: AppColors.gradientSubtle,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $firstName',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      data.project.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: AppSpacing.iconXs,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Entrega em $monthsUntilDelivery meses',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateMonthsUntilDelivery(DateTime deliveryDate) {
    final now = DateTime.now();
    final difference = deliveryDate.difference(now);
    return (difference.inDays / 30).ceil();
  }

  Widget _buildNextActionCard(NextActionEntity action) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        Icons.bolt,
                        color: AppColors.textOnPrimary,
                        size: AppSpacing.iconSm,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'PRÓXIMA AÇÃO',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  action.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (action.deadline != null || action.phaseName != null) ...[
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (action.deadline != null) ...[
                        Icon(
                          Icons.schedule,
                          size: AppSpacing.iconXs,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppSpacing.xxs),
                        Text(
                          action.deadline!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (action.deadline != null && action.phaseName != null)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          child: Text(
                            '·',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      if (action.phaseName != null)
                        Expanded(
                          child: Text(
                            action.phaseName!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
                SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Ver detalhes',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.accent,
                      size: AppSpacing.iconSm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(FinancialSummaryEntity summary) {
    final percentage = summary.percentage;
    final isWarning = percentage > 80;
    final color = isWarning ? AppColors.warning : AppColors.green;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(RouteNames.financial),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resumo Financeiro',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  CurrencyUtils.format(summary.totalCommitted),
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'Total comprometido',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'do orçamento total',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Ver detalhes',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xxs),
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
        'icon': Icons.map_outlined,
        'label': 'Mapa',
        'route': RouteNames.reformMap,
        'color': AppColors.blue,
      },
      {
        'icon': Icons.attach_money,
        'label': 'Financeiro',
        'route': RouteNames.financial,
        'color': AppColors.green,
      },
      {
        'icon': Icons.people_outline,
        'label': 'Fornecedores',
        'route': RouteNames.suppliers,
        'color': AppColors.purple,
      },
      {
        'icon': Icons.book_outlined,
        'label': 'Diário',
        'route': RouteNames.diary,
        'color': AppColors.accent,
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'label': 'Compras',
        'route': RouteNames.shopping,
        'color': AppColors.rose,
      },
      {
        'icon': Icons.favorite_outline,
        'label': 'Desejos',
        'route': RouteNames.wishlist,
        'color': AppColors.rose,
      },
      {
        'icon': Icons.payment,
        'label': 'Parcelas',
        'route': RouteNames.payments,
        'color': AppColors.green,
      },
      {
        'icon': Icons.description_outlined,
        'label': 'Documentos',
        'route': RouteNames.documents,
        'color': AppColors.blue,
      },
      {
        'icon': Icons.menu_book_outlined,
        'label': 'Glossário',
        'route': RouteNames.glossary,
        'color': AppColors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ferramentas',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            final color = module['color'] as Color;

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(module['route'] as String),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Icon(
                            module['icon'] as IconData,
                            size: AppSpacing.iconMd,
                            color: color,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          module['label'] as String,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall,
          currentIndex: _currentIndex,
          elevation: 0,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Financeiro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Fornecedores',
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
