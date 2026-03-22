import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/table_model.dart';
import '../../../data/services/database_service.dart';

class TableMgmtView extends StatefulWidget {
  const TableMgmtView({Key? key}) : super(key: key);

  @override
  State<TableMgmtView> createState() => _TableMgmtViewState();
}

class _TableMgmtViewState extends State<TableMgmtView> {
  final DatabaseService _dbService = DatabaseService();

  void _showAddTableDialog() {
    final numController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Table', style: TextStyle(color: AppTheme.darkRed, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: numController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Table Number',
                prefixIcon: Icon(Icons.table_restaurant),
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                onPressed: isSaving ? null : () async {
                  final text = numController.text.trim();
                  if (text.isEmpty) return;
                  final num = int.tryParse(text);
                  if (num == null) return;
                  
                  setDialogState(() => isSaving = true);
                  try {
                    await _dbService.addTable(num);
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    setDialogState(() => isSaving = false);
                  }
                },
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showFullScreenQR(TableModel table) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: const CloseButton(color: Colors.black),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.grey),
                tooltip: 'Take a screenshot to save',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Take a screenshot of this page to print the QR Code!'), behavior: SnackBarBehavior.floating),
                  );
                },
              )
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TABLE ${table.tableNumber}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.darkRed, letterSpacing: 2),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: QrImageView(
                    data: table.qrData,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Scan to Order',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  'makanje.com/table/${table.tableNumber}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleYellow,
      appBar: AppBar(
        title: const Text('Table Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkRed,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<TableModel>>(
        stream: _dbService.getTablesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          
          final tables = snapshot.data ?? [];
          if (tables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No tables generated yet.\nTap + to add your first table!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return InkWell(
                onTap: () => _showFullScreenQR(table),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.paleYellow, borderRadius: BorderRadius.circular(12)),
                        child: QrImageView(data: table.qrData, version: QrVersions.auto, size: 70.0),
                      ),
                      const SizedBox(height: 16),
                      Text('Table ${table.tableNumber}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
                      const SizedBox(height: 4),
                      const Text('Tap to Enlarge', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTableDialog,
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Table', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
