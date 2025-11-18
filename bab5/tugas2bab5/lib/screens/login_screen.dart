import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierC = TextEditingController();
  final _passwordC = TextEditingController();
  bool _remember = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _identifierC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AuthService.login(
        identifier: _identifierC.text,
        password: _passwordC.text,
      );

      if (_remember) {
        await TokenStorage.save(result.token);
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _required(String? v, {String label = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
          /// =========================================================
          /// BACKGROUND LOGO TRANSPARAN
          /// =========================================================
          Positioned.fill(
            child: Opacity(
              opacity: 0.08, // semakin kecil semakin samar
              child: Center(
                child: Image.asset(
                  "assets/images/logo.jpg", // GANTI DENGAN LOGO ANDA
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          /// =========================================================
          /// FORM LOGIN
          /// =========================================================
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                  "Hello sobat HMTI",
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tolong ACCnya kaka 🙏🏻",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _identifierC,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (v) => _required(v, label: 'Email'),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordC,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (v) => _required(v, label: 'Password'),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Checkbox(
                            value: _remember,
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                            side: const BorderSide(color: Colors.black, width: 1.5),
                            onChanged: (v) => setState(() => _remember = v ?? true),
                          ),
                          const Text('Remember me', style: TextStyle(color: Colors.black)),
                        ]),
                        GestureDetector(
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Color.fromARGB(255, 40, 2, 255),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],

                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: Colors.black)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Color.fromARGB(255, 0, 79, 250), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
