import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// One Server-Sent Event. `name` is the value of the `event:` line, or
/// `'message'` per the SSE spec when absent. `data` is the decoded JSON
/// object on the `data:` line (we always send objects; raw strings are
/// surfaced under the `_raw` key).
class SseEvent {
  const SseEvent({required this.name, required this.data});

  final String name;
  final Map<String, dynamic> data;

  @override
  String toString() => 'SseEvent($name, $data)';
}

/// Opens a streamed POST to [url] with [body] and yields parsed SSE events
/// until the server closes the stream. Supports the subset of the SSE
/// protocol the backend actually uses: `event:`, `data:`, blank-line
/// frame separator. Comments (`:` prefix) and `id:` / `retry:` are
/// tolerated but ignored.
Stream<SseEvent> openSseStream({
  required Dio dio,
  required String path,
  required Map<String, dynamic> body,
  Map<String, dynamic> headers = const {},
  Duration timeout = const Duration(seconds: 90),
}) async* {
  final response = await dio.post<ResponseBody>(
    path,
    data: body,
    options: Options(
      responseType: ResponseType.stream,
      receiveTimeout: timeout,
      headers: {
        'Accept': 'text/event-stream',
        ...headers,
      },
    ),
  );

  final stream = response.data;
  if (stream == null) {
    throw StateError('SSE response had no body');
  }

  String pendingEvent = 'message';
  final dataBuffer = StringBuffer();
  String carry = '';

  await for (final bytes in stream.stream) {
    carry += utf8.decode(bytes, allowMalformed: true);
    while (true) {
      final newlineIdx = carry.indexOf('\n');
      if (newlineIdx == -1) break;

      var line = carry.substring(0, newlineIdx);
      carry = carry.substring(newlineIdx + 1);
      if (line.endsWith('\r')) {
        line = line.substring(0, line.length - 1);
      }

      if (line.isEmpty) {
        // Dispatch frame.
        if (dataBuffer.isNotEmpty) {
          yield _decode(pendingEvent, dataBuffer.toString());
        }
        pendingEvent = 'message';
        dataBuffer.clear();
        continue;
      }

      if (line.startsWith(':')) continue; // comment

      final colon = line.indexOf(':');
      final field = colon == -1 ? line : line.substring(0, colon);
      var value = colon == -1 ? '' : line.substring(colon + 1);
      if (value.startsWith(' ')) value = value.substring(1);

      switch (field) {
        case 'event':
          pendingEvent = value;
          break;
        case 'data':
          if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
          dataBuffer.write(value);
          break;
        // id: / retry: ignored.
      }
    }
  }

  // Flush any unterminated trailing frame.
  if (dataBuffer.isNotEmpty) {
    yield _decode(pendingEvent, dataBuffer.toString());
  }
}

SseEvent _decode(String name, String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return SseEvent(name: name, data: decoded);
    }
    return SseEvent(name: name, data: {'_raw': decoded});
  } on FormatException {
    return SseEvent(name: name, data: {'_raw': raw});
  }
}
