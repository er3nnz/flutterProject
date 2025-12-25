import 'package:flutter/material.dart';
import 'package:ders_project/db/database_helper.dart';
import 'package:ders_project/models/user.dart';

class UsersPage extends StatefulWidget {
  final User currentUser;
  const UsersPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await DatabaseHelper.instance.getAllUsers();
    if (mounted) setState(() { _users = users; _loading = false; });
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Kullanıcı silinsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sil')),
        ],
      ),
    );
    if (ok != true) return;
    await DatabaseHelper.instance.deleteUserById(id, actorUserId: widget.currentUser.id);
    await _load();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı silindi')));
  }

  Future<void> _changeRole(int id) async {
    final newRole = await showDialog<String?>(context: context, builder: (_) {
      String selected = 'user';
      return AlertDialog(
        title: const Text('Rol değiştir'),
        content: DropdownButton<String>(value: selected, items: const [DropdownMenuItem(value: 'user', child: Text('user')), DropdownMenuItem(value: 'staff', child: Text('staff')), DropdownMenuItem(value: 'admin', child: Text('admin'))], onChanged: (v){ if (v!=null) selected=v; },),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')), TextButton(onPressed: () => Navigator.of(context).pop(selected), child: const Text('Kaydet'))],
      );
    });
    if (newRole != null) {
      await DatabaseHelper.instance.updateUserRole(id, newRole, actorUserId: widget.currentUser.id);
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rol güncellendi')));
    }
  }

  Future<void> _resetPassword(int id) async {
    final newPass = await showDialog<String?>(context: context, builder: (_) {
      final ctrl = TextEditingController();
      return AlertDialog(
        title: const Text('Parola sıfırla'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Yeni parola')),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')), TextButton(onPressed: () => Navigator.of(context).pop(ctrl.text), child: const Text('Sıfırla'))],
      );
    });
    if (newPass != null && newPass.isNotEmpty) {
      await DatabaseHelper.instance.resetUserPassword(id, newPass, actorUserId: widget.currentUser.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parola sıfırlandı')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcılar')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, i) {
          final u = _users[i];
          return ListTile(
            title: Text(u.username),
            subtitle: Text('Role: ${u.role}'),
            trailing: PopupMenuButton<String>(onSelected: (v){ if (v=='delete') _delete(u.id!); else if (v=='role') _changeRole(u.id!); else if (v=='reset') _resetPassword(u.id!); }, itemBuilder: (_) => [const PopupMenuItem(value: 'role', child: Text('Rol değiştir')), const PopupMenuItem(value: 'reset', child: Text('Parolayı sıfırla')), const PopupMenuItem(value: 'delete', child: Text('Sil'))]),
          );
        },
      ),
    );
  }
}
