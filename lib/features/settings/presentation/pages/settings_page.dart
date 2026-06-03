import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/app_settings_cubit.dart';
import '../cubit/app_settings_state.dart';
import '../../../../core/widgets/confirmation_dialog.dart';

/// Página de Configurações
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Carregar configurações ao abrir a página
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<AppSettingsCubit>().loadSettings(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Redirecionar para login após logout
            context.go(RouteNames.login);
          }
        },
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Seção: Projeto
            _SectionHeader(title: 'Projeto Atual'),
            _SettingsTile(
              icon: Icons.edit,
              title: 'Editar Informações do Projeto',
              subtitle: 'Nome, endereço, orçamento e datas',
              onTap: () => context.push(RouteNames.editProject),
            ),
            _SettingsTile(
              icon: Icons.folder_open,
              title: 'Trocar de Projeto',
              subtitle: 'Alternar entre seus projetos',
              onTap: () => context.push(RouteNames.projects),
            ),
            SizedBox(height: AppSpacing.lg),

            // Seção: Conta
            _SectionHeader(title: 'Conta'),
            _SettingsTile(
              icon: Icons.person,
              title: 'Perfil',
              subtitle: 'Editar nome e email',
              onTap: () => context.push('/settings/edit-profile'),
            ),
            _SettingsTile(
              icon: Icons.lock,
              title: 'Alterar Senha',
              subtitle: 'Trocar sua senha de acesso',
              onTap: () => context.push('/settings/change-password'),
            ),
            SizedBox(height: AppSpacing.lg),

            // Seção: Notificações
            _SectionHeader(title: 'Notificações'),
            BlocBuilder<AppSettingsCubit, AppSettingsState>(
              builder: (context, state) {
                if (state is AppSettingsLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is AppSettingsLoaded) {
                  return Column(
                    children: [
                      _SettingsSwitchTile(
                        icon: Icons.notifications_active,
                        title: 'Notificações Push',
                        subtitle: 'Receber notificações no dispositivo',
                        value: state.settings.notificationsEnabled,
                        onChanged: (value) {
                          context.read<AppSettingsCubit>().updateSetting(
                            'notificationsEnabled',
                            value,
                          );
                        },
                      ),
                      _SettingsSwitchTile(
                        icon: Icons.warning_amber,
                        title: 'Alertas de Obra',
                        subtitle: 'Parcelas, documentos e prazos',
                        value: state.settings.alertsEnabled,
                        onChanged: (value) {
                          context.read<AppSettingsCubit>().updateSetting(
                            'alertsEnabled',
                            value,
                          );
                        },
                      ),
                      _SettingsSwitchTile(
                        icon: Icons.school,
                        title: 'Dicas Educativas',
                        subtitle: 'Receber dicas sobre construção',
                        value: state.settings.educationalAlertsEnabled,
                        onChanged: (value) {
                          context.read<AppSettingsCubit>().updateSetting(
                            'educationalAlertsEnabled',
                            value,
                          );
                        },
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: AppSpacing.lg),

            // Seção: Sobre
            _SectionHeader(title: 'Sobre'),
            _SettingsTile(
              icon: Icons.info,
              title: 'Sobre o Costruttore',
              subtitle: 'Versão 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),
            _SettingsTile(
              icon: Icons.description,
              title: 'Termos de Uso',
              subtitle: 'Leia nossos termos',
              onTap: () {
                // TODO: Abrir termos de uso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.privacy_tip,
              title: 'Política de Privacidade',
              subtitle: 'Como tratamos seus dados',
              onTap: () {
                // TODO: Abrir política de privacidade
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.lg),

            // Botão de Logout
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textInverse,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sair da Conta',
      message:
          'Tem certeza que deseja sair? Você precisará fazer login novamente.',
      confirmLabel: 'Sair',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.construction, color: AppColors.primary, size: 32),
            SizedBox(width: AppSpacing.sm),
            const Text('Costruttore'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão 1.0.0',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Seu parceiro para gerenciar a obra do apartamento na planta.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              '© 2026 Costruttore',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho de seção
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
        top: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Tile de configuração
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}

/// Tile de configuração com switch
class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}

// Made with Bob
