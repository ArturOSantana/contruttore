/// Nomes das rotas do aplicativo
/// Centraliza todas as rotas para facilitar navegação e manutenção
class RouteNames {
  RouteNames._();

  // Splash & Onboarding
  static const String splash = '/';
  static const String tutorial = '/tutorial';
  static const String onboarding = '/onboarding';
  static const String retroactiveOnboarding = '/retroactive-onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Navigation
  static const String home = '/home';

  // Phases
  static const String phases = '/phases';
  static const String phaseDetail = '/phases/:id';
  static const String phaseCreate = '/phases/create';
  static const String phaseEdit = '/phases/:id/edit';

  // Financial
  static const String financial = '/financial';
  static const String financialOverview = '/financial/overview';
  static const String expenseCreate = '/financial/expense/create';
  static const String expenseDetail = '/financial/expense/:id';
  static const String expenseEdit = '/financial/expense/:id/edit';

  // Payments
  static const String payments = '/payments';
  static const String paymentCreate = '/payments/create';
  static const String paymentDetail = '/payments/:id';
  static const String paymentEdit = '/payments/:id/edit';

  // Suppliers
  static const String suppliers = '/suppliers';
  static const String supplierCreate = '/suppliers/create';
  static const String supplierDetail = '/suppliers/:id';
  static const String supplierEdit = '/suppliers/:id/edit';
  static const String supplierQuotes = '/suppliers/:id/quotes';
  static const String compareQuotes = '/suppliers/compare-quotes';
  static const String compareSuppliers = '/suppliers/compare';
  static const String addQuote = '/suppliers/:id/add-quote';

  // Diary
  static const String diary = '/diary';
  static const String diaryCreate = '/diary/create';
  static const String diaryDetail = '/diary/:id';
  static const String diaryEdit = '/diary/:id/edit';

  // Shopping List
  static const String shopping = '/shopping';
  static const String shoppingCreate = '/shopping/create';
  static const String shoppingEdit = '/shopping/:id/edit';

  // Wishlist
  static const String wishlist = '/wishlist';
  static const String wishlistCreate = '/wishlist/create';
  static const String wishlistEdit = '/wishlist/:id/edit';

  // Alerts
  static const String alerts = '/alerts';
  static const String alertDetail = '/alerts/:id';
  static const String alertCreate = '/alerts/create';

  // Glossary
  static const String glossary = '/glossary';
  static const String glossaryTerm = '/glossary/:term';

  // Documents
  static const String documents = '/documents';
  static const String documentUpload = '/documents/upload';
  static const String documentDetail = '/documents/:id';

  // Projects
  static const String projects = '/projects';
  static const String editProject = '/projects/edit';

  // Settings
  static const String settings = '/settings';
  static const String settingsProfile = '/settings/profile';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsAbout = '/settings/about';
  static const String settingsHelp = '/settings/help';

  // Helpers para construir rotas com parâmetros
  static String phaseDetailPath(String id) => '/phases/$id';
  static String phaseEditPath(String id) => '/phases/$id/edit';
  static String expenseDetailPath(String id) => '/financial/expense/$id';
  static String expenseEditPath(String id) => '/financial/expense/$id/edit';
  static String paymentDetailPath(String id) => '/payments/$id';
  static String paymentEditPath(String id) => '/payments/$id/edit';
  static String supplierDetailPath(String id) => '/suppliers/$id';
  static String supplierEditPath(String id) => '/suppliers/$id/edit';
  static String diaryDetailPath(String id) => '/diary/$id';
  static String diaryEditPath(String id) => '/diary/$id/edit';
  static String shoppingEditPath(String id) => '/shopping/$id/edit';
  static String wishlistEditPath(String id) => '/wishlist/$id/edit';
  static String alertDetailPath(String id) => '/alerts/$id';
  static String documentDetailPath(String id) => '/documents/$id';
  static String glossaryTermPath(String term) => '/glossary/$term';
}

// Made with Bob
