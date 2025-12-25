// Audit logs viewer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';

class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({Key? key}) : super(key: key);

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await DatabaseHelper.instance.getAuditLogs(limit: 500);
    if (!mounted) return;
    setState(() {
      _logs = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Loglar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, i) {
                final row = _logs[i];
                final data = row['data'] != null ? jsonDecode(row['data'] as String) : null;
                return ListTile(
                  title: Text('${row['action']} - ${row['entity'] ?? ''}'),
                  subtitle: Text('user:${row['user_id']} at ${row['created_at']}\n${data != null ? data.toString() : ''}'),
                );
              },
            ),
    );
  }
}
