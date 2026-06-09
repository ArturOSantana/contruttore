// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:contruttore/core/services/brasilapi_service.dart' as _i335;
import 'package:contruttore/core/services/notification_service.dart' as _i128;
import 'package:contruttore/core/services/sinapi_service.dart' as _i180;
import 'package:contruttore/core/services/viacep_service.dart' as _i149;
import 'package:contruttore/core/services/weather_service.dart' as _i1048;
import 'package:contruttore/features/alerts/data/repositories/alerts_repository_impl.dart'
    as _i292;
import 'package:contruttore/features/alerts/domain/repositories/alerts_repository.dart'
    as _i469;
import 'package:contruttore/features/alerts/domain/usecases/add_alert_usecase.dart'
    as _i1063;
import 'package:contruttore/features/alerts/domain/usecases/generate_alerts_usecase.dart'
    as _i290;
import 'package:contruttore/features/alerts/domain/usecases/get_alerts_usecase.dart'
    as _i282;
import 'package:contruttore/features/alerts/domain/usecases/get_unread_count_usecase.dart'
    as _i902;
import 'package:contruttore/features/alerts/domain/usecases/mark_as_read_usecase.dart'
    as _i133;
import 'package:contruttore/features/alerts/presentation/cubit/alerts_cubit.dart'
    as _i482;
import 'package:contruttore/features/auth/data/repositories/auth_repository_impl.dart'
    as _i30;
import 'package:contruttore/features/auth/domain/repositories/auth_repository.dart'
    as _i250;
import 'package:contruttore/features/auth/domain/usecases/change_password_usecase.dart'
    as _i795;
import 'package:contruttore/features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i305;
import 'package:contruttore/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i478;
import 'package:contruttore/features/auth/domain/usecases/login_usecase.dart'
    as _i690;
import 'package:contruttore/features/auth/domain/usecases/logout_usecase.dart'
    as _i67;
import 'package:contruttore/features/auth/domain/usecases/register_usecase.dart'
    as _i200;
import 'package:contruttore/features/auth/domain/usecases/switch_project_usecase.dart'
    as _i792;
import 'package:contruttore/features/auth/domain/usecases/update_profile_usecase.dart'
    as _i755;
import 'package:contruttore/features/auth/presentation/cubit/auth_cubit.dart'
    as _i531;
import 'package:contruttore/features/diary/data/repositories/diary_repository_impl.dart'
    as _i206;
import 'package:contruttore/features/diary/domain/repositories/diary_repository.dart'
    as _i867;
import 'package:contruttore/features/diary/domain/usecases/add_automatic_entry_usecase.dart'
    as _i1003;
import 'package:contruttore/features/diary/domain/usecases/add_diary_entry_usecase.dart'
    as _i80;
import 'package:contruttore/features/diary/domain/usecases/check_inactivity_usecase.dart'
    as _i965;
import 'package:contruttore/features/diary/domain/usecases/delete_diary_entry_usecase.dart'
    as _i641;
import 'package:contruttore/features/diary/domain/usecases/generate_pdf_usecase.dart'
    as _i702;
import 'package:contruttore/features/diary/domain/usecases/get_diary_entries_usecase.dart'
    as _i830;
import 'package:contruttore/features/diary/domain/usecases/update_diary_entry_usecase.dart'
    as _i239;
import 'package:contruttore/features/diary/domain/usecases/upload_photo_usecase.dart'
    as _i215;
import 'package:contruttore/features/diary/presentation/cubit/diary_cubit.dart'
    as _i820;
import 'package:contruttore/features/documents/data/repositories/documents_repository_impl.dart'
    as _i708;
import 'package:contruttore/features/documents/domain/repositories/documents_repository.dart'
    as _i939;
import 'package:contruttore/features/documents/domain/usecases/add_document_usecase.dart'
    as _i242;
import 'package:contruttore/features/documents/domain/usecases/delete_document_usecase.dart'
    as _i180;
import 'package:contruttore/features/documents/domain/usecases/get_documents_usecase.dart'
    as _i546;
import 'package:contruttore/features/documents/domain/usecases/get_expiring_documents_usecase.dart'
    as _i150;
import 'package:contruttore/features/documents/domain/usecases/upload_file_usecase.dart'
    as _i683;
import 'package:contruttore/features/documents/presentation/cubit/documents_cubit.dart'
    as _i307;
import 'package:contruttore/features/financial/data/repositories/financial_repository_impl.dart'
    as _i180;
import 'package:contruttore/features/financial/data/repositories/transaction_repository_impl.dart'
    as _i286;
import 'package:contruttore/features/financial/domain/repositories/financial_repository.dart'
    as _i794;
import 'package:contruttore/features/financial/domain/repositories/transaction_repository.dart'
    as _i356;
import 'package:contruttore/features/financial/domain/usecases/add_expense_usecase.dart'
    as _i342;
import 'package:contruttore/features/financial/domain/usecases/add_manual_transaction_usecase.dart'
    as _i27;
import 'package:contruttore/features/financial/domain/usecases/cancel_installment_payment_usecase.dart'
    as _i14;
import 'package:contruttore/features/financial/domain/usecases/create_installment_payment_usecase.dart'
    as _i1072;
import 'package:contruttore/features/financial/domain/usecases/create_shopping_purchase_usecase.dart'
    as _i865;
import 'package:contruttore/features/financial/domain/usecases/delete_expense_usecase.dart'
    as _i725;
import 'package:contruttore/features/financial/domain/usecases/delete_transaction_usecase.dart'
    as _i141;
import 'package:contruttore/features/financial/domain/usecases/get_expenses_usecase.dart'
    as _i310;
import 'package:contruttore/features/financial/domain/usecases/get_financial_summary_usecase.dart'
    as _i266;
import 'package:contruttore/features/financial/domain/usecases/get_transactions_usecase.dart'
    as _i1031;
import 'package:contruttore/features/financial/domain/usecases/update_expense_usecase.dart'
    as _i796;
