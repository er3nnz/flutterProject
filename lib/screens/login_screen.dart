import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';
import 'package:ders_project/screens/register_screen.dart';
import 'package:ders_project/screens/admin_home_screen.dart';
import 'package:ders_project/screens/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final db = DatabaseHelper.instance;
      final user = await db.authenticateUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı adı veya parola yanlış')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giriş başarılı')));
        if (user.role == 'admin') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UserHomeScreen()));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Giriş sırasında hata: ${e.toString()}')));
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
            colors: [Colors.white, theme.colorScheme.primary.withOpacity(0.06)],
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
                            Icon(Icons.lock_open, size: 56, color: theme.colorScheme.primary),
                            const SizedBox(height: 8),
                            Text('Giriş Yap', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                              decoration: InputDecoration(
                                labelText: 'Parola',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              obscureText: _obscure,
                              validator: (v) => (v == null || v.isEmpty) ? 'Parola gerekli' : null,
                            ),
                            const SizedBox(height: 20),

                            _loading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      child: const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                                    ),
                                  ),

                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Hesabın yok mu?'),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                  child: const Text('Kayıt Ol'),
                                ),
                              ],
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
