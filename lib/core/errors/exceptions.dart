class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {}

class UnauthorizedException implements Exception {}

class NetworkException implements Exception {}

class TwoFARequiredException implements Exception {
  final String email;
  TwoFARequiredException(this.email);
}