import 'package:contruttore/features/financial/domain/usecases/update_phase_financials_usecase.dart'
    as _i207;
import 'package:contruttore/features/financial/domain/usecases/update_transaction_usecase.dart'
    as _i362;
import 'package:contruttore/features/financial/presentation/cubit/financial_cubit.dart'
    as _i1061;
import 'package:contruttore/features/glossary/data/repositories/glossary_repository_impl.dart'
    as _i758;
import 'package:contruttore/features/glossary/domain/repositories/glossary_repository.dart'
    as _i464;
import 'package:contruttore/features/glossary/domain/usecases/get_glossary_terms_usecase.dart'
    as _i551;
import 'package:contruttore/features/glossary/domain/usecases/search_glossary_usecase.dart'
    as _i730;
import 'package:contruttore/features/glossary/domain/usecases/toggle_favorite_usecase.dart'
    as _i413;
import 'package:contruttore/features/glossary/presentation/cubit/glossary_cubit.dart'
    as _i386;
import 'package:contruttore/features/home/domain/usecases/get_home_data_usecase.dart'
    as _i420;
import 'package:contruttore/features/home/presentation/cubit/home_cubit.dart'
    as _i560;
import 'package:contruttore/features/installments/data/repositories/installment_repository_impl.dart'
    as _i1016;
import 'package:contruttore/features/installments/domain/repositories/installment_repository.dart'
    as _i1049;
import 'package:contruttore/features/installments/domain/usecases/add_installment_usecase.dart'
    as _i734;
import 'package:contruttore/features/installments/domain/usecases/delete_installment_usecase.dart'
    as _i477;
import 'package:contruttore/features/installments/domain/usecases/get_installments_usecase.dart'
    as _i356;
import 'package:contruttore/features/installments/domain/usecases/mark_payment_as_paid_usecase.dart'
    as _i396;
import 'package:contruttore/features/installments/presentation/cubit/installments_cubit.dart'
    as _i224;
import 'package:contruttore/features/onboarding/domain/usecases/generate_onboarding_results_usecase.dart'
    as _i439;
import 'package:contruttore/features/onboarding/domain/usecases/generate_reform_risks_usecase.dart'
    as _i806;
import 'package:contruttore/features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i916;
import 'package:contruttore/features/onboarding/presentation/cubit/retroactive_cubit.dart'
    as _i480;
import 'package:contruttore/features/payments/data/repositories/payment_repository_impl.dart'
    as _i478;
import 'package:contruttore/features/payments/domain/repositories/payment_repository.dart'
    as _i984;
import 'package:contruttore/features/payments/domain/usecases/mark_payment_as_paid_usecase.dart'
    as _i937;
import 'package:contruttore/features/payments/presentation/cubit/payments_cubit.dart'
    as _i476;
import 'package:contruttore/features/phases/data/repositories/phase_repository_impl.dart'
    as _i323;
import 'package:contruttore/features/phases/domain/repositories/phase_repository.dart'
    as _i909;
import 'package:contruttore/features/phases/domain/usecases/complete_phase_usecase.dart'
    as _i129;
import 'package:contruttore/features/phases/domain/usecases/get_phases_usecase.dart'
    as _i832;
import 'package:contruttore/features/phases/domain/usecases/mark_phases_retroactive_usecase.dart'
    as _i1049;
import 'package:contruttore/features/phases/domain/usecases/toggle_subtask_usecase.dart'
    as _i864;
import 'package:contruttore/features/phases/presentation/cubit/phases_cubit.dart'
    as _i499;
import 'package:contruttore/features/problems/data/repositories/problem_repository_impl.dart'
    as _i674;
import 'package:contruttore/features/problems/domain/repositories/problem_repository.dart'
    as _i357;
import 'package:contruttore/features/problems/domain/usecases/add_problem_usecase.dart'
    as _i342;
import 'package:contruttore/features/problems/domain/usecases/get_problems_usecase.dart'
    as _i613;
import 'package:contruttore/features/problems/presentation/cubit/problems_cubit.dart'
    as _i467;
import 'package:contruttore/features/projects/data/repositories/phase_repository_impl.dart'
    as _i253;
import 'package:contruttore/features/projects/data/repositories/project_repository_impl.dart'
    as _i311;
import 'package:contruttore/features/projects/domain/repositories/phase_repository.dart'
    as _i340;
import 'package:contruttore/features/projects/domain/repositories/project_repository.dart'
    as _i236;
import 'package:contruttore/features/projects/domain/usecases/create_project_usecase.dart'
    as _i756;
import 'package:contruttore/features/projects/domain/usecases/generate_phases_usecase.dart'
    as _i41;
import 'package:contruttore/features/projects/domain/usecases/get_phases_usecase.dart'
    as _i373;
import 'package:contruttore/features/projects/domain/usecases/get_project_usecase.dart'
    as _i627;
import 'package:contruttore/features/projects/domain/usecases/get_projects_usecase.dart'
    as _i154;
import 'package:contruttore/features/projects/domain/usecases/update_project_usecase.dart'
    as _i281;
import 'package:contruttore/features/projects/domain/usecases/update_subtask_usecase.dart'
    as _i1005;
import 'package:contruttore/features/projects/presentation/cubit/phases_cubit.dart'
    as _i144;
import 'package:contruttore/features/projects/presentation/cubit/project_cubit.dart'
    as _i45;
import 'package:contruttore/features/projects/presentation/cubit/projects_list_cubit.dart'
    as _i1073;
import 'package:contruttore/features/reform_map/data/repositories/reform_map_repository_impl.dart'
    as _i451;
import 'package:contruttore/features/reform_map/domain/repositories/reform_map_repository.dart'
    as _i517;
import 'package:contruttore/features/reform_map/domain/services/calendar_events_detector.dart'
    as _i219;
import 'package:contruttore/features/reform_map/domain/services/milestones_detector.dart'
    as _i951;
