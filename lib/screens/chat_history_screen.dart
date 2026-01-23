import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../providers/chat_provider.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  final StorageService _storage = StorageService();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = _storage.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("History", style: GoogleFonts.inter(color: Colors.white)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4D9CFF)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No saved chats", style: TextStyle(color: Colors.grey[600])),
            );
          }

          final history = snapshot.data!;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final chat = history[index];
              return Dismissible(
                key: Key(chat['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade900,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  _storage.deleteChat(chat['id']);
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(
                    chat['title'] ?? "Untitled",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    chat['preview'] ?? "...",
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Iconsax.arrow_right_3, color: Colors.grey, size: 16),
                  onTap: () {
                    // Load the chat and close history screen
                    ref.read(chatProvider.notifier).loadChat(chat['id']);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}