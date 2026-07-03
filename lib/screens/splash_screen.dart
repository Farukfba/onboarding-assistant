import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Load business config on splash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfig();
    });
  }

  Future<void> _loadConfig() async {
    await ref.read(chatProvider.notifier).loadBusinessConfig();
    if (!mounted) return;

    final state = ref.read(chatProvider);
    if (state.error != null) {
      // Show error on splash — config failed
      return;
    }

    // Navigate to chat
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ChatScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                state.businessConfig?.assistantName ?? 'Onboarding',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Getting things ready...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 48),
              if (state.error != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Could not connect',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loadConfig,
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
