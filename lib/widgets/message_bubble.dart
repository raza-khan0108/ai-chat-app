import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';
import 'typewriter_markdown.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isLatest; // New parameter to know if we should animate

  const MessageBubble({
    super.key,
    required this.message,
    this.isLatest = false
  });

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // AI Avatar
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF4D9CFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
          ],

          // Message Content
          Flexible(
            child: Container(
              padding: isUser
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : EdgeInsets.zero,
              decoration: isUser
                  ? BoxDecoration(
                color: const Color(0xFF4D9CFF),
                borderRadius: BorderRadius.circular(20),
              )
                  : null,
              child: isUser
              // User Message (Standard Text)
                  ? Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white,
                ),
              )
              // AI Message (Typewriter Markdown)
                  : TypewriterMarkdown(
                text: message.content,
                isStreaming: isLatest, // Only animate if it's the newest message
              ),
            ),
          ),
        ],
      ),
    );
  }
}