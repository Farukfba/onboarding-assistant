class BusinessConfig {
  final String businessId;
  final String businessName;
  final String assistantName;
  final String tone;
  final List<String> onboardingSteps;
  final String welcomeMessage;

  BusinessConfig({
    required this.businessId,
    required this.businessName,
    required this.assistantName,
    required this.tone,
    required this.onboardingSteps,
    required this.welcomeMessage,
  });

  factory BusinessConfig.fromJson(Map<String, dynamic> json) {
    return BusinessConfig(
      businessId: json['business_id'] as String? ?? json['id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      assistantName: json['assistant_name'] as String? ?? 'Assistant',
      tone: json['tone'] as String? ?? 'friendly',
      onboardingSteps: (json['onboarding_steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      welcomeMessage: json['welcome_message'] as String? ?? 'Welcome!',
    );
  }
}