import 'package:contruttore/features/reform_map/domain/services/move_in_distance_calculator.dart'
    as _i51;
import 'package:contruttore/features/reform_map/domain/services/move_in_mode_generator.dart'
    as _i934;
import 'package:contruttore/features/reform_map/domain/services/next_phase_preparation_detector.dart'
    as _i629;
import 'package:contruttore/features/reform_map/domain/services/pending_decisions_detector.dart'
    as _i124;
import 'package:contruttore/features/reform_map/domain/services/reform_map_integration_service.dart'
    as _i667;
import 'package:contruttore/features/reform_map/domain/services/reform_week_generator.dart'
    as _i1002;
import 'package:contruttore/features/reform_map/domain/services/upcoming_purchases_detector.dart'
    as _i792;
import 'package:contruttore/features/reform_map/domain/usecases/add_calendar_event_usecase.dart'
    as _i952;
import 'package:contruttore/features/reform_map/domain/usecases/add_problem_usecase.dart'
    as _i806;
import 'package:contruttore/features/reform_map/domain/usecases/calculate_health_usecase.dart'
    as _i246;
import 'package:contruttore/features/reform_map/domain/usecases/calculate_next_action_usecase.dart'
    as _i421;
import 'package:contruttore/features/reform_map/domain/usecases/calculate_upcoming_expenses_usecase.dart'
    as _i210;
import 'package:contruttore/features/reform_map/domain/usecases/get_next_step_preparation_usecase.dart'
    as _i1014;
import 'package:contruttore/features/reform_map/domain/usecases/get_reform_map_usecase.dart'
    as _i314;
import 'package:contruttore/features/reform_map/domain/usecases/resolve_problem_usecase.dart'
    as _i745;
import 'package:contruttore/features/reform_map/domain/usecases/update_preparation_item_usecase.dart'
    as _i374;
import 'package:contruttore/features/reform_map/presentation/cubit/reform_map_cubit.dart'
    as _i123;
import 'package:contruttore/features/settings/data/repositories/app_settings_repository_impl.dart'
    as _i184;
import 'package:contruttore/features/settings/domain/repositories/app_settings_repository.dart'
    as _i879;
import 'package:contruttore/features/settings/presentation/cubit/app_settings_cubit.dart'
    as _i967;
import 'package:contruttore/features/settings/presentation/cubit/change_password_cubit.dart'
    as _i30;
import 'package:contruttore/features/settings/presentation/cubit/edit_profile_cubit.dart'
    as _i991;
import 'package:contruttore/features/shopping/data/repositories/shopping_repository_impl.dart'
    as _i792;
import 'package:contruttore/features/shopping/domain/repositories/shopping_repository.dart'
    as _i911;
import 'package:contruttore/features/shopping/domain/usecases/add_shopping_item_usecase.dart'
    as _i1017;
import 'package:contruttore/features/shopping/domain/usecases/cancel_shopping_purchase_usecase.dart'
    as _i886;
import 'package:contruttore/features/shopping/domain/usecases/delete_shopping_item_usecase.dart'
    as _i441;
import 'package:contruttore/features/shopping/domain/usecases/generate_suggestions_usecase.dart'
    as _i795;
import 'package:contruttore/features/shopping/domain/usecases/get_shopping_items_usecase.dart'
    as _i893;
import 'package:contruttore/features/shopping/domain/usecases/mark_as_purchased_usecase.dart'
    as _i1038;
import 'package:contruttore/features/shopping/presentation/cubit/shopping_cubit.dart'
    as _i1013;
import 'package:contruttore/features/suppliers/data/repositories/supplier_repository_impl.dart'
    as _i526;
import 'package:contruttore/features/suppliers/domain/repositories/supplier_repository.dart'
    as _i1001;
import 'package:contruttore/features/suppliers/domain/usecases/accept_quote_usecase.dart'
    as _i826;
import 'package:contruttore/features/suppliers/domain/usecases/add_quote_usecase.dart'
    as _i186;
import 'package:contruttore/features/suppliers/domain/usecases/add_supplier_usecase.dart'
    as _i705;
import 'package:contruttore/features/suppliers/domain/usecases/compare_quotes_usecase.dart'
    as _i183;
import 'package:contruttore/features/suppliers/domain/usecases/delete_supplier_usecase.dart'
    as _i862;
import 'package:contruttore/features/suppliers/domain/usecases/get_quotes_usecase.dart'
    as _i358;
import 'package:contruttore/features/suppliers/domain/usecases/get_suppliers_usecase.dart'
    as _i651;
import 'package:contruttore/features/suppliers/domain/usecases/update_supplier_usecase.dart'
    as _i22;
import 'package:contruttore/features/suppliers/presentation/cubit/suppliers_cubit.dart'
    as _i192;
import 'package:contruttore/features/wishlist/data/repositories/wishlist_repository_impl.dart'
    as _i863;
import 'package:contruttore/features/wishlist/domain/repositories/wishlist_repository.dart'
    as _i925;
import 'package:contruttore/features/wishlist/domain/usecases/add_wishlist_item_usecase.dart'
    as _i179;
import 'package:contruttore/features/wishlist/domain/usecases/delete_wishlist_item_usecase.dart'
    as _i525;
import 'package:contruttore/features/wishlist/domain/usecases/get_wishlist_items_usecase.dart'
    as _i524;
import 'package:contruttore/features/wishlist/domain/usecases/move_to_shopping_usecase.dart'
    as _i677;
import 'package:contruttore/features/wishlist/domain/usecases/toggle_selected_usecase.dart'
    as _i677;
import 'package:contruttore/features/wishlist/presentation/cubit/wishlist_cubit.dart'
    as _i68;
