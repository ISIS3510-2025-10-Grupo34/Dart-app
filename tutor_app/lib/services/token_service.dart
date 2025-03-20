import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  factory TokenService() {
    return _instance;
  }

  TokenService._internal();

  // Store the authentication token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Retrieve the authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Remove the authentication token (used for logout)
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // Check if a token exists
  Future<bool> hasToken() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
