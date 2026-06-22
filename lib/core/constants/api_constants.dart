class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.200.217.71:8000',
  );

  // Direct auth service URL (bypass Kong) for development
  static const String authBaseUrl = String.fromEnvironment(
    'API_AUTH_URL',
    defaultValue: 'http://10.200.217.71:8084',
  );

  static const String loginPath = '/api/auth/login';

  static const String clientsPath = '/api/clients';
  static const String accountsPath = '/api/accounts';
  static const String transactionsPath = '/api/transactions';
  static const String loansPath = '/api/loans';
  static const String authPath = '/api/auth';
  static const String ocrPath = '/api/ai-ocr';
  static const String notificationsPath = '/api/notifications';
}
