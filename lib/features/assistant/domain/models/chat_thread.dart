import 'package:flutter/foundation.dart';

import 'chat_message.dart';

@immutable
class ChatThread {
  const ChatThread({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.languageCode = 'en',
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime updatedAt;
  final String languageCode;

  ChatThread copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
    String? languageCode,
  }) {
    return ChatThread(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
