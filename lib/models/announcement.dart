class Announcement {
  final int id;
  final String title;
  final String content;
  final DateTime date; // auto_now_add من السيرفر

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> j) {
    final rawDate = j['date'];
    DateTime parsedDate;
    if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return Announcement(
      id: j['id'] as int,
      title: j['title'] as String,
      content: j['content'] as String,
      date: parsedDate,
    );
  }

  // عند الإنشاء/التعديل لا نرسل date (السيرفر يضبطه)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  Announcement copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }
}
