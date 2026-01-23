import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class TypewriterMarkdown extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isStreaming;

  const TypewriterMarkdown({
    super.key,
    required this.text,
    this.style,
    this.isStreaming = false,
  });

  @override
  State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<TypewriterMarkdown> {
  String _displayedText = "";
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // If not streaming (old messages), show immediately
    if (!widget.isStreaming) {
      _displayedText = widget.text;
      _currentIndex = widget.text.length;
    } else {
      _startTyping();
    }
  }

  @override
  void didUpdateWidget(TypewriterMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _currentIndex++;
          _displayedText = widget.text.substring(0, _currentIndex);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use a custom builder to ensure the text style matches your theme
    return MarkdownBody(
      data: _displayedText,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.inter(
          fontSize: 16,
          height: 1.5,
          color: const Color(0xFFECECF1), // Off-white for AI
        ),
        code: GoogleFonts.firaCode(
          backgroundColor: const Color(0xFF2D2D2D),
          color: const Color(0xFFFF7B72),
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        codeblockPadding: const EdgeInsets.all(16),
      ),
    );
  }
}