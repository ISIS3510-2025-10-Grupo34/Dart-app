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
      } else if (response.statusCode == 400) {
        String errorMessage = '. Try again';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] + errorMessage;
        } catch (_) {}
        throw errorMessage;
      } else {
        throw "Internal Server Error";
      }
    } catch (e) {
      throw 'Couldn\'t contact the server. Please check your connection.';
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

  Future<bool> checkEmailExists(String email) async {
    final url = Uri.parse('${EnvConfig.apiUrl}/api/email-check/');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: '"$email"',
      );

      if (response.statusCode == 201) {
        return false;
      } else if (response.statusCode == 400 || response.statusCode == 500) {
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody['error']
                  ?.toString()
                  .contains("Email already exists") ==
              true) {
            return true;
          } else {
            throw 'Internal Server Error';
          }
        } catch (e) {
          throw 'Internal Server Error';
        }
      } else {
        throw 'Internal Server Error';
      }
    } catch (e) {
      throw 'Could not check email. Please check your connection.';
    }
  }
}
