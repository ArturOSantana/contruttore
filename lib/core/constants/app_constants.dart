/// Constantes globais do aplicativo Costruttore
class AppConstants {
  AppConstants._();

  // Informações do App
  static const String appName = 'Costruttore';
  static const String appVersion = '1.0.0';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(minutes: 2);

  // Limites
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxPhotosPerDiary = 10;
  static const int maxSuppliers = 100;

  // Formato de datas
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Formato de moeda
  static const String currencySymbol = 'R\$';
  static const String currencyLocale = 'pt_BR';

  // Chaves de armazenamento local
  static const String keyUser = 'user';
  static const String keyTheme = 'theme';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyTutorialCompleted = 'tutorial_completed';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Coleções do Firestore
  static const String collectionUsers = 'users';
  static const String collectionProjects = 'projects';
  static const String collectionPhases = 'phases';
  static const String collectionExpenses = 'expenses';
  static const String collectionPayments = 'payments';
  static const String collectionSuppliers = 'suppliers';
  static const String collectionDiary = 'diary';
  static const String collectionShoppingList = 'shopping_list';
  static const String collectionWishlist = 'wishlist';
  static const String collectionAlerts = 'alerts';
  static const String collectionDocuments = 'documents';

  // Paths do Firebase Storage
  static const String storageProfilePhotos = 'profile_photos';
  static const String storageDiaryPhotos = 'diary_photos';
  static const String storageDocuments = 'documents';
  static const String storageReceipts = 'receipts';

  // URLs externas
  static const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5';
  static const String privacyPolicyUrl = 'https://costruttore.app/privacy';
  static const String termsOfServiceUrl = 'https://costruttore.app/terms';
  static const String supportEmail = 'suporte@costruttore.app';

  // Regex patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\([0-9]{2}\) [0-9]{4,5}-[0-9]{4}$';
  static const String cpfPattern = r'^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$';
  static const String cnpjPattern =
      r'^[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}$';

  // Fases da construção (ordem)
  static const List<String> constructionPhases = [
    'Projeto',
    'Fundação',
    'Estrutura',
    'Alvenaria',
    'Cobertura',
    'Instalações Hidráulicas',
    'Instalações Elétricas',
    'Revestimentos',
    'Esquadrias',
    'Pintura',
    'Acabamentos',
    'Limpeza Final',
  ];

  // Status de pagamento
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusOverdue = 'overdue';
  static const String paymentStatusCancelled = 'cancelled';

  // Tipos de alerta
  static const String alertTypePayment = 'payment';
  static const String alertTypePhase = 'phase';
  static const String alertTypeWeather = 'weather';
  static const String alertTypeDocument = 'document';
  static const String alertTypeGeneral = 'general';

  // Prioridades
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';
}

// Made with Bob
