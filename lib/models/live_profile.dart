/// Partial profile built in real-time from the conversation
/// before the final Claude extraction call runs.
class LiveProfile {
  final String? name;
  final String? teamType;
  final String? useCase;
  final String? painPoint;

  const LiveProfile({
    this.name,
    this.teamType,
    this.useCase,
    this.painPoint,
  });

  bool get isEmpty =>
      name == null && teamType == null && useCase == null && painPoint == null;

  int get filledCount => [name, teamType, useCase, painPoint]
      .where((v) => v != null)
      .length;

  LiveProfile copyWith({
    String? name,
    String? teamType,
    String? useCase,
    String? painPoint,
  }) {
    return LiveProfile(
      name: name ?? this.name,
      teamType: teamType ?? this.teamType,
      useCase: useCase ?? this.useCase,
      painPoint: painPoint ?? this.painPoint,
    );
  }
}
