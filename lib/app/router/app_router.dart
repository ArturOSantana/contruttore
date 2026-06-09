import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/tutorial/presentation/pages/tutorial_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_choice_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_14_steps_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_results_page.dart';
import '../../features/onboarding/presentation/pages/reform_risks_page.dart';
import '../../features/onboarding/presentation/pages/retroactive_onboarding_page.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/onboarding/presentation/cubit/retroactive_cubit.dart';
import '../../features/projects/presentation/pages/phases_page.dart';
import '../../features/projects/presentation/pages/phase_detail_page.dart';
import '../../features/projects/presentation/cubit/phases_cubit.dart';
import '../../features/projects/domain/entities/phase_entity.dart';
import '../../features/reform_map/presentation/pages/reform_map_page.dart';
import '../../features/reform_map/presentation/pages/report_problem_page.dart';
import '../../features/reform_map/presentation/cubit/reform_map_cubit.dart';
import '../../features/alerts/presentation/cubit/alerts_cubit.dart';
import '../../features/shopping/presentation/cubit/shopping_cubit.dart';
import '../../features/suppliers/presentation/cubit/suppliers_cubit.dart';
import '../../features/installments/presentation/cubit/installments_cubit.dart';
import '../../features/payments/presentation/cubit/payments_cubit.dart';
import '../../features/diary/presentation/cubit/diary_cubit.dart';
import '../../features/financial/presentation/cubit/financial_cubit.dart';
import '../../features/wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../features/settings/presentation/cubit/app_settings_cubit.dart';
import '../../features/projects/presentation/cubit/project_cubit.dart';
import '../../features/projects/presentation/cubit/project_state.dart';
import '../../features/projects/presentation/cubit/projects_list_cubit.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/projects/presentation/pages/project_settings_page.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/financial/presentation/pages/financial_page.dart';
import '../../features/financial/presentation/pages/add_expense_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/installments/presentation/pages/installments_page.dart';
import '../../features/installments/presentation/pages/add_installment_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_page.dart';
import '../../features/suppliers/presentation/pages/add_supplier_page.dart';
import '../../features/suppliers/presentation/pages/compare_quotes_page.dart';
import '../../features/suppliers/presentation/pages/compare_suppliers_page.dart';
import '../../features/suppliers/presentation/pages/supplier_quotes_page.dart';
import '../../features/diary/presentation/pages/diary_page.dart';
import '../../features/diary/presentation/pages/add_diary_entry_page.dart';
import '../../features/shopping/presentation/pages/shopping_page.dart';
import '../../features/shopping/presentation/pages/add_shopping_item_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';
import '../../features/wishlist/presentation/pages/add_wishlist_item_page.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/glossary/presentation/pages/glossary_page.dart';
import '../../features/glossary/presentation/pages/glossary_term_page.dart';
import '../../features/glossary/presentation/cubit/glossary_cubit.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/documents/presentation/pages/add_document_page.dart';
import '../../features/documents/presentation/cubit/documents_cubit.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/edit_project_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/change_password_page.dart';
import '../../features/settings/presentation/cubit/edit_profile_cubit.dart';
import '../../features/settings/presentation/cubit/change_password_cubit.dart';
import '../../injection_container.dart';

