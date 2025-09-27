import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../providers/chat_provider.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {
    final loadedConversations = await StorageService.getConversationsList();
    setState(() {
      conversations = loadedConversations;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Chat History',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF10A37F),
        ),
      )
          : conversations.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Color(0xFF6C7293),
            ),
            SizedBox(height: 16),
            Text(
              'No saved conversations',
              style: TextStyle(
                color: Color(0xFF6C7293),
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start chatting and save conversations to see them here',
              style: TextStyle(
                color: Color(0xFF6C7293),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final date = DateTime.fromMillisecondsSinceEpoch(
            conversation['timestamp'],
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF404040),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10A37F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                conversation['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Color(0xFF6C7293),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6C7293),
                size: 16,
              ),
              onTap: () {
                ref.read(chatProvider.notifier).loadConversation(
                  conversation['key'],
                );
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
