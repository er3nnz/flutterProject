import 'package:ders_project/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';
import 'package:ders_project/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _seedAdminIfMissing();
  await AuthService.instance.init();
  runApp(const MyApp());
}

Future<void> _seedAdminIfMissing() async {
  final db = DatabaseHelper.instance;
  await db.database;

  const adminUsername = 'admin';
  const adminPassword = 'admin123';

  try {
    final existing = await db.getUserByUsername(adminUsername);
    if (existing == null) {
      await db.registerUser(username: adminUsername, password: adminPassword, role: 'admin');
    } else {
      print('Admin user already exists');
    }
  } catch (e) {
    print('Error while seeding admin user: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stok Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
