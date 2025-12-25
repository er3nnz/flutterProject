import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';
import 'package:ders_project/models/user.dart';
import 'users_page_screen.dart';
import 'audit_logs_screeen.dart';

class AdminDashboard extends StatefulWidget {
  final User currentUser;
  const AdminDashboard({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, int>? _metrics;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _loading = true);
    final m = await DatabaseHelper.instance.getMetrics();
    if (mounted) setState(() { _metrics = m; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Paneli')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hoşgeldiniz, ${widget.currentUser.username} (role: ${widget.currentUser.role})'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UsersPage(currentUser: widget.currentUser))), child: const Text('Kullanıcı Yönetimi')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuditLogsPage())), child: const Text('Audit Logları')),
            const SizedBox(height: 16),
            const Text('Sistem Metrikleri', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_metrics == null) Center(child: _loading ? const CircularProgressIndicator() : const Text('No data')) else Expanded(
              child: ListView(
                children: _metrics!.entries.map((e) => ListTile(title: Text(e.key), trailing: Text(e.value.toString()))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