/// Configuração de rotas do aplicativo usando GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.tutorial,
        name: 'tutorial',
        builder: (context, state) => const TutorialPage(),
      ),
      GoRoute(
        path: RouteNames.onboardingChoice,
        name: 'onboarding-choice',
        builder: (context, state) => const OnboardingChoicePage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const Onboarding14StepsPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding14Steps,
        name: 'onboarding-14',
        builder: (context, state) => const Onboarding14StepsPage(),
      ),
      GoRoute(
        path: RouteNames.onboardingResults,
        name: 'onboarding-results',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final cubit = extra?['cubit'] as OnboardingCubit?;

          if (cubit == null) {
            // Fallback: criar novo cubit se não foi passado
            final newCubit = getIt<OnboardingCubit>();
            return OnboardingResultsPage(
              cubit: newCubit,
              nextAction: extra?['nextAction'] ?? '',
              criticalAlerts: extra?['criticalAlerts'] ?? [],
              checklistsByRoom: extra?['checklistsByRoom'] ?? {},
              healthScore: extra?['healthScore'] ?? 0,
              estimatedDuration: extra?['estimatedDuration'] ?? 0,
            );
          }

          return OnboardingResultsPage(
            cubit: cubit,
            nextAction: extra?['nextAction'] ?? '',
            criticalAlerts: extra?['criticalAlerts'] ?? [],
            checklistsByRoom: extra?['checklistsByRoom'] ?? {},
            healthScore: extra?['healthScore'] ?? 0,
            estimatedDuration: extra?['estimatedDuration'] ?? 0,
          );
        },
      ),
      GoRoute(
        path: RouteNames.reformRisks,
        name: 'reform-risks',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final risks = extra?['risks'] as List? ?? [];
          final onContinue = extra?['onContinue'] as VoidCallback?;

          return ReformRisksPage(
            risks: risks.cast(),
            onContinue: onContinue ?? () => context.go(RouteNames.home),
          );
        },
      ),
      GoRoute(
        path: RouteNames.retroactiveOnboarding,
        name: 'retroactive-onboarding',
        builder: (context, state) {
          // Parâmetros vindos do onboarding normal
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (context) => getIt<RetroactiveCubit>(),
            child: RetroactiveOnboardingPage(
              userId: extra?['userId'] ?? '',
              projectName: extra?['projectName'] ?? '',
              address: extra?['address'] ?? '',
              area: extra?['area'] ?? 0.0,
              deliveryDate: extra?['deliveryDate'] ?? DateTime.now(),
              contractDate: extra?['contractDate'] ?? DateTime.now(),
              constructorName: extra?['constructorName'] ?? '',
            ),
          );
        },
      ),

      // Auth
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Home
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) {
          final refreshKey = state.uri.queryParameters['refresh'];
          return BlocProvider(
            create: (context) => getIt<HomeCubit>(),
            child: HomePage(refreshKey: refreshKey),
          );
        },
      ),

      // Reform Map (GPS da Reforma)
      GoRoute(
        path: RouteNames.reformMap,
        name: 'reform-map',
        builder: (context, state) => const _ReformMapPageWrapper(),
      ),

      // Report Problem
      GoRoute(
        path: RouteNames.reportProblem,
        name: 'report-problem',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId']!;
          final phaseId = state.uri.queryParameters['phaseId'];
          final phaseName = state.uri.queryParameters['phaseName'];

          return BlocProvider(
            create: (context) => context.read<ReformMapCubit>(),
            child: ReportProblemPage(
              projectId: projectId,
              phaseId: phaseId,
              phaseName: phaseName,
            ),
          );
        },
      ),

      // Phases (mantido para compatibilidade)
      GoRoute(
        path: RouteNames.phases,
        name: 'phases',
        builder: (context, state) => const _PhasesPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.phaseDetail,
        name: 'phase-detail',
        builder: (context, state) {
          final phaseId = state.pathParameters['id']!;
          // A fase deve ser passada via extra no GoRouter.push
          final phase = state.extra as PhaseEntity?;

          if (phase == null) {
            return const Scaffold(
              body: Center(
                child: Text('Fase não encontrada'),
              ),
            );
          }

          return PhaseDetailPage(phase: phase);
        },
      ),
      GoRoute(
        path: RouteNames.phaseCreate,
        name: 'phase-create',
        builder: (context, state) => const _PlaceholderPage(title: 'Nova Fase'),
      ),
      GoRoute(
        path: RouteNames.phaseEdit,
        name: 'phase-edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Editar Fase $id');
        },
      ),

      // Financial
      GoRoute(
        path: RouteNames.financial,
        name: 'financial',
        builder: (context, state) => const _FinancialPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.financialOverview,
        name: 'financial-overview',
        builder: (context, state) =>
            const _PlaceholderPage(title: 'Visão Financeira'),
      ),
      GoRoute(
        path: RouteNames.expenseCreate,
        name: 'expense-create',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<FinancialCubit>()..loadFinancialData(projectId),
            child: AddExpensePage(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.expenseDetail,
        name: 'expense-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Despesa $id');
        },
      ),

      // Payments (Nova tela unificada de parcelas)
      GoRoute(
        path: RouteNames.payments,
        name: 'payments',
        builder: (context, state) => const _PaymentsPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.paymentCreate,
        name: 'payment-create',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<InstallmentsCubit>()..loadInstallments(projectId),
            child: AddInstallmentPage(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.paymentDetail,
        name: 'payment-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Pagamento $id');
        },
      ),

      // Suppliers
      GoRoute(
        path: RouteNames.suppliers,
        name: 'suppliers',
        builder: (context, state) => const _SuppliersPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.supplierCreate,
        name: 'supplier-create',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<SuppliersCubit>()..loadSuppliers(projectId),
            child: AddSupplierPage(projectId: projectId),
          );
        },
      ),
      // IMPORTANTE: Rotas específicas devem vir ANTES de rotas com parâmetros dinâmicos
      GoRoute(
        path: RouteNames.compareQuotes,
        name: 'compare-quotes',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          final quoteIds = state.uri.queryParameters['quoteIds'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<SuppliersCubit>()..loadSuppliers(projectId),
            child: CompareQuotesPage(
              projectId: projectId,
              quoteIds:
                  quoteIds.split(',').where((id) => id.isNotEmpty).toList(),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.compareSuppliers,
        name: 'compare-suppliers',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          final supplierIds = state.uri.queryParameters['supplierIds'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<SuppliersCubit>()..loadSuppliers(projectId),
            child: CompareSuppliersPage(
              projectId: projectId,
              supplierIds:
                  supplierIds.split(',').where((id) => id.isNotEmpty).toList(),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.supplierDetail,
        name: 'supplier-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Fornecedor $id');
        },
      ),
      GoRoute(
        path: RouteNames.supplierQuotes,
        name: 'supplier-quotes',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          final supplierName =
              state.uri.queryParameters['supplierName'] ?? 'Fornecedor';
          return BlocProvider(
            create: (context) =>
                getIt<SuppliersCubit>()..loadSuppliers(projectId),
            child: SupplierQuotesPage(
              projectId: projectId,
              supplierId: id,
              supplierName: supplierName,
            ),
          );
        },
      ),

      // Diary
      GoRoute(
        path: RouteNames.diary,
        name: 'diary',
        builder: (context, state) => const _DiaryPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.diaryCreate,
        name: 'diary-create',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<DiaryCubit>()..loadDiaryEntries(projectId),
            child: AddDiaryEntryPage(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.diaryDetail,
        name: 'diary-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Diário $id');
        },
      ),

      // Shopping
      GoRoute(
        path: RouteNames.shopping,
        name: 'shopping',
        builder: (context, state) => const _ShoppingPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.shoppingCreate,
        name: 'shopping-create',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<ShoppingCubit>()..loadShoppingItems(projectId),
            child: AddShoppingItemPage(projectId: projectId),
          );
        },
      ),

      // Wishlist
      GoRoute(
        path: RouteNames.wishlist,
        name: 'wishlist',
        builder: (context, state) => const _WishlistPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.wishlistCreate,
        name: 'wishlist-create',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<WishlistCubit>()..loadWishlistItems(projectId),
            child: AddWishlistItemPage(projectId: projectId),
          );
        },
      ),

      // Alerts
      GoRoute(
        path: RouteNames.alerts,
        name: 'alerts',
        builder: (context, state) => const _AlertsPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.alertDetail,
        name: 'alert-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Alerta $id');
        },
      ),

      // Glossary
      GoRoute(
        path: RouteNames.glossary,
        name: 'glossary',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<GlossaryCubit>()..loadTerms(),
          child: const GlossaryPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.glossaryTerm,
        name: 'glossary-term',
        builder: (context, state) {
          final termId = state.pathParameters['term']!;
          return BlocProvider(
            create: (context) => getIt<GlossaryCubit>()..loadTerms(),
            child: GlossaryTermPage(termId: termId),
          );
        },
      ),

      // Documents
      GoRoute(
        path: RouteNames.documents,
        name: 'documents',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return BlocProvider(
            create: (context) =>
                getIt<DocumentsCubit>()..loadDocuments(projectId),
            child: DocumentsPage(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.documentUpload,
        name: 'document-upload',
        builder: (context, state) {
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          return AddDocumentPage(projectId: projectId);
        },
      ),
      GoRoute(
        path: RouteNames.documentDetail,
        name: 'document-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Documento $id');
        },
      ),

      // Projects
      GoRoute(
        path: RouteNames.projects,
        name: 'projects',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<ProjectsListCubit>(),
          child: const ProjectsListPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.editProject,
        name: 'edit-project',
        builder: (context, state) => const _EditProjectPageWrapper(),
      ),
      GoRoute(
        path: RouteNames.projectSettings,
        name: 'project-settings',
        builder: (context, state) => const _ProjectSettingsPageWrapper(),
      ),

      // Settings
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => getIt<AppSettingsCubit>(),
            child: const SettingsPage(),
          );
        },
      ),
      GoRoute(
        path: '/settings/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<EditProfileCubit>(),
          child: const EditProfilePage(),
        ),
      ),
      GoRoute(
        path: '/settings/change-password',
        name: 'change-password',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<ChangePasswordCubit>(),
          child: const ChangePasswordPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.settingsProfile,
        name: 'settings-profile',
        builder: (context, state) => const _PlaceholderPage(title: 'Perfil'),
      ),
      GoRoute(
        path: RouteNames.settingsNotifications,
        name: 'settings-notifications',
        builder: (context, state) =>
            const _PlaceholderPage(title: 'Notificações'),
      ),
      GoRoute(
        path: RouteNames.settingsPrivacy,
        name: 'settings-privacy',
        builder: (context, state) =>
            const _PlaceholderPage(title: 'Privacidade'),
      ),
      GoRoute(
        path: RouteNames.settingsAbout,
        name: 'settings-about',
        builder: (context, state) => const _PlaceholderPage(title: 'Sobre'),
      ),
      GoRoute(
        path: RouteNames.settingsHelp,
        name: 'settings-help',
        builder: (context, state) => const _PlaceholderPage(title: 'Ajuda'),
      ),
    ],
    errorBuilder: (context, state) => _ErrorPage(error: state.error.toString()),
  );
}

