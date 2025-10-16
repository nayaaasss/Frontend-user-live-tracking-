import 'package:auth_user/ui/auth/login/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:auth_user/utils/validators.dart';
import 'package:auth_user/widgets/login_textfield.dart';
import 'package:auth_user/models/register_request_model.dart';
import 'package:auth_user/repositories/register_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = "user";
  final _repo = RegisterRepository();
  bool _loading = false;
  bool _isObscure = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return; // kalau form belum valid, jangan lanjut
    }

    setState(() => _loading = true);

    final result = await _repo.register(
      RegisterRequestModel(
        email: _emailController.text,
        password: _passwordController.text,
        role: _role,
      ),
    );

    setState(() => _loading = false);

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi sukses! Silakan login.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else if (result == "already_exists") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email sudah terdaftar, silakan login.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan, coba lagi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign up to get started",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 40),

                // Email field
                LoginTextfield(
                  labelText: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  inputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password field
                LoginTextfield(
                  labelText: "Password",
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  inputAction: TextInputAction.done,
                  isObscure: _isObscure,
                  hasSuffix: true,
                  onSuffixPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),

                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF0D47A1,
                          ), // biru tua solid
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 12, 
                          shadowColor: const Color.fromARGB(255, 15, 2, 161).withOpacity(
                            0.4,
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
