import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';
import 'package:ders_project/models/audit_log.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final rows = await DatabaseHelper.instance.getAuditLogs(
        userId: _selectedUserId,
        limit: 500,
      );
      setState(() {
        _logs = rows;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getActionLabel(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return 'Oluştur';
      case 'UPDATE':
        return 'Güncelle';
      case 'DELETE':
        return 'Sil';
      case 'LOGIN':
        return 'Giriş';
      case 'LOGOUT':
        return 'Çıkış';
      default:
        return action;
    }
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      case 'LOGIN':
        return Colors.orange;
      case 'LOGOUT':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return Icons.add_circle_rounded;
      case 'UPDATE':
        return Icons.edit_rounded;
      case 'DELETE':
        return Icons.delete_rounded;
      case 'LOGIN':
        return Icons.login_rounded;
      case 'LOGOUT':
        return Icons.logout_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    if (_searchController.text.isEmpty) return _logs;
    final query = _searchController.text.toLowerCase();
    return _logs.where((log) {
      final action = (log['action'] as String? ?? '').toLowerCase();
      final entity = (log['entity'] as String? ?? '').toLowerCase();
      return action.contains(query) || entity.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Audit Logları',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadLogs,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ara...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedUserId = null;
                          });
                          _loadLogs();
                        },
                        icon: const Icon(Icons.filter_alt_off_rounded),
                        label: const Text('Filtreyi Temizle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_rounded, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz log kaydı yok',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLogs,
                        child: ListView.builder(
                          itemCount: _filteredLogs.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            final action = log['action'] as String? ?? '';
                            final entity = log['entity'] as String? ?? '';
                            final userId = log['user_id'] as int?;
                            final createdAt = log['created_at'] as String? ?? '';
                            final data = log['data'] != null ? jsonDecode(log['data'] as String) : null;
                            final actionColor = _getActionColor(action);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: actionColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _getActionIcon(action),
                                        color: actionColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _getActionLabel(action),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: actionColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: actionColor.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  action.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: actionColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (entity.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.category_rounded, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Varlık: $entity',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (userId != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.person_rounded, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Kullanıcı ID: $userId',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (data != null && data is Map && data.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                data.toString(),
                                                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                                              const SizedBox(width: 4),
                                              Text(
                                                createdAt.length > 16 ? createdAt.substring(0, 16) : createdAt,
                                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

