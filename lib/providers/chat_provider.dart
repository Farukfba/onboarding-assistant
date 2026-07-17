import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/business_config.dart';
import '../models/live_profile.dart';
import '../services/api_service.dart';
import '../services/profile_parser.dart';
import '../constants.dart';

class ChatState {
  final String? sessionId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String status;
  final String? error;
  final BusinessConfig? businessConfig;
  final int currentStep;
  final int totalSteps;
  final LiveProfile liveProfile;

  const ChatState({
    this.sessionId,
    this.messages = const [],
    this.isLoading = false,
    this.status = 'in_progress',
    this.error,
    this.businessConfig,
    this.currentStep = 0,
    this.totalSteps = 0,
    this.liveProfile = const LiveProfile(),
  });

  double get progress => totalSteps == 0
      ? 0.0
      : (currentStep / totalSteps).clamp(0.0, 1.0);

  ChatState copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? status,
    String? error,
    BusinessConfig? businessConfig,
    int? currentStep,
    int? totalSteps,
    LiveProfile? liveProfile,
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
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      liveProfile: liveProfile ?? this.liveProfile,
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
        totalSteps: config.onboardingSteps.length,
        currentStep: 0,
        messages: [
          ChatMessage(
            role: MessageRole.assistant,
            content: config.welcomeMessage,
            quickReplies: const ["Let's go! 👋"],
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> checkForExistingSession() async {
  try {
    return await _api.fetchLatestSession(kBusinessId);
  } catch (e) {
    return null;
  }
}

Future<void> resumeSession(String sessionId, BusinessConfig config) async {
  state = state.copyWith(isLoading: true, clearError: true);
  try {
    final messages = await _api.fetchSessionMessages(sessionId);
    final live = ProfileParser.parse(messages);
    state = state.copyWith(
      sessionId: sessionId,
      businessConfig: config,
      totalSteps: config.onboardingSteps.length,
      currentStep: (messages.where((m) => m.isUser).length)
          .clamp(0, config.onboardingSteps.length - 1),
      messages: messages,
      isLoading: false,
      status: 'in_progress',
      liveProfile: live,
    );
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (state.isLoading) return;

    final updatedMessages = state.messages.map((m) {
      if (m.isAssistant && m == state.messages.last) {
        return ChatMessage(
          role: m.role,
          content: m.content,
          timestamp: m.timestamp,
          quickReplies: const [],
        );
      }
      return m;
    }).toList();

    final messagesWithUser = [
      ...updatedMessages,
      ChatMessage(role: MessageRole.user, content: content.trim()),
    ];

    state = state.copyWith(
      messages: messagesWithUser,
      isLoading: true,
      clearError: true,
    );

    try {
      final result = await _api.sendMessage(
  businessId: kBusinessId,
  sessionId: state.sessionId,
  message: content.trim(),
  email: 'farukbaliyu23@gmail.com',
);

      final newStep =
          (state.currentStep + 1).clamp(0, state.totalSteps - 1);
      final chips = _detectQuickReplies(result.reply);

      final finalMessages = [
        ...messagesWithUser,
        ChatMessage(
          role: MessageRole.assistant,
          content: result.reply,
          quickReplies: chips,
        ),
      ];

      // Parse live profile from conversation so far
      final live = ProfileParser.parse(finalMessages);

      state = state.copyWith(
        sessionId: result.sessionId,
        messages: finalMessages,
        isLoading: false,
        status: result.status,
        currentStep:
            result.status == 'complete' ? state.totalSteps : newStep,
        liveProfile: live,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: MessageRole.assistant,
            content:
                '⚠️ Something went wrong: ${e.toString()}. Please try again.',
            quickReplies: const ['Try again'],
          ),
        ],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  List<String> _detectQuickReplies(String reply) {
    final lower = reply.toLowerCase();
    if (lower.contains('solo') ||
        lower.contains('team') ||
        lower.contains('working alone') ||
        lower.contains('how many')) {
      return ['Solo 👤', 'Small team (2–5)', 'Larger team (6+)'];
    }
    if (lower.contains('do you') ||
        lower.contains('are you') ||
        lower.contains('have you') ||
        lower.contains('would you')) {
      return ['Yes', 'No', 'Not sure'];
    }
    if (lower.contains('experience') ||
        lower.contains('familiar') ||
        lower.contains('background')) {
      return ['Beginner', 'Intermediate', 'Advanced'];
    }
    if (lower.contains('goal') ||
        lower.contains('hoping') ||
        lower.contains('use it for') ||
        lower.contains('use the product')) {
      return ['Automate tasks', 'Manage clients', 'Grow my business', 'Other'];
    }
    if (lower.contains('pain') ||
        lower.contains('challenge') ||
        lower.contains('struggle') ||
        lower.contains('biggest')) {
      return [
        'Too much manual work',
        'Disorganised data',
        'Team coordination',
        'Other'
      ];
    }
    return [];
  }

  void resetSession() {
    final config = state.businessConfig;
    state = ChatState(
      businessConfig: config,
      totalSteps: config?.onboardingSteps.length ?? 0,
      currentStep: 0,
      liveProfile: const LiveProfile(),
      messages: config != null
          ? [
              ChatMessage(
                role: MessageRole.assistant,
                content: config.welcomeMessage,
                quickReplies: const ["Let's go! 👋"],
              ),
            ]
          : [],
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ApiService());
});
