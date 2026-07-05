import 'package:flutter/material.dart';
import '../models/live_profile.dart';

class LiveProfileSheet extends StatelessWidget {
  final LiveProfile profile;
  final int filledSteps;
  final int totalSteps;

  const LiveProfileSheet({
    super.key,
    required this.profile,
    required this.filledSteps,
    required this.totalSteps,
  });

  static void show(BuildContext context, LiveProfile profile,
      int filledSteps, int totalSteps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LiveProfileSheet(
        profile: profile,
        filledSteps: filledSteps,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your profile so far',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${profile.filledCount} of $totalSteps fields collected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Profile fields
          _ProfileRow(
            icon: Icons.badge_outlined,
            label: 'Name',
            value: profile.name,
            theme: theme,
          ),
          _ProfileRow(
            icon: Icons.group_outlined,
            label: 'Team type',
            value: profile.teamType,
            theme: theme,
          ),
          _ProfileRow(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Use case',
            value: profile.useCase,
            theme: theme,
          ),
          _ProfileRow(
            icon: Icons.psychology_outlined,
            label: 'Pain point',
            value: profile.painPoint,
            theme: theme,
          ),

          const SizedBox(height: 20),

          // Completion hint
          if (profile.filledCount < totalSteps)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep answering to complete your profile',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D9E75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Color(0xFF1D9E75)),
                  const SizedBox(width: 8),
                  Text(
                    'Profile complete!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1D9E75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Close button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final ThemeData theme;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: hasValue
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                key: ValueKey(value),
                hasValue ? value! : '—',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasValue
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.outline,
                  fontStyle:
                      hasValue ? FontStyle.normal : FontStyle.italic,
                  fontWeight:
                      hasValue ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ),
          if (hasValue)
            Icon(
              Icons.check_circle,
              size: 14,
              color: const Color(0xFF1D9E75),
            ),
        ],
      ),
    );
  }
}
