import 'package:flutter/material.dart';
import 'package:ders_project/models/user.dart';
import 'package:ders_project/services/auth_service.dart';
import 'package:ders_project/screens/login_screen.dart';
import 'package:ders_project/db/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  late VoidCallback _authListener;

  @override
  void initState() {
    super.initState();
    _authListener = () {
      setState(() {
        _currentUser = AuthService.instance.currentUser.value;
      });
    };
    AuthService.instance.currentUser.addListener(_authListener);
    _loadUserProfile();
  }

  @override
  void dispose() {
    AuthService.instance.currentUser.removeListener(_authListener);
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final user = await AuthService.instance.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  // New: Edit profile (username)
  Future<void> _showEditProfileDialog() async {
    final db = DatabaseHelper.instance;
    final usernameController = TextEditingController(text: _currentUser?.username ?? '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Bilgilerini Düzenle'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Kullanıcı adı gerekli' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newUsername = usernameController.text.trim();
              try {
                final check = await db.getUserByUsername(newUsername);
                if (check != null && check.id != _currentUser?.id) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu kullanıcı adı zaten kullanılıyor')));
                  return;
                }

                if (_currentUser?.id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı')));
                  return;
                }

                await db.updateUsername(_currentUser!.id!, newUsername);
                final updated = await db.getUserById(_currentUser!.id!);
                if (updated != null) {
                  await AuthService.instance.setCurrentUser(updated);
                }

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı adı güncellendi')));
                Navigator.pop(context, true);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Güncelleme başarısız: ${e.toString()}')));
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result == true) _loadUserProfile();
  }

  Future<void> _showChangePasswordDialog() async {
    final db = DatabaseHelper.instance;
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                decoration: const InputDecoration(labelText: 'Mevcut Parola'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Mevcut parola gerekli' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: newController,
                decoration: const InputDecoration(labelText: 'Yeni Parola'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 4) ? 'Yeni parola en az 4 karakter olmalı' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmController,
                decoration: const InputDecoration(labelText: 'Yeni Parola (Tekrar)'),
                obscureText: true,
                validator: (v) => (v != newController.text) ? 'Parolalar eşleşmiyor' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (_currentUser == null || _currentUser!.id == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı')));
                return;
              }

              try {
                final auth = await db.authenticateUser(username: _currentUser!.username, password: currentController.text);
                if (auth == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mevcut parola yanlış')));
                  return;
                }

                await db.changePassword(userId: _currentUser!.id!, newPassword: newController.text);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parola başarıyla değiştirildi')));
                Navigator.pop(context, true);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şifre değiştirilemedi: ${e.toString()}')));
              }
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );

    if (result == true) _loadUserProfile();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.clear();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Çıkış yapıldı'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ayarlar yakında eklenecek'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _currentUser?.username ?? 'Kullanıcı',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentUser?.role ?? 'Kullanıcı',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          Icons.person_outline_rounded,
                          'Kullanıcı Adı',
                          _currentUser?.username ?? 'Belirtilmemiş',
                          Colors.blue,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          Icons.badge_outlined,
                          'Rol',
                          _currentUser?.role ?? 'Belirtilmemiş',
                          Colors.purple,
                        ),
                        if (_currentUser?.createdAt != null) ...[
                          const Divider(height: 1),
                          _buildInfoTile(
                            Icons.calendar_today_outlined,
                            'Kayıt Tarihi',
                            _currentUser!.createdAt!.toIso8601String().substring(0, 10),
                            Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildActionTile(
                          Icons.edit_rounded,
                          'Profil Bilgilerini Düzenle',
                          Colors.blue,
                          () {
                            _showEditProfileDialog();
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          Icons.lock_outline_rounded,
                          'Şifre Değiştir',
                          Colors.orange,
                          () {
                            _showChangePasswordDialog();
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          Icons.info_outline_rounded,
                          'Hakkında',
                          Colors.green,
                          () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Stok Yönetim Sistemi',
                              applicationVersion: '1.0.0',
                              applicationIcon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.inventory_2_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Çıkış Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}
