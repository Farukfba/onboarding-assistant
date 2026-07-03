import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/business_config.dart';
import '../services/api_service.dart';
import '../constants.dart';

class ChatState {
  final String? sessionId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String status; // 'in_progress' | 'complete'
  final String? error;
  final BusinessConfig? businessConfig;

  const ChatState({
    this.sessionId,
    this.messages = const [],
    this.isLoading = false,
    this.status = 'in_progress',
    this.error,
    this.businessConfig,
  });

  ChatState copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? status,
    String? error,
    BusinessConfig? businessConfig,
    bool clearError = false,
    bool clearSessionId = false,
  }) {
    return ChatState(
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      businessConfig: businessConfig ?? this.businessConfig,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _api;

  ChatNotifier(this._api) : super(const ChatState());

  Future<void> loadBusinessConfig() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final config = await _api.fetchBusinessConfig(kBusinessId);
      state = state.copyWith(
        businessConfig: config,
        isLoading: false,
        // Show welcome message as first assistant message
        messages: [
          ChatMessage(
            role: MessageRole.assistant,
            content: config.welcomeMessage,
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (state.isLoading) return;

    // Clear any previous error and add user message immediately
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: MessageRole.user, content: content.trim()),
      ],
      isLoading: true,
      clearError: true,
    );

    try {
      final result = await _api.sendMessage(
        businessId: kBusinessId,
        sessionId: state.sessionId,
        message: content.trim(),
      );

      state = state.copyWith(
        sessionId: result.sessionId,
        messages: [
          ...state.messages,
          ChatMessage(role: MessageRole.assistant, content: result.reply),
        ],
        isLoading: false,
        status: result.status,
      );
    } catch (e) {
      // Add error as a system message in the chat rather than crashing
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: MessageRole.assistant,
            content: '⚠️ Something went wrong: ${e.toString()}. Please try again.',
          ),
        ],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void resetSession() {
    final config = state.businessConfig;
    state = ChatState(
      businessConfig: config,
      messages: config != null
          ? [
              ChatMessage(
                role: MessageRole.assistant,
                content: config.welcomeMessage,
              ),
            ]
          : [],
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ApiService());
});
