class Message {
  final String role;
  final String content;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  // Convert to Map for JSON storage
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Map (JSON)
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Helper to copy object with changes
  Message copyWith({String? role, String? content, DateTime? timestamp}) {
    return Message(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}