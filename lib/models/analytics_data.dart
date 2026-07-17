class DropoffStep {
  final int step;
  final int count;
  DropoffStep({required this.step, required this.count});
}

class RecentCompletion {
  final String name;
  final String? teamType;
  final String? useCase;
  final String createdAt;
  RecentCompletion({
    required this.name,
    this.teamType,
    this.useCase,
    required this.createdAt,
  });
}

class AnalyticsData {
  final int totalSessions;
  final int completedSessions;
  final int completionRate;
  final int activeToday;
  final double avgMessages;
  final List<DropoffStep> dropoffByStep;
  final List<RecentCompletion> recentCompletions;

  AnalyticsData({
    required this.totalSessions,
    required this.completedSessions,
    required this.completionRate,
    required this.activeToday,
    required this.avgMessages,
    required this.dropoffByStep,
    required this.recentCompletions,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      totalSessions: json['total_sessions'] as int? ?? 0,
      completedSessions: json['completed_sessions'] as int? ?? 0,
      completionRate: json['completion_rate'] as int? ?? 0,
      activeToday: json['active_today'] as int? ?? 0,
      avgMessages: (json['avg_messages'] as num?)?.toDouble() ?? 0.0,
      dropoffByStep: (json['dropoff_by_step'] as List<dynamic>? ?? [])
          .map((e) => DropoffStep(
                step: e['step'] as int,
                count: e['count'] as int,
              ))
          .toList(),
      recentCompletions:
          (json['recent_completions'] as List<dynamic>? ?? [])
              .map((e) => RecentCompletion(
                    name: e['name'] as String? ?? 'Unknown',
                    teamType: e['team_type'] as String?,
                    useCase: e['use_case'] as String?,
                    createdAt: e['created_at'] as String? ?? '',
                  ))
              .toList(),
    );
  }
}