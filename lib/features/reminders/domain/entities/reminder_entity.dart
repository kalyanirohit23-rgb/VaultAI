import 'package:equatable/equatable.dart';

class ReminderEntity extends Equatable {
  const ReminderEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.reminderDate,
    this.documentId,
    this.isCompleted = false,
    this.isRecurring = false,
    this.recurringDays,
    this.type = 'document_expiry',
    this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime reminderDate;
  final String? documentId;
  final bool isCompleted;
  final bool isRecurring;
  final int? recurringDays;
  final String type;
  final DateTime? createdAt;

  bool get isOverdue => !isCompleted && reminderDate.isBefore(DateTime.now());
  bool get isDueToday => !isCompleted &&
      reminderDate.year == DateTime.now().year &&
      reminderDate.month == DateTime.now().month &&
      reminderDate.day == DateTime.now().day;

  @override
  List<Object?> get props => [id, userId, title, reminderDate, isCompleted];
}
