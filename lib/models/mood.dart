class Mood {
  final String? id;
  final String date;
  final int rating;
  final String emoji;
  final String note;

  Mood({
    this.id,
    required this.date,
    required this.rating,
    required this.emoji,
    required this.note,
  });

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      id: map['id'] as String?,
      date: map['date'] as String? ?? DateTime.now().toString().substring(0, 10),
      rating: map['rating'] as int? ?? 0,
      emoji: map['emoji'] as String? ?? '',
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'rating': rating,
      'emoji': emoji,
      'note': note,
    };
  }
}