import 'package:contruttore/injection_container.dart' as _i166;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:uuid/uuid.dart' as _i706;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final firebaseModule = _$FirebaseModule();
    final externalModule = _$ExternalModule();
    final networkModule = _$NetworkModule();
    final notificationModule = _$NotificationModule();
    gh.factory<_i702.GeneratePdfUseCase>(() => _i702.GeneratePdfUseCase());
    gh.factory<_i439.GenerateOnboardingResultsUseCase>(
        () => _i439.GenerateOnboardingResultsUseCase());
    gh.factory<_i806.GenerateReformRisksUseCase>(
        () => _i806.GenerateReformRisksUseCase());
    gh.factory<_i219.CalendarEventsDetector>(
        () => _i219.CalendarEventsDetector());
    gh.factory<_i951.MilestonesDetector>(() => _i951.MilestonesDetector());
    gh.factory<_i51.MoveInDistanceCalculator>(
        () => _i51.MoveInDistanceCalculator());
    gh.factory<_i934.MoveInModeGenerator>(() => _i934.MoveInModeGenerator());
    gh.factory<_i629.NextPhasePreparationDetector>(
        () => _i629.NextPhasePreparationDetector());
    gh.factory<_i124.PendingDecisionsDetector>(
        () => _i124.PendingDecisionsDetector());
    gh.factory<_i1002.ReformWeekGenerator>(() => _i1002.ReformWeekGenerator());
    gh.factory<_i792.UpcomingPurchasesDetector>(
        () => _i792.UpcomingPurchasesDetector());
    gh.lazySingleton<_i180.SinapiService>(() => _i180.SinapiService());
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i457.FirebaseStorage>(
        () => firebaseModule.firebaseStorage);
    gh.lazySingleton<_i706.Uuid>(() => externalModule.uuid);
    gh.lazySingleton<_i519.Client>(() => externalModule.httpClient);
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
        () => notificationModule.localNotifications);
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => notificationModule.firebaseMessaging);
    gh.lazySingleton<_i250.AuthRepository>(() => _i30.AuthRepositoryImpl(
          gh<_i59.FirebaseAuth>(),
          gh<_i974.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i867.DiaryRepository>(() => _i206.DiaryRepositoryImpl(
          gh<_i974.FirebaseFirestore>(),
          gh<_i457.FirebaseStorage>(),
        ));
    gh.factory<_i80.AddDiaryEntryUseCase>(
        () => _i80.AddDiaryEntryUseCase(gh<_i867.DiaryRepository>()));
    gh.factory<_i965.CheckInactivityUseCase>(
        () => _i965.CheckInactivityUseCase(gh<_i867.DiaryRepository>()));
    gh.factory<_i830.GetDiaryEntriesUseCase>(
        () => _i830.GetDiaryEntriesUseCase(gh<_i867.DiaryRepository>()));
    gh.factory<_i215.UploadPhotoUseCase>(
        () => _i215.UploadPhotoUseCase(gh<_i867.DiaryRepository>()));
    gh.factory<_i795.GenerateSuggestionsUseCase>(
        () => _i795.GenerateSuggestionsUseCase(gh<_i706.Uuid>()));
    gh.lazySingleton<_i128.NotificationService>(() => _i128.NotificationService(
          gh<_i163.FlutterLocalNotificationsPlugin>(),
          gh<_i892.FirebaseMessaging>(),
        ));
    gh.lazySingleton<_i1001.SupplierRepository>(
        () => _i526.SupplierRepositoryImpl(
              gh<_i974.FirebaseFirestore>(),
              gh<_i519.Client>(),
            ));
    gh.factory<_i335.BrasilApiService>(
        () => _i335.BrasilApiService(gh<_i361.Dio>()));
    gh.factory<_i149.ViaCepService>(() => _i149.ViaCepService(gh<_i361.Dio>()));
    gh.factory<_i1048.WeatherService>(
        () => _i1048.WeatherService(gh<_i361.Dio>()));
    gh.lazySingleton<_i939.DocumentsRepository>(
        () => _i708.DocumentsRepositoryImpl(
              gh<_i974.FirebaseFirestore>(),
              gh<_i457.FirebaseStorage>(),
            ));
    gh.factory<_i186.AddQuoteUseCase>(
        () => _i186.AddQuoteUseCase(gh<_i1001.SupplierRepository>()));
    gh.factory<_i705.AddSupplierUseCase>(
        () => _i705.AddSupplierUseCase(gh<_i1001.SupplierRepository>()));
    gh.factory<_i358.GetQuotesUseCase>(
        () => _i358.GetQuotesUseCase(gh<_i1001.SupplierRepository>()));
    gh.factory<_i651.GetSuppliersUseCase>(
        () => _i651.GetSuppliersUseCase(gh<_i1001.SupplierRepository>()));
    gh.factory<_i22.UpdateSupplierUseCase>(
        () => _i22.UpdateSupplierUseCase(gh<_i1001.SupplierRepository>()));
    gh.lazySingleton<_i464.GlossaryRepository>(
        () => _i758.GlossaryRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i357.ProblemRepository>(
        () => _i674.ProblemRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i984.PaymentRepository>(
        () => _i478.PaymentRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i911.ShoppingRepository>(
        () => _i792.ShoppingRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i795.ChangePasswordUseCase>(
        () => _i795.ChangePasswordUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i305.ForgotPasswordUseCase>(
        () => _i305.ForgotPasswordUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i478.GetCurrentUserUseCase>(
        () => _i478.GetCurrentUserUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i690.LoginUseCase>(
        () => _i690.LoginUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i67.LogoutUseCase>(
        () => _i67.LogoutUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i200.RegisterUseCase>(
        () => _i200.RegisterUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i792.SwitchProjectUseCase>(
        () => _i792.SwitchProjectUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i755.UpdateProfileUseCase>(
        () => _i755.UpdateProfileUseCase(gh<_i250.AuthRepository>()));
    gh.factory<_i342.AddProblemUseCase>(
        () => _i342.AddProblemUseCase(gh<_i357.ProblemRepository>()));
    gh.factory<_i613.GetProblemsUseCase>(
        () => _i613.GetProblemsUseCase(gh<_i357.ProblemRepository>()));
    gh.lazySingleton<_i469.AlertsRepository>(
        () => _i292.AlertsRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i242.AddDocumentUseCase>(
        () => _i242.AddDocumentUseCase(gh<_i939.DocumentsRepository>()));
    gh.factory<_i180.DeleteDocumentUseCase>(
        () => _i180.DeleteDocumentUseCase(gh<_i939.DocumentsRepository>()));
    gh.factory<_i546.GetDocumentsUseCase>(
        () => _i546.GetDocumentsUseCase(gh<_i939.DocumentsRepository>()));
    gh.factory<_i150.GetExpiringDocumentsUseCase>(() =>
        _i150.GetExpiringDocumentsUseCase(gh<_i939.DocumentsRepository>()));
    gh.factory<_i683.UploadFileUseCase>(
        () => _i683.UploadFileUseCase(gh<_i939.DocumentsRepository>()));
    gh.lazySingleton<_i340.PhaseRepository>(
        () => _i253.PhaseRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i991.EditProfileCubit>(
        () => _i991.EditProfileCubit(gh<_i755.UpdateProfileUseCase>()));
    gh.lazySingleton<_i356.TransactionRepository>(
        () => _i286.TransactionRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i925.WishlistRepository>(
        () => _i863.WishlistRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i179.AddWishlistItemUseCase>(
        () => _i179.AddWishlistItemUseCase(gh<_i925.WishlistRepository>()));
    gh.factory<_i524.GetWishlistItemsUseCase>(
        () => _i524.GetWishlistItemsUseCase(gh<_i925.WishlistRepository>()));
    gh.factory<_i677.ToggleSelectedUseCase>(
        () => _i677.ToggleSelectedUseCase(gh<_i925.WishlistRepository>()));
    gh.lazySingleton<_i879.AppSettingsRepository>(
        () => _i184.AppSettingsRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i1017.AddShoppingItemUseCase>(
        () => _i1017.AddShoppingItemUseCase(gh<_i911.ShoppingRepository>()));
    gh.factory<_i893.GetShoppingItemsUseCase>(
        () => _i893.GetShoppingItemsUseCase(gh<_i911.ShoppingRepository>()));
    gh.factory<_i41.GeneratePhasesUseCase>(
        () => _i41.GeneratePhasesUseCase(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i937.MarkPaymentAsPaidUseCase>(
        () => _i937.MarkPaymentAsPaidUseCase(gh<_i984.PaymentRepository>()));
    gh.lazySingleton<_i517.ReformMapRepository>(
        () => _i451.ReformMapRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i236.ProjectRepository>(() => _i311.ProjectRepositoryImpl(
          gh<_i974.FirebaseFirestore>(),
          gh<_i59.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i1049.InstallmentRepository>(
        () => _i1016.InstallmentRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i551.GetGlossaryTermsUseCase>(
        () => _i551.GetGlossaryTermsUseCase(gh<_i464.GlossaryRepository>()));
    gh.factory<_i730.SearchGlossaryUseCase>(
        () => _i730.SearchGlossaryUseCase(gh<_i464.GlossaryRepository>()));
    gh.factory<_i413.ToggleFavoriteUseCase>(
        () => _i413.ToggleFavoriteUseCase(gh<_i464.GlossaryRepository>()));
    gh.lazySingleton<_i909.PhaseRepository>(
        () => _i323.PhaseRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i794.FinancialRepository>(
        () => _i180.FinancialRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i756.CreateProjectUseCase>(
        () => _i756.CreateProjectUseCase(gh<_i236.ProjectRepository>()));
    gh.factory<_i154.GetProjectsUseCase>(
        () => _i154.GetProjectsUseCase(gh<_i236.ProjectRepository>()));
    gh.factory<_i641.DeleteDiaryEntryUseCase>(
        () => _i641.DeleteDiaryEntryUseCase(gh<_i867.DiaryRepository>()));
    gh.factory<_i239.UpdateDiaryEntryUseCase>(
        () => _i239.UpdateDiaryEntryUseCase(gh<_i867.DiaryRepository>()));
    gh.lazySingleton<_i1003.AddAutomaticEntryUseCase>(
        () => _i1003.AddAutomaticEntryUseCase(gh<_i867.DiaryRepository>()));
    gh.factory<_i30.ChangePasswordCubit>(
        () => _i30.ChangePasswordCubit(gh<_i795.ChangePasswordUseCase>()));
    gh.factory<_i952.AddCalendarEventUseCase>(
        () => _i952.AddCalendarEventUseCase(gh<_i517.ReformMapRepository>()));
    gh.factory<_i806.AddProblemUseCase>(
        () => _i806.AddProblemUseCase(gh<_i517.ReformMapRepository>()));
    gh.factory<_i246.CalculateHealthUseCase>(
        () => _i246.CalculateHealthUseCase(gh<_i517.ReformMapRepository>()));
    gh.factory<_i421.CalculateNextActionUseCase>(() =>
        _i421.CalculateNextActionUseCase(gh<_i517.ReformMapRepository>()));
    gh.factory<_i314.GetReformMapUseCase>(
        () => _i314.GetReformMapUseCase(gh<_i517.ReformMapRepository>()));
    gh.lazySingleton<_i210.CalculateUpcomingExpensesUseCase>(() =>
        _i210.CalculateUpcomingExpensesUseCase(
            gh<_i517.ReformMapRepository>()));
    gh.lazySingleton<_i1014.GetNextStepPreparationUseCase>(() =>
        _i1014.GetNextStepPreparationUseCase(gh<_i517.ReformMapRepository>()));
    gh.lazySingleton<_i745.ResolveProblemUseCase>(
        () => _i745.ResolveProblemUseCase(gh<_i517.ReformMapRepository>()));
    gh.lazySingleton<_i374.UpdatePreparationItemUseCase>(() =>
        _i374.UpdatePreparationItemUseCase(gh<_i517.ReformMapRepository>()));
    gh.factory<_i677.MoveToShoppingUseCase>(() => _i677.MoveToShoppingUseCase(
          gh<_i911.ShoppingRepository>(),
          gh<_i706.Uuid>(),
        ));
    gh.factory<_i290.GenerateAlertsUseCase>(() => _i290.GenerateAlertsUseCase(
          gh<_i469.AlertsRepository>(),
          gh<_i974.FirebaseFirestore>(),
          gh<_i128.NotificationService>(),
          gh<_i984.PaymentRepository>(),
          gh<_i706.Uuid>(),
        ));
    gh.factory<_i123.ReformMapCubit>(() => _i123.ReformMapCubit(
          getReformMapUseCase: gh<_i314.GetReformMapUseCase>(),
          calculateHealthUseCase: gh<_i246.CalculateHealthUseCase>(),
          calculateNextActionUseCase: gh<_i421.CalculateNextActionUseCase>(),
          addProblemUseCase: gh<_i806.AddProblemUseCase>(),
          calculateUpcomingExpensesUseCase:
              gh<_i210.CalculateUpcomingExpensesUseCase>(),
          getNextStepPreparationUseCase:
              gh<_i1014.GetNextStepPreparationUseCase>(),
          updatePreparationItemUseCase:
              gh<_i374.UpdatePreparationItemUseCase>(),
          resolveProblemUseCase: gh<_i745.ResolveProblemUseCase>(),
          moveInDistanceCalculator: gh<_i51.MoveInDistanceCalculator>(),
          moveInModeGenerator: gh<_i934.MoveInModeGenerator>(),
          pendingDecisionsDetector: gh<_i124.PendingDecisionsDetector>(),
          upcomingPurchasesDetector: gh<_i792.UpcomingPurchasesDetector>(),
          nextPhasePreparationDetector:
              gh<_i629.NextPhasePreparationDetector>(),
          milestonesDetector: gh<_i951.MilestonesDetector>(),
          calendarEventsDetector: gh<_i219.CalendarEventsDetector>(),
          reformWeekGenerator: gh<_i1002.ReformWeekGenerator>(),
          addCalendarEventUseCase: gh<_i952.AddCalendarEventUseCase>(),
        ));
    gh.factory<_i129.CompletePhaseUseCase>(
        () => _i129.CompletePhaseUseCase(gh<_i909.PhaseRepository>()));
    gh.factory<_i832.GetPhasesUseCase>(
        () => _i832.GetPhasesUseCase(gh<_i909.PhaseRepository>()));
    gh.factory<_i864.ToggleSubtaskUseCase>(
        () => _i864.ToggleSubtaskUseCase(gh<_i909.PhaseRepository>()));
    gh.lazySingleton<_i1049.MarkPhasesRetroactiveUseCase>(
        () => _i1049.MarkPhasesRetroactiveUseCase(gh<_i909.PhaseRepository>()));
    gh.factory<_i441.DeleteShoppingItemUseCase>(
        () => _i441.DeleteShoppingItemUseCase(gh<_i911.ShoppingRepository>()));
    gh.factory<_i1063.AddAlertUseCase>(
        () => _i1063.AddAlertUseCase(gh<_i469.AlertsRepository>()));
    gh.factory<_i282.GetAlertsUseCase>(
        () => _i282.GetAlertsUseCase(gh<_i469.AlertsRepository>()));
    gh.factory<_i902.GetUnreadCountUseCase>(
        () => _i902.GetUnreadCountUseCase(gh<_i469.AlertsRepository>()));
    gh.factory<_i133.MarkAsReadUseCase>(
        () => _i133.MarkAsReadUseCase(gh<_i469.AlertsRepository>()));
    gh.factory<_i499.PhasesCubit>(() => _i499.PhasesCubit(
          gh<_i832.GetPhasesUseCase>(),
          gh<_i864.ToggleSubtaskUseCase>(),
          gh<_i129.CompletePhaseUseCase>(),
          gh<_i1049.MarkPhasesRetroactiveUseCase>(),
        ));
    gh.factory<_i420.GetHomeDataUseCase>(() => _i420.GetHomeDataUseCase(
          gh<_i250.AuthRepository>(),
          gh<_i236.ProjectRepository>(),
          gh<_i974.FirebaseFirestore>(),
        ));
    gh.factory<_i183.CompareQuotesUseCase>(() => _i183.CompareQuotesUseCase(
          gh<_i1001.SupplierRepository>(),
          gh<_i180.SinapiService>(),
        ));
    gh.factory<_i560.HomeCubit>(() => _i560.HomeCubit(
          gh<_i420.GetHomeDataUseCase>(),
          gh<_i290.GenerateAlertsUseCase>(),
        ));
    gh.factory<_i826.AcceptQuoteUseCase>(() => _i826.AcceptQuoteUseCase(
          gh<_i1001.SupplierRepository>(),
          gh<_i356.TransactionRepository>(),
          gh<_i984.PaymentRepository>(),
          gh<_i706.Uuid>(),
        ));
    gh.factory<_i820.DiaryCubit>(() => _i820.DiaryCubit(
          gh<_i830.GetDiaryEntriesUseCase>(),
          gh<_i80.AddDiaryEntryUseCase>(),
          gh<_i239.UpdateDiaryEntryUseCase>(),
          gh<_i215.UploadPhotoUseCase>(),
          gh<_i965.CheckInactivityUseCase>(),
          gh<_i702.GeneratePdfUseCase>(),
          gh<_i641.DeleteDiaryEntryUseCase>(),
        ));
    gh.lazySingleton<_i14.CancelInstallmentPaymentUseCase>(() =>
        _i14.CancelInstallmentPaymentUseCase(
            gh<_i356.TransactionRepository>()));
    gh.lazySingleton<_i1072.CreateInstallmentPaymentUseCase>(() =>
        _i1072.CreateInstallmentPaymentUseCase(
            gh<_i356.TransactionRepository>()));
    gh.lazySingleton<_i865.CreateShoppingPurchaseUseCase>(() =>
        _i865.CreateShoppingPurchaseUseCase(gh<_i356.TransactionRepository>()));
    gh.lazySingleton<_i141.DeleteTransactionUseCase>(() =>
        _i141.DeleteTransactionUseCase(gh<_i356.TransactionRepository>()));
    gh.lazySingleton<_i1031.GetTransactionsUseCase>(
        () => _i1031.GetTransactionsUseCase(gh<_i356.TransactionRepository>()));
    gh.lazySingleton<_i362.UpdateTransactionUseCase>(() =>
        _i362.UpdateTransactionUseCase(gh<_i356.TransactionRepository>()));
    gh.factory<_i862.DeleteSupplierUseCase>(
        () => _i862.DeleteSupplierUseCase(gh<_i1001.SupplierRepository>()));
    gh.factory<_i525.DeleteWishlistItemUseCase>(
        () => _i525.DeleteWishlistItemUseCase(gh<_i925.WishlistRepository>()));
    gh.factory<_i477.DeleteInstallmentUseCase>(() =>
        _i477.DeleteInstallmentUseCase(gh<_i1049.InstallmentRepository>()));
    gh.factory<_i886.CancelShoppingPurchaseUseCase>(
        () => _i886.CancelShoppingPurchaseUseCase(
              gh<_i911.ShoppingRepository>(),
              gh<_i356.TransactionRepository>(),
              gh<_i706.Uuid>(),
            ));
    gh.factory<_i1073.ProjectsListCubit>(() => _i1073.ProjectsListCubit(
          gh<_i154.GetProjectsUseCase>(),
          gh<_i478.GetCurrentUserUseCase>(),
          gh<_i792.SwitchProjectUseCase>(),
        ));
    gh.factory<_i1038.MarkAsPurchasedUseCase>(
        () => _i1038.MarkAsPurchasedUseCase(
              gh<_i911.ShoppingRepository>(),
              gh<_i865.CreateShoppingPurchaseUseCase>(),
              gh<_i706.Uuid>(),
            ));
    gh.factory<_i531.AuthCubit>(() => _i531.AuthCubit(
          gh<_i690.LoginUseCase>(),
          gh<_i200.RegisterUseCase>(),
          gh<_i67.LogoutUseCase>(),
          gh<_i305.ForgotPasswordUseCase>(),
          gh<_i478.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i27.AddManualTransactionUseCase>(
        () => _i27.AddManualTransactionUseCase(
              gh<_i356.TransactionRepository>(),
              gh<_i706.Uuid>(),
            ));
    gh.factory<_i627.GetProjectUsecase>(
        () => _i627.GetProjectUsecase(gh<_i236.ProjectRepository>()));
    gh.factory<_i281.UpdateProjectUseCase>(
        () => _i281.UpdateProjectUseCase(gh<_i236.ProjectRepository>()));
    gh.factory<_i667.ReformMapIntegrationService>(
        () => _i667.ReformMapIntegrationService(
              gh<_i356.TransactionRepository>(),
              gh<_i911.ShoppingRepository>(),
              gh<_i1001.SupplierRepository>(),
              gh<_i1049.InstallmentRepository>(),
              gh<_i517.ReformMapRepository>(),
            ));
    gh.factory<_i356.GetInstallmentsUseCase>(
        () => _i356.GetInstallmentsUseCase(gh<_i1049.InstallmentRepository>()));
    gh.factory<_i68.WishlistCubit>(() => _i68.WishlistCubit(
          gh<_i524.GetWishlistItemsUseCase>(),
          gh<_i179.AddWishlistItemUseCase>(),
          gh<_i677.ToggleSelectedUseCase>(),
          gh<_i677.MoveToShoppingUseCase>(),
          gh<_i525.DeleteWishlistItemUseCase>(),
          gh<_i1003.AddAutomaticEntryUseCase>(),
        ));
    gh.lazySingleton<_i266.GetFinancialSummaryUseCase>(
        () => _i266.GetFinancialSummaryUseCase(
              gh<_i356.TransactionRepository>(),
              gh<_i236.ProjectRepository>(),
              gh<_i984.PaymentRepository>(),
            ));
    gh.factory<_i480.RetroactiveCubit>(() => _i480.RetroactiveCubit(
          projectRepository: gh<_i236.ProjectRepository>(),
          phaseRepository: gh<_i909.PhaseRepository>(),
          financialRepository: gh<_i794.FinancialRepository>(),
          supplierRepository: gh<_i1001.SupplierRepository>(),
          uuid: gh<_i706.Uuid>(),
        ));
    gh.lazySingleton<_i207.UpdatePhaseFinancialsUseCase>(() =>
        _i207.UpdatePhaseFinancialsUseCase(gh<_i794.FinancialRepository>()));
    gh.factory<_i725.DeleteExpenseUseCase>(
        () => _i725.DeleteExpenseUseCase(gh<_i794.FinancialRepository>()));
    gh.factory<_i373.GetPhasesUsecase>(
        () => _i373.GetPhasesUsecase(gh<_i340.PhaseRepository>()));
    gh.factory<_i1005.UpdateSubtaskUsecase>(
        () => _i1005.UpdateSubtaskUsecase(gh<_i340.PhaseRepository>()));
    gh.factory<_i476.PaymentsCubit>(() => _i476.PaymentsCubit(
          gh<_i984.PaymentRepository>(),
          gh<_i937.MarkPaymentAsPaidUseCase>(),
        ));
    gh.factory<_i467.ProblemsCubit>(() => _i467.ProblemsCubit(
          gh<_i613.GetProblemsUseCase>(),
          gh<_i342.AddProblemUseCase>(),
          gh<_i745.ResolveProblemUseCase>(),
          gh<_i357.ProblemRepository>(),
        ));
    gh.factory<_i734.AddInstallmentUseCase>(() => _i734.AddInstallmentUseCase(
          gh<_i1049.InstallmentRepository>(),
          gh<_i706.Uuid>(),
        ));
    gh.factory<_i967.AppSettingsCubit>(
        () => _i967.AppSettingsCubit(gh<_i879.AppSettingsRepository>()));
    gh.factory<_i916.OnboardingCubit>(() => _i916.OnboardingCubit(
          gh<_i756.CreateProjectUseCase>(),
          gh<_i41.GeneratePhasesUseCase>(),
          gh<_i909.PhaseRepository>(),
          gh<_i974.FirebaseFirestore>(),
          gh<_i439.GenerateOnboardingResultsUseCase>(),
          gh<_i806.GenerateReformRisksUseCase>(),
        ));
    gh.factory<_i386.GlossaryCubit>(() => _i386.GlossaryCubit(
          gh<_i551.GetGlossaryTermsUseCase>(),
          gh<_i730.SearchGlossaryUseCase>(),
          gh<_i413.ToggleFavoriteUseCase>(),
        ));
    gh.factory<_i342.AddExpenseUseCase>(
        () => _i342.AddExpenseUseCase(gh<_i794.FinancialRepository>()));
    gh.factory<_i310.GetExpensesUseCase>(
        () => _i310.GetExpensesUseCase(gh<_i794.FinancialRepository>()));
    gh.factory<_i796.UpdateExpenseUseCase>(
        () => _i796.UpdateExpenseUseCase(gh<_i794.FinancialRepository>()));
    gh.factory<_i1061.FinancialCubit>(() => _i1061.FinancialCubit(
          gh<_i266.GetFinancialSummaryUseCase>(),
          gh<_i1031.GetTransactionsUseCase>(),
          gh<_i27.AddManualTransactionUseCase>(),
          gh<_i362.UpdateTransactionUseCase>(),
          gh<_i141.DeleteTransactionUseCase>(),
          gh<_i207.UpdatePhaseFinancialsUseCase>(),
          gh<_i1003.AddAutomaticEntryUseCase>(),
        ));
    gh.factory<_i396.MarkPaymentAsPaidUseCase>(
        () => _i396.MarkPaymentAsPaidUseCase(
              gh<_i1049.InstallmentRepository>(),
              gh<_i1072.CreateInstallmentPaymentUseCase>(),
              gh<_i706.Uuid>(),
            ));
    gh.factory<_i192.SuppliersCubit>(() => _i192.SuppliersCubit(
          gh<_i651.GetSuppliersUseCase>(),
          gh<_i705.AddSupplierUseCase>(),
          gh<_i22.UpdateSupplierUseCase>(),
          gh<_i862.DeleteSupplierUseCase>(),
          gh<_i358.GetQuotesUseCase>(),
          gh<_i186.AddQuoteUseCase>(),
          gh<_i826.AcceptQuoteUseCase>(),
          gh<_i183.CompareQuotesUseCase>(),
          gh<_i984.PaymentRepository>(),
          gh<_i1003.AddAutomaticEntryUseCase>(),
        ));
    gh.factory<_i307.DocumentsCubit>(() => _i307.DocumentsCubit(
          gh<_i546.GetDocumentsUseCase>(),
          gh<_i242.AddDocumentUseCase>(),
          gh<_i180.DeleteDocumentUseCase>(),
          gh<_i683.UploadFileUseCase>(),
          gh<_i1003.AddAutomaticEntryUseCase>(),
        ));
    gh.factory<_i482.AlertsCubit>(() => _i482.AlertsCubit(
          gh<_i282.GetAlertsUseCase>(),
          gh<_i1063.AddAlertUseCase>(),
          gh<_i133.MarkAsReadUseCase>(),
          gh<_i902.GetUnreadCountUseCase>(),
          gh<_i290.GenerateAlertsUseCase>(),
        ));
    gh.factory<_i45.ProjectCubit>(() => _i45.ProjectCubit(
          gh<_i627.GetProjectUsecase>(),
          gh<_i281.UpdateProjectUseCase>(),
        ));
    gh.factory<_i144.PhasesCubit>(() => _i144.PhasesCubit(
          gh<_i373.GetPhasesUsecase>(),
          gh<_i1005.UpdateSubtaskUsecase>(),
          gh<_i207.UpdatePhaseFinancialsUseCase>(),
          gh<_i1003.AddAutomaticEntryUseCase>(),
          gh<_i128.NotificationService>(),
        ));
    gh.factory<_i1013.ShoppingCubit>(() => _i1013.ShoppingCubit(
          gh<_i893.GetShoppingItemsUseCase>(),
          gh<_i1017.AddShoppingItemUseCase>(),
          gh<_i1038.MarkAsPurchasedUseCase>(),
          gh<_i886.CancelShoppingPurchaseUseCase>(),
          gh<_i795.GenerateSuggestionsUseCase>(),
          gh<_i441.DeleteShoppingItemUseCase>(),
          gh<_i984.PaymentRepository>(),
          gh<_i207.UpdatePhaseFinancialsUseCase>(),
          gh<_i1003.AddAutomaticEntryUseCase>(),
        ));
    gh.factory<_i224.InstallmentsCubit>(() => _i224.InstallmentsCubit(
          gh<_i356.GetInstallmentsUseCase>(),
          gh<_i734.AddInstallmentUseCase>(),
          gh<_i396.MarkPaymentAsPaidUseCase>(),
          gh<_i14.CancelInstallmentPaymentUseCase>(),
          gh<_i477.DeleteInstallmentUseCase>(),
          gh<_i207.UpdatePhaseFinancialsUseCase>(),
          gh<_i1003.AddAutomaticEntryUseCase>(),
        ));
    return this;
  }
}

class _$FirebaseModule extends _i166.FirebaseModule {}

class _$ExternalModule extends _i166.ExternalModule {}

class _$NetworkModule extends _i166.NetworkModule {}

class _$NotificationModule extends _i166.NotificationModule {}
