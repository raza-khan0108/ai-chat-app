class Message {
  final String role;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.now(),
    );
  }

  Message copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return Message(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
