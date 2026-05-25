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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'language_code': languageCode,
        'updated_at': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Conversation',
      languageCode: json['language_code'] as String? ?? 'en',
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
              DateTime.now(),
      messages: ((json['messages'] as List?) ?? const [])
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
