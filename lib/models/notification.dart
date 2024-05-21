class Notification {
  final String id;
  final String ceoName;
  final String companyName;
  final DateTime date;
  final String message;
  final bool isRead;
  final String senderId;

  Notification({
    required this.id,
    required this.ceoName,
    required this.companyName,
    required this.date,
    required this.message,
    required this.senderId,
    this.isRead = false,
  });

  factory Notification.fromMap(Map<String, dynamic> data) {
    return Notification(
      id: data['id'] ?? '',
      ceoName: data['ceoName'] ?? 'Unknown CEO',
      companyName: data['companyName'] ?? 'Unknown Company',
      date: DateTime.tryParse(data['date']) ?? DateTime.now(),
      message: data['message'] ?? '',
      senderId: data['senderId'] ?? '',
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ceoName': ceoName,
      'companyName': companyName,
      'date': date.toIso8601String(),
      'message': message,
      'senderId': senderId,
      'isRead': isRead,
    };
  }
}
