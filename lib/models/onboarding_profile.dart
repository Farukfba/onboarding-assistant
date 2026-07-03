class OnboardingProfile {
  final String? name;
  final String? teamType;
  final String? useCase;
  final String? painPoint;

  OnboardingProfile({
    this.name,
    this.teamType,
    this.useCase,
    this.painPoint,
  });

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    final data = json['extracted_data'] as Map<String, dynamic>? ?? {};
    return OnboardingProfile(
      name: data['name'] as String?,
      teamType: data['team_type'] as String?,
      useCase: data['use_case'] as String?,
      painPoint: data['pain_point'] as String?,
    );
  }
}
