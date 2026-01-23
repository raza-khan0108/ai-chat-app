import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

// --- State Class ---
class ChatState {
  final List<Message> messages;
  final bool isLoading; // Waiting for response to start
  final String? currentChatId; // ID of the current conversation

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.currentChatId,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? currentChatId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentChatId: currentChatId ?? this.currentChatId,
    );
  }
}

// --- Provider Notifier ---
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();

  ChatNotifier() : super(ChatState(currentChatId: const Uuid().v4()));

  // 1. Send Message
  Future<void> sendMessage(String content) async {
    // FIX: Added timestamp: DateTime.now()
    final userMsg = Message(
        role: 'user',
        content: content,
        timestamp: DateTime.now()
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true, // Start loading animation
    );

    // Prepare AI Message Placeholder
    // FIX: Added timestamp
    String aiResponse = "";
    final aiMsg = Message(
        role: 'assistant',
        content: "",
        timestamp: DateTime.now()
    );

    try {
      final stream = _chatService.sendMessage(state.messages);

      bool firstChunk = true;

      await for (final chunk in stream) {
        aiResponse += chunk;

        if (firstChunk) {
          // Response started! Stop "Loading" (dots) and show the message bubble
          // This prevents the "Double Icon" bug
          state = state.copyWith(
              isLoading: false,
              messages: [...state.messages, aiMsg.copyWith(content: aiResponse)]
          );
          firstChunk = false;
        } else {
          // Update the last message with new content
          final updatedMessages = List<Message>.from(state.messages);
          updatedMessages.last = updatedMessages.last.copyWith(content: aiResponse);
          state = state.copyWith(messages: updatedMessages);
        }
      }

      // Auto-save after response is complete
      _autoSave();

    } catch (e) {
      // FIX: Added timestamp to error message
      state = state.copyWith(
          isLoading: false,
          messages: [...state.messages, Message(
              role: 'assistant',
              content: "Error: $e",
              timestamp: DateTime.now()
          )]
      );
    }
  }

  // 2. Save Chat Manually
  Future<void> saveChat() async {
    if (state.messages.isEmpty) return;

    // Use the first user message as the title, or "New Chat"
    String title = "New Chat";
    final firstUserMsg = state.messages.firstWhere(
            (m) => m.role == 'user',
        orElse: () => Message(role: 'user', content: 'New Chat', timestamp: DateTime.now())
    );

    title = firstUserMsg.content.length > 30
        ? firstUserMsg.content.substring(0, 30)
        : firstUserMsg.content;

    await _storageService.saveChat(state.currentChatId!, title, state.messages);
  }

  // Internal Auto-save
  Future<void> _autoSave() async {
    if (state.messages.isNotEmpty) {
      await saveChat();
    }
  }

  // 3. Load Chat from History
  Future<void> loadChat(String chatId) async {
    state = state.copyWith(isLoading: true);
    final messages = await _storageService.loadChat(chatId);
    state = state.copyWith(
        messages: messages,
        currentChatId: chatId,
        isLoading: false
    );
  }

  // 4. New Chat / Clear
  void clearChat() {
    state = ChatState(
        messages: [],
        isLoading: false,
        currentChatId: const Uuid().v4() // Generate new ID
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});