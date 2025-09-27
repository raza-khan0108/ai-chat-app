import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/message.dart';

class ChatService {
  static const String baseUrl = 'http://192.168.0.213:8000'; // Update with your PC IP
  final Dio _dio = Dio();

  String _normalizeChunk(String chunk) {
    // Clean and normalize each chunk
    return chunk
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces to single
        .trim();
  }

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
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(minutes: 2),
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
        final decoded = utf8.decode(bytes, allowMalformed: true);
        buffer.write(decoded);

        final text = buffer.toString();
        final lines = text.split('\n');
        buffer
          ..clear()
          ..write(lines.removeLast());

        for (final raw in lines) {
          final line = raw.trimRight();
          if (line.isEmpty) continue;

          if (line.startsWith('event:')) {
            continue;
          }

          if (line.startsWith('data:')) {
            final data = line.substring(5).trimLeft();

            if (data == '[DONE]') return;

            if (data.startsWith('Error:') ||
                data.startsWith('Exception') ||
                data.startsWith('HTTP')) {
              yield 'Error: $data';
              continue;
            }

            if (data.isNotEmpty) {
              final normalized = _normalizeChunk(data);
              if (normalized.isNotEmpty) {
                yield normalized;
              }
            }
          }
        }
      }

      final last = buffer.toString().trimRight();
      if (last.startsWith('data:')) {
        final data = last.substring(5).trimLeft();
        if (data.isNotEmpty && data != '[DONE]') {
          final normalized = _normalizeChunk(data);
          if (normalized.isNotEmpty) {
            yield normalized;
          }
        }
      }
    } catch (e) {
      yield 'Stream Error: $e';
    }
  }
}
