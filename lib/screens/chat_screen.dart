import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import 'summary_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasNavigated = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final theme = Theme.of(context);

    // Navigate to summary when complete
    if (state.status == 'complete' && !_hasNavigated && state.sessionId != null) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SummaryScreen(sessionId: state.sessionId!),
          ),
        ).then((_) {
          // Reset when returning from summary
          _hasNavigated = false;
          ref.read(chatProvider.notifier).resetSession();
        });
      });
    }

    // Scroll on new messages
    if (state.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                state.businessConfig?.assistantName.substring(0, 1) ?? 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.businessConfig?.assistantName ?? 'Assistant',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  state.businessConfig?.businessName ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: state.messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount:
                        state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length && state.isLoading) {
                        return _buildTypingIndicator(theme);
                      }
                      return _buildMessageBubble(
                          state.messages[index], theme);
                    },
                  ),
          ),

          // Input bar
          _buildInputBar(state, theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'Start your onboarding',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.smart_toy_outlined,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !state.isLoading && state.status != 'complete',
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              onSubmitted: state.isLoading ? null : (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: state.status == 'complete'
                    ? 'Onboarding complete!'
                    : 'Type a message...',
                hintStyle: TextStyle(color: theme.colorScheme.outline),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: state.isLoading
                ? Container(
                    key: const ValueKey('loading'),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : IconButton(
                    key: const ValueKey('send'),
                    onPressed: state.status == 'complete' ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Animated three-dot typing indicator
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: -6).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    // Staggered start
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
