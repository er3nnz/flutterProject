import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';
import 'register_page.dart';
import 'admin_dashboard.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    try {
      final user = await DatabaseHelper.instance.authenticateUser(username: username, password: password);
      if (user == null) {
        setState(() {
          _error = 'Kullanıcı adı veya parola hatalı';
        });
      } else {
        // Navigate based on role
        if (user.role == 'admin') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AdminDashboard(currentUser: user)));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage(title: 'Hoşgeldiniz')));
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Giriş sırasında hata: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Parola'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading ? const CircularProgressIndicator() : const Text('Giriş'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: const Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
