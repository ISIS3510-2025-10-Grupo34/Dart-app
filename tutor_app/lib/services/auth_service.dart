import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env_config.dart';

class AuthService {
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiUrl}/api/login/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data["data"]["token"];
        final Map<String, dynamic> userData = decodeJwt(token);
        return userData;
      } else {
        String errorMessage =
            'Login failed (Status code: ${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(
        'Error during login: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token inválido');
      }
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload);
    } catch (e) {
      throw Exception('Error al decodificar el token');
    }
  }
}
