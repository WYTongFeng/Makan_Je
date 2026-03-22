import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tableKey = 'active_table_number';
  static const String _timestampKey = 'session_timestamp';
  
  // Define 2 hours session expiry
  static const int _sessionExpiryMinutes = 120;

  // Save specific table locally into shared_preferences
  Future<void> setActiveTable(int tableNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tableKey, tableNumber);
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Returns active table number iff session exists and is unexpired
  Future<int?> getActiveTable() async {
    final prefs = await SharedPreferences.getInstance();
    final tableNumber = prefs.getInt(_tableKey);
    final timestamp = prefs.getInt(_timestampKey);

    if (tableNumber != null && timestamp != null) {
      final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final diff = DateTime.now().difference(sessionTime).inMinutes;

      if (diff <= _sessionExpiryMinutes) {
        return tableNumber;
      } else {
        // Erase memory if it's over 2 hours old
        await clearSession();
        return null;
      }
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tableKey);
    await prefs.remove(_timestampKey);
  }
}
