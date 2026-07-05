enum MessageRole { user, assistant }

class ChatMessage {
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<String> quickReplies; // answer chips shown below this message

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.quickReplies = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}
