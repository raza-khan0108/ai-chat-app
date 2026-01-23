import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const String _historyKey = 'chat_history_index';

  // Save a chat session
  Future<void> saveChat(String chatId, String title, List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Save the messages for this specific chat ID
    final messagesJson = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_$chatId', messagesJson);

    // 2. Update the index (list of all saved chats)
    final historyJson = prefs.getString(_historyKey);
    List<Map<String, dynamic>> history = [];

    if (historyJson != null) {
      history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    }

    // Remove existing entry if updating
    history.removeWhere((item) => item['id'] == chatId);

    // Add new entry at the top
    history.insert(0, {
      'id': chatId,
      'title': title,
      'timestamp': DateTime.now().toIso8601String(),
      'preview': messages.last.content.take(50), // Store snippet
    });

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Get list of all saved chats (for the History Screen)
  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_historyKey);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }

  // Load a specific chat
  Future<List<Message>> loadChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('chat_$chatId');
    if (json == null) return [];

    final List<dynamic> rawList = jsonDecode(json);
    return rawList.map((m) => Message.fromJson(m)).toList();
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove messages
    await prefs.remove('chat_$chatId');

    // Remove from index
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      history.removeWhere((item) => item['id'] == chatId);
      await prefs.setString(_historyKey, jsonEncode(history));
    }
  }
}

extension StringExtension on String {
  String take(int n) => length > n ? '${substring(0, n)}...' : this;
}