import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameC = TextEditingController();
  final _usernameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _remember = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _nameC.dispose();
    _usernameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _passwordC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AuthService.register(
        name: _nameC.text.trim(),
        username: _usernameC.text.trim(),
        email: _emailC.text.trim(),
        phone: _phoneC.text.trim(),
        password: _passwordC.text,
        passwordConfirmation: _confirmC.text,
      );

      if (_remember) {
        await TokenStorage.save(result.token);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil!')),
      );
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Sign Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bikin akun tra sob,',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 32),

              TextFormField(
                controller: _nameC,
                decoration: _decoration('Full Name'),
                validator: (v) => _required(v, label: 'Full Name'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameC,
                decoration: _decoration('Username'),
                validator: (v) => _required(v, label: 'Username'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailC,
                decoration: _decoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final r = _required(v, label: 'Email');
                  if (r != null) return r;
                  final s = v!.trim();
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneC,
                decoration: _decoration('Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => _required(v, label: 'Phone'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordC,
                obscureText: _obscurePassword,
                decoration: _decoration('Password', suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                )),
                validator: (v) {
                  final r = _required(v, label: 'Password');
                  if (r != null) return r;
                  if ((v?.length ?? 0) < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmC,
                obscureText: _obscureConfirm,
                decoration: _decoration('Confirm Password', suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                )),
                validator: (v) {
                  final r = _required(v, label: 'Confirm Password');
                  if (r != null) return r;
                  if (v != _passwordC.text) return 'Password tidak sama';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? true),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const Text('Remember me', style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Tambahkan fungsi jika kamu punya halaman lupa password
                    },
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 0, 140, 255))), // Warna biru
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: const TextStyle(color: Color.fromARGB(255, 0, 140, 255), fontWeight: FontWeight.bold), // Warna biru
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      suffixIcon: suffixIcon,
    );
  }
}