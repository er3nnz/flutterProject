import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String _role = 'user';
  String? _error;
  bool _loading = false;

  Future<void> _register() async {
    setState(() { _error = null; _loading = true; });
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() { _error = 'Kullanıcı adı ve parola gerekli'; _loading = false; });
      return;
    }
    if (password != confirm) {
      setState(() { _error = 'Parolalar eşleşmiyor'; _loading = false; });
      return;
    }
    try {
      await DatabaseHelper.instance.registerUser(username: username, password: password, role: _role);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt başarılı')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Kullanıcı adı')),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Parola'), obscureText: true),
            const SizedBox(height: 8),
            TextField(controller: _confirmController, decoration: const InputDecoration(labelText: 'Parola (tekrar)'), obscureText: true),
            const SizedBox(height: 8),
            DropdownButton<String>(value: _role, items: const [DropdownMenuItem(value: 'user', child: Text('User')), DropdownMenuItem(value: 'staff', child: Text('Staff')), DropdownMenuItem(value: 'admin', child: Text('Admin'))], onChanged: (v) { if (v!=null) setState(()=>_role=v); }),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Kayıt')),
          ],
        ),
      ),
    );
  }
}

