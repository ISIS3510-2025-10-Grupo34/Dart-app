import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import 'home_screen.dart';
import 'home_screen_student.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _userService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context
      );

      if (response != null && response.containsKey('token')) {
        final String token = response['token'];

        // Guardar token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Decodificar token para obtener el rol
        try {
          Map<String, dynamic> decodedToken = _decodeJwt(token);
          String role = decodedToken["role"] ?? "";

          // Redirigir según el rol
          if (role == "student") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreenStudent()),
            );
          } else if (role == "tutor") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            setState(() {
              _errorMessage = "Rol de usuario no válido";
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = "Error al procesar el token";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Credenciales incorrectas";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token inválido');
      }
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload);
    } catch (e) {
      throw Exception('Error al decodificar el token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                "TutorApp",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xFF171F45)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Enter your credentials to login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 32),
              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Error Message (if any)
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF171F45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                      : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
