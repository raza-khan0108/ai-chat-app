import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/message.dart';

class ChatService {
  // Update this IP to match your backend
  static const String baseUrl = 'https://clarity-backend-02a2.onrender.com';
  final Dio _dio = Dio();

  Stream<String> sendMessage(List<Message> conversationHistory) async* {
    Response<ResponseBody> resp;
    try {
      resp = await _dio.post<ResponseBody>(
        '$baseUrl/chat',
        data: {
          'messages': conversationHistory.map((m) => m.toJson()).toList(),
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
          },
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(minutes: 120),
        ),
      );
    } on DioException catch (e) {
      final msg = e.message ?? 'Network error';
      yield 'Connection Error: $msg';
      return;
    } catch (e) {
      yield 'Unexpected Error: $e';
      return;
    }

    if (resp.statusCode != 200) {
      yield 'HTTP ${resp.statusCode}: ${resp.statusMessage ?? 'Request failed'}';
      return;
    }

    final body = resp.data;
    if (body == null) {
      yield 'Error: Empty response stream';
      return;
    }

    final stream = body.stream as Stream<Uint8List>;
    final buffer = StringBuffer();

    try {
      await for (final bytes in stream) {
        // Decode bytes to UTF-8
        final decoded = utf8.decode(bytes, allowMalformed: true);
        buffer.write(decoded);

        // Process complete lines
        final text = buffer.toString();
        // Split by newlines to handle multiple data chunks in one packet
        final lines = text.split('\n');

        // Keep the incomplete last line in the buffer
        buffer.clear();
        buffer.write(lines.removeLast());

        for (final raw in lines) {
          final line = raw.trim();
          if (line.isEmpty) continue;

          // Handle SSE format
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim(); // Remove "data: "

            if (data == '[DONE]') return;

            try {
              // --- CRITICAL FIX START ---
              // 1. Parse the string as JSON
              final jsonMap = jsonDecode(data);

              // 2. Extract the actual content from the OpenRouter structure
              // Structure is usually: choices[0]['delta']['content']
              if (jsonMap['choices'] != null &&
                  (jsonMap['choices'] as List).isNotEmpty) {

                final delta = jsonMap['choices'][0]['delta'];
                if (delta != null && delta['content'] != null) {
                  final content = delta['content'] as String;

                  // 3. Yield the actual text content
                  if (content.isNotEmpty) {
                    yield content;
                  }
                }
              }
              // --- CRITICAL FIX END ---

            } catch (e) {
              // If it's not JSON (like an error message), yield it directly
              // or ignore parsing errors for keep-alive packets
              print("Error parsing chunk: $e");
            }
          }
        }
      }
    } catch (e) {
      yield 'Stream Error: $e';
    }
  }
}