import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'menu_mgmt_view.dart';
import 'user_mgmt_view.dart';
import 'dashboard_view.dart';
import 'table_mgmt_view.dart';

class ManagerHostView extends StatefulWidget {
  const ManagerHostView({Key? key}) : super(key: key);

  @override
  State<ManagerHostView> createState() => _ManagerHostViewState();
}

class _ManagerHostViewState extends State<ManagerHostView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MenuMgmtView(),
    const UserMgmtView(),
    const DashboardView(),
    const TableMgmtView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppTheme.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Staff',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Tables',
          ),
        ],
      ),
    );
  }
}
