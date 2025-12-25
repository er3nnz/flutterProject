import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';
import 'package:ders_project/services/auth_service.dart';
import 'package:ders_project/screens/admin_home_screen.dart';
import 'package:ders_project/screens/user_home_screen.dart';
import 'package:ders_project/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final db = DatabaseHelper.instance;
      await db.registerUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        role: 'user',
      );

      final user = await db.getUserByUsername(_usernameController.text.trim());

      if (user != null) {
        await AuthService.instance.setCurrentUser(user);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt başarılı')));

      if (user != null && user.role == 'admin') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UserHomeScreen()));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt başarısız: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withValues(alpha: 0.08), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.app_registration, size: 56, color: theme.colorScheme.primary),
                            const SizedBox(height: 8),
                            Text('Kayıt Ol', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(labelText: 'Kullanıcı adı', prefixIcon: Icon(Icons.person)),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Kullanıcı adı gerekli' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(labelText: 'Parola', prefixIcon: Icon(Icons.lock)),
                              obscureText: true,
                              validator: (v) => (v == null || v.length < 4) ? 'Parola en az 4 karakter olmalı' : null,
                            ),
                            const SizedBox(height: 20),
                            _loading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _register,
                                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      child: const Text('Kayıt Ol', style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                              child: const Text('Zaten hesabınız var mı? Giriş yapın'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
