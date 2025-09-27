import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const String _chatHistoryKey = 'clarity_chat_history';

  // Save chat history
  static Future<void> saveChatHistory(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((msg) => msg.toJson()).toList();
      final jsonString = jsonEncode(messagesJson);
      await prefs.setString(_chatHistoryKey, jsonString);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  // Load chat history
  static Future<List<Message>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_chatHistoryKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  // Clear chat history
  static Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  // Save individual conversation with timestamp
  static Future<void> saveConversation(String title, List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final conversationKey = 'conversation_$timestamp';

      final conversationData = {
        'title': title,
        'timestamp': timestamp,
        'messages': messages.map((msg) => msg.toJson()).toList(),
      };

      await prefs.setString(conversationKey, jsonEncode(conversationData));

      // Also update conversations list
      final conversationsList = await getConversationsList();
      conversationsList.add({
        'key': conversationKey,
        'title': title,
        'timestamp': timestamp,
      });
      await prefs.setString('conversations_list', jsonEncode(conversationsList));
    } catch (e) {
      print('Error saving conversation: $e');
    }
  }

  // Get list of saved conversations
  static Future<List<Map<String, dynamic>>> getConversationsList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('conversations_list');

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading conversations list: $e');
      return [];
    }
  }

  // Load specific conversation
  static Future<List<Message>> loadConversation(String conversationKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(conversationKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final Map<String, dynamic> conversationData = jsonDecode(jsonString);
      final List<dynamic> messagesJson = conversationData['messages'];
      return messagesJson.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Error loading conversation: $e');
      return [];
    }
  }
}
