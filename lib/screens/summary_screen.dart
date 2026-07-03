import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/onboarding_profile.dart';

class SummaryScreen extends StatefulWidget {
  final String sessionId;

  const SummaryScreen({super.key, required this.sessionId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  OnboardingProfile? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService().fetchProfile(widget.sessionId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
        });
        _controller.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Onboarding Complete',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(theme)
              : _buildSummary(theme),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not load your profile',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final profile = _profile!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Success icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D9E75).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 52,
                  color: Color(0xFF1D9E75),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "You're all set!",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's a summary of your onboarding",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),

            const SizedBox(height: 32),

            // Profile card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileRow(
                    theme,
                    icon: Icons.person_outline_rounded,
                    label: 'Name',
                    value: profile.name,
                    isFirst: true,
                  ),
                  _buildDivider(theme),
                  _buildProfileRow(
                    theme,
                    icon: Icons.group_outlined,
                    label: 'Team type',
                    value: profile.teamType != null
                        ? _formatTeamType(profile.teamType!)
                        : null,
                  ),
                  _buildDivider(theme),
                  _buildProfileRow(
                    theme,
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Use case',
                    value: profile.useCase,
                  ),
                  _buildDivider(theme),
                  _buildProfileRow(
                    theme,
                    icon: Icons.psychology_outlined,
                    label: 'Pain point',
                    value: profile.painPoint,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Start over button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Start Over'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String? value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value! : 'Not provided',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasValue
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline,
                    fontStyle:
                        hasValue ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: theme.colorScheme.outline.withOpacity(0.15),
    );
  }

  String _formatTeamType(String teamType) {
    switch (teamType) {
      case 'solo':
        return 'Solo founder';
      case 'team':
        return 'Team';
      default:
        return teamType;
    }
  }
}
