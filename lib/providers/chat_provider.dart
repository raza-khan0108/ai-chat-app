import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChatProvider extends StateNotifier<ChatState> {
  final ChatService _chatService = ChatService();

  ChatProvider() : super(const ChatState()) {
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    final savedMessages = await StorageService.loadChatHistory();
    if (savedMessages.isNotEmpty) {
      state = state.copyWith(messages: savedMessages);
    }
  }

  Future<void> _saveChatHistory() async {
    await StorageService.saveChatHistory(state.messages);
  }

  void addUserMessage(String content) {
    final userMessage = Message(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      error: null,
    );

    _saveChatHistory();
  }

  // IMPROVED SPACING LOGIC
  String _ensureProperSpacing(String current, String newChunk) {
    if (current.isEmpty) return newChunk;
    if (newChunk.isEmpty) return current;

    // Clean the new chunk
    final cleanChunk = newChunk.trim();
    if (cleanChunk.isEmpty) return current;

    // Check what current text ends with
    final currentTrimmed = current.trimRight();
    if (currentTrimmed.isEmpty) return cleanChunk;

    final lastChar = currentTrimmed[currentTrimmed.length - 1];
    final firstChar = cleanChunk[0];

    // Don't add space if:
    // 1. Current ends with whitespace or newline
    // 2. New chunk starts with punctuation
    // 3. New chunk already starts with space
    if (RegExp(r'[\s\n]').hasMatch(lastChar) ||
        RegExp(r'^[,.!?;:\)\]}]').hasMatch(firstChar) ||
        cleanChunk.startsWith(' ')) {
      return current + cleanChunk;
    }

    // Don't add space after punctuation if next is uppercase (sentence start)
    if (RegExp(r'[.!?]').hasMatch(lastChar) &&
        RegExp(r'^[A-Z]').hasMatch(firstChar)) {
      return '$current $cleanChunk';
    }

    // Add space between words
    if (RegExp(r'[a-zA-Z0-9]').hasMatch(lastChar) &&
        RegExp(r'^[a-zA-Z0-9]').hasMatch(firstChar)) {
      return '$current $cleanChunk';
    }

    return current + cleanChunk;
  }

  // IMPROVED FINAL CLEANUP
  String _cleanupResponse(String response) {
    var cleaned = response;

    // Fix common spacing issues
    cleaned = cleaned.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2'); // camelCase to spaced
    cleaned = cleaned.replaceAll(RegExp(r'(\w)(\w+)\s*:\s*'), r'$1$2: '); // Fix colons
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' '); // Multiple spaces to single
    cleaned = cleaned.replaceAll(RegExp(r'\n\s+'), '\n'); // Remove spaces after newlines
    cleaned = cleaned.replaceAll(RegExp(r'\s+\n'), '\n'); // Remove spaces before newlines
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // Max 2 newlines

    // Fix punctuation spacing
    cleaned = cleaned.replaceAllMapped(RegExp(r'\s+([,.!?;:])'), (m) => m[1]!);
    cleaned = cleaned.replaceAllMapped(RegExp(r'([,.!?;:])([A-Za-z0-9])'), (m) => '${m[1]} ${m[2]}');

    // Fix markdown spacing
    cleaned = cleaned.replaceAll(RegExp(r'\*\*\s+'), '**');
    cleaned = cleaned.replaceAll(RegExp(r'\s+\*\*'), '**');
    cleaned = cleaned.replaceAll(RegExp(r'###\s+'), '### ');
    cleaned = cleaned.replaceAll(RegExp(r'##\s+'), '## ');

    return cleaned.trim();
  }

  Future<void> sendMessage(String userMessage) async {
    addUserMessage(userMessage);

    final assistantMessage = Message(
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMessage],
      isLoading: true,
      error: null,
    );

    String assistantResponse = '';
    bool gotFirstChunk = false;

    try {
      final conversationHistory = state.messages
          .where((m) => m.role != 'assistant' || m.content.isNotEmpty)
          .toList();

      await for (final chunk in _chatService.sendMessage(conversationHistory)) {
        if (!gotFirstChunk) {
          gotFirstChunk = true;
          state = state.copyWith(isLoading: false);
        }

        // Use improved spacing logic
        assistantResponse = _ensureProperSpacing(assistantResponse, chunk);

        final updatedMessages = state.messages.toList();
        updatedMessages[updatedMessages.length - 1] = Message(
          role: 'assistant',
          content: assistantResponse,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(messages: updatedMessages);
      }

      // Final cleanup with improved logic
      assistantResponse = _cleanupResponse(assistantResponse);

      final finalMessages = state.messages.toList();
      finalMessages[finalMessages.length - 1] = Message(
        role: 'assistant',
        content: assistantResponse,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );

      _saveChatHistory();

    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> clearChat() async {
    await StorageService.clearChatHistory();
    state = const ChatState();
  }

  Future<void> saveConversation(String title) async {
    if (state.messages.isNotEmpty) {
      await StorageService.saveConversation(title, state.messages);
    }
  }

  Future<void> loadConversation(String conversationKey) async {
    final messages = await StorageService.loadConversation(conversationKey);
    state = state.copyWith(messages: messages);
  }
}

final chatProvider = StateNotifierProvider<ChatProvider, ChatState>((ref) {
  return ChatProvider();
});
