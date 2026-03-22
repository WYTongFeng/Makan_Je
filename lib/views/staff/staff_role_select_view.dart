import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'kds_view.dart';
import 'waiter_view.dart';
import '../common/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StaffRoleSelectView extends StatelessWidget {
  const StaffRoleSelectView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      appBar: AppBar(
        title: const Text('Staff Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkRed,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Your Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildRoleCard(
              context,
              title: 'Kitchen Display (KDS)',
              icon: Icons.soup_kitchen,
              color: AppTheme.darkRed,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KdsView())),
            ),
            const SizedBox(height: 24),
            _buildRoleCard(
              context,
              title: 'Waiter Dashboard',
              icon: Icons.room_service,
              color: AppTheme.primaryOrange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WaiterView())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
              ),
              child: Center(child: Icon(icon, size: 48, color: color)),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkGrey),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
