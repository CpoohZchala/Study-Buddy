class Session {
  int? id;
  String subject;
  DateTime date;
  int durationMinutes;
  String? notes;

  Session({
    this.id,
    required this.subject,
    required this.date,
    required this.durationMinutes,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      subject: map['subject'],
      date: DateTime.parse(map['date']),
      durationMinutes: map['durationMinutes'],
      notes: map['notes'],
    );
  }
}
