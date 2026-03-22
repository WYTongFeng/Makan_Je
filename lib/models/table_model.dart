import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  final String id;
  final int tableNumber;
  final String qrData;
  final DateTime createdAt;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.qrData,
    required this.createdAt,
  });

  factory TableModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TableModel(
      id: id,
      tableNumber: data['table_number'] ?? 0,
      qrData: data['qr_data'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'table_number': tableNumber,
      'qr_data': qrData,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
