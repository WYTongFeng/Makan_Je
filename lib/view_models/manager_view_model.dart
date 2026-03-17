import 'package:flutter/material.dart';
import '../data/services/database_service.dart';

class ManagerViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Function called when the manager taps the toggle switch
  Future<void> toggleItemAvailability(String itemId, bool currentStatus) async {
    _isLoading = true;
    notifyListeners(); // Tells the UI to show a loading spinner

    try {
      // Flip the boolean
      bool newStatus = !currentStatus;
      await _dbService.updateSoldOutStatus(itemId, newStatus);
    } catch (e) {
      print("Toggle failed");
      // Here you would normally trigger an error message to the UI
    } finally {
      _isLoading = false;
      notifyListeners(); // Tells the UI to hide the loading spinner
    }
  }
}
