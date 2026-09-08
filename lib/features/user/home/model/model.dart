import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String userId;
  final String busId;
  final DateTime reminderTime;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.busId,
    required this.reminderTime,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'busId': busId,
      'reminderTime': Timestamp.fromDate(reminderTime),
      'sent': false,
    };
  }

  factory ReminderModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    final timestamp = data['reminderTime'] as Timestamp;

    return ReminderModel(
      id: id,
      userId: data['userId'] ?? '',
      busId: data['busId'] ?? '',
      reminderTime: timestamp.toDate(),
    );
  }
}