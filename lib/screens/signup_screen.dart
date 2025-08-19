import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }

    try {
      await AuthService().signUp(email, password);
      Navigator.pushReplacementNamed(context, '/landing');
    } catch (e) {
      setState(() => _error = 'Signup failed. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Lineup', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF033950))),
              if (_error != null) ...[
                SizedBox(height: 10),
                Text(_error!, style: TextStyle(color: Colors.red)),
              ],
              SizedBox(height: 30),
              _buildTextField(_emailController, 'Email'),
              SizedBox(height: 15),
              _buildTextField(_passwordController, 'Password', obscure: true),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF033950),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Already have an account? Sign in', style: TextStyle(color: Color(0xFF033950))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
      ),
    );
  }
}