/// Widget placeholder para páginas ainda não implementadas
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Em construção',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Página de erro para rotas não encontradas
class _ErrorPage extends StatelessWidget {
  final String error;

  const _ErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob

/// Widget wrapper para buscar projectId e criar BlocProvider para Phases
class _PhasesPageWrapper extends StatelessWidget {
  const _PhasesPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        return BlocProvider(
          create: (context) => getIt<PhasesCubit>()..loadPhases(projectId),
          child: PhasesPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Alerts
class _AlertsPageWrapper extends StatelessWidget {
  const _AlertsPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        return BlocProvider(
          create: (context) => getIt<AlertsCubit>()..loadAlerts(projectId),
          child: AlertsPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Shopping
class _ShoppingPageWrapper extends StatelessWidget {
  const _ShoppingPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        return BlocProvider(
          create: (context) =>
              getIt<ShoppingCubit>()..loadShoppingItems(projectId),
          child: ShoppingPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Suppliers
class _SuppliersPageWrapper extends StatelessWidget {
  const _SuppliersPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        return BlocProvider(
          create: (context) =>
              getIt<SuppliersCubit>()..loadSuppliers(projectId),
          child: SuppliersPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Payments
class _PaymentsPageWrapper extends StatelessWidget {
  const _PaymentsPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        // MultiBlocProvider para incluir PaymentsCubit e SuppliersCubit
        // (SuppliersCubit é necessário no dialog de adicionar payment)
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  getIt<PaymentsCubit>()..loadPayments(projectId),
            ),
            BlocProvider(
              create: (context) =>
                  getIt<SuppliersCubit>()..loadSuppliers(projectId),
            ),
          ],
          child: PaymentsPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Diary
class _DiaryPageWrapper extends StatelessWidget {
  const _DiaryPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([getIt<AuthRepository>().getCurrentUser()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?[0].fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        // Buscar nome do projeto
        return FutureBuilder(
          future: getIt<ProjectRepository>().getProject(projectId),
          builder: (context, projectSnapshot) {
            if (projectSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final projectName = projectSnapshot.data?.fold(
                  (failure) => 'Meu Projeto',
                  (project) => project.name ?? 'Meu Projeto',
                ) ??
                'Meu Projeto';

            return DiaryPage(projectId: projectId, projectName: projectName);
          },
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Financial
class _FinancialPageWrapper extends StatelessWidget {
  const _FinancialPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        return BlocProvider(
          create: (context) =>
              getIt<FinancialCubit>()..loadFinancialData(projectId),
          child: FinancialPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar página de edição de projeto
class _EditProjectPageWrapper extends StatelessWidget {
  const _EditProjectPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        if (projectId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Nenhum projeto selecionado')),
          );
        }

        return BlocProvider(
          create: (context) => getIt<ProjectCubit>(),
          child: EditProjectPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Wishlist
class _WishlistPageWrapper extends StatelessWidget {
  const _WishlistPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        return BlocProvider(
          create: (context) =>
              getIt<WishlistCubit>()..loadWishlistItems(projectId),
          child: WishlistPage(projectId: projectId),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar página de configurações do projeto
class _ProjectSettingsPageWrapper extends StatelessWidget {
  const _ProjectSettingsPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        if (projectId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Nenhum projeto selecionado')),
          );
        }

        return BlocProvider(
          create: (context) => getIt<ProjectCubit>()..getProject(projectId),
          child: BlocBuilder<ProjectCubit, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is ProjectError) {
                return Scaffold(
                  body: Center(child: Text('Erro: ${state.message}')),
                );
              }

              if (state is ProjectLoaded && state.project != null) {
                return ProjectSettingsPage(project: state.project!);
              }

              return const Scaffold(
                body: Center(child: Text('Projeto não encontrado')),
              );
            },
          ),
        );
      },
    );
  }
}

/// Widget wrapper para buscar projectId e criar BlocProvider para Reform Map
class _ReformMapPageWrapper extends StatelessWidget {
  const _ReformMapPageWrapper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data?.fold(
              (failure) => '',
              (user) => user?.currentProjectId ?? '',
            ) ??
            '';

        return BlocProvider(
          create: (context) =>
              getIt<ReformMapCubit>()..loadReformMap(projectId),
          child: ReformMapPage(projectId: projectId),
        );
      },
    );
  }
}
