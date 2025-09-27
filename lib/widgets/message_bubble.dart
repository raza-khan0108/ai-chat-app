import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF10A37F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Clarity.AI',
                      style: TextStyle(
                        color: Color(0xFF10A37F),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF2D2D30) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isUser ? null : Border.all(
                      color: const Color(0xFF2D2D30),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.content.isEmpty && isStreaming)
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: const Color(0xFF10A37F),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Thinking...',
                              style: TextStyle(
                                color: Color(0xFF6C7293),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      else if (isUser)
                        Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        )
                      else
                      // ENSURE MARKDOWN RENDERING FOR ASSISTANT
                        MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            em: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFE0E0E0),
                            ),
                            h1: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            h2: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            h3: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            listBullet: const TextStyle(
                              color: Color(0xFF10A37F),
                              fontSize: 16,
                              height: 1.4,
                            ),
                            code: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              color: const Color(0xFF10A37F),
                              backgroundColor: const Color(0xFF2D2D30),
                            ),
                            codeblockDecoration: const BoxDecoration(
                              color: Color(0xFF2D2D30),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            blockquote: const TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontStyle: FontStyle.italic,
                            ),
                            tableHead: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            tableBody: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (isStreaming && message.content.isNotEmpty && !isUser)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF10A37F),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF6C7293),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
