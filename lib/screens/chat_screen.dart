import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import 'chat_history_screen.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  void _showSaveConversationDialog(BuildContext context, WidgetRef ref) {
    final chatNotifier = ref.read(chatProvider.notifier);
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D30),
        title: const Text(
          'Save Conversation',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter conversation title',
            hintStyle: TextStyle(color: Color(0xFF6C7293)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF10A37F)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6C7293)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                chatNotifier.saveConversation(titleController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversation saved!'),
                    backgroundColor: Color(0xFF10A37F),
                  ),
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF10A37F)),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D30),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF10A37F)),
              title: const Text(
                'Chat History',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatHistoryScreen(),
                  ),
                );
              },
            ),
            if (chatState.messages.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.save, color: Color(0xFF10A37F)),
                title: const Text(
                  'Save Conversation',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSaveConversationDialog(context, ref);
                },
              ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Color(0xFF10A37F)),
              title: const Text(
                'New Chat',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatProvider.notifier).clearChat();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10A37F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Clarity.AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // History button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.history,
              color: Colors.white,
            ),
            tooltip: 'Chat History',
          ),
          // Menu button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2D2D30),
            onSelected: (value) {
              switch (value) {
                case 'save':
                  if (chatState.messages.isNotEmpty) {
                    _showSaveConversationDialog(context, ref);
                  }
                  break;
                case 'new_chat':
                  chatNotifier.clearChat();
                  break;
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatHistoryScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Color(0xFF10A37F)),
                    SizedBox(width: 8),
                    Text('Chat History', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              if (chatState.messages.isNotEmpty)
                const PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.save, color: Color(0xFF10A37F)),
                      SizedBox(width: 8),
                      Text('Save Chat', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.add, color: Color(0xFF10A37F)),
                    SizedBox(width: 8),
                    Text('New Chat', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Color(0xFF6C7293),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Start a conversation',
                    style: TextStyle(
                      color: Color(0xFF6C7293),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ask me anything about AI, technology, or any topic',
                    style: TextStyle(
                      color: Color(0xFF6C7293),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 16, color: Color(0xFF6C7293)),
                      SizedBox(width: 4),
                      Text(
                        'Tap history icon to view past conversations',
                        style: TextStyle(
                          color: Color(0xFF6C7293),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                final isLastMessage = index == chatState.messages.length - 1;
                final isStreaming = chatState.isLoading &&
                    isLastMessage &&
                    message.role == 'assistant';

                return MessageBubble(
                  message: message,
                  isStreaming: isStreaming,
                );
              },
            ),
          ),
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade700),
              ),
              child: Text(
                'Error: ${chatState.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ChatInput(
            onSendMessage: (message) => chatNotifier.sendMessage(message),
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }
}
