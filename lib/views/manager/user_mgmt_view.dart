import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/manager_view_model.dart';

class UserMgmtView extends StatefulWidget {
  const UserMgmtView({Key? key}) : super(key: key);

  @override
  State<UserMgmtView> createState() => _UserMgmtViewState();
}

class _UserMgmtViewState extends State<UserMgmtView> {
  final ManagerViewModel _viewModel = ManagerViewModel();

  void _showRegisterModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'staff';
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paleYellow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Register New User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkRed), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email, color: AppTheme.primaryOrange), filled: true, fillColor: AppTheme.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      validator: (v) => v!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passCtrl,
                      decoration: InputDecoration(labelText: 'Password (min 6 chars)', prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryOrange), filled: true, fillColor: AppTheme.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(labelText: 'Role', prefixIcon: const Icon(Icons.badge, color: AppTheme.primaryOrange), filled: true, fillColor: AppTheme.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      items: const [
                        DropdownMenuItem(value: 'staff', child: Text('Staff (Kitchen Display)')),
                        DropdownMenuItem(value: 'manager', child: Text('Manager (Full Access)')),
                      ],
                      onChanged: (val) => setModalState(() => selectedRole = val!),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: isLoading ? null : () async {
                          if (!formKey.currentState!.validate()) return;
                          setModalState(() => isLoading = true);
                          try {
                            await _viewModel.registerStaffUser(emailCtrl.text, passCtrl.text, selectedRole);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User registered successfully!', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryOrange));
                            }
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.darkRed));
                          } finally {
                            if (mounted) setModalState(() => isLoading = false);
                          }
                        },
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account', style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      appBar: AppBar(title: const Text('User Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), backgroundColor: AppTheme.white, foregroundColor: AppTheme.darkRed, elevation: 0, centerTitle: true, bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.darkRed)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          final users = snapshot.data?.docs ?? [];
          if (users.isEmpty) return const Center(child: Text('No users found.', style: TextStyle(color: Colors.grey)));
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final userDoc = users[index].data() as Map<String, dynamic>;
              final email = userDoc['email'] ?? 'Unknown';
              final role = userDoc['role'] ?? 'staff';
              return Container(
                decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(backgroundColor: role == 'manager' ? AppTheme.darkRed.withOpacity(0.2) : AppTheme.primaryOrange.withOpacity(0.2), child: Icon(role == 'manager' ? Icons.admin_panel_settings : Icons.person, color: role == 'manager' ? AppTheme.darkRed : AppTheme.primaryOrange)),
                  title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
                  subtitle: Text('Role: ${role.toString().toUpperCase()}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryOrange,
        onPressed: () => _showRegisterModal(context),
        icon: const Icon(Icons.person_add, color: AppTheme.white),
        label: const Text('Register Account', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
