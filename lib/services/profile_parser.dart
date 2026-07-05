import '../models/chat_message.dart';
import '../models/live_profile.dart';

/// Parses the conversation history locally on the Flutter side
/// to build a live profile as the user answers questions.
/// This runs client-side — no API call needed.
class ProfileParser {
  static LiveProfile parse(List<ChatMessage> messages) {
    String? name;
    String? teamType;
    String? useCase;
    String? painPoint;

    // Walk through assistant→user pairs to extract answers
    for (int i = 0; i < messages.length - 1; i++) {
      final assistant = messages[i];
      final user = i + 1 < messages.length ? messages[i + 1] : null;

      if (assistant.isUser || user == null || user.isAssistant) continue;

      final question = assistant.content.toLowerCase();
      final answer = user.content.trim();

      // Name — question asks for name
      if ((question.contains("your name") || question.contains("what's your name") ||
        question.contains("what is your name") ||
        question.contains("full name") || question.contains("your full name")) &&
    name == null) {
        // Extract just the name — take first 1-3 words of the answer
        final words = answer.split(' ').take(3).join(' ');
        name = _capitalise(words);
      }

      // Team type — question about solo/team
      if (question.contains("solo") || question.contains("team") ||
    question.contains("how many") || question.contains("working alone") ||
    question.contains("individual") || question.contains("business owner") ||
    question.contains("onboarding as")) {
        final lower = answer.toLowerCase();
        if (lower.contains("solo") || lower.contains("alone") ||
    lower.contains("just me") || lower.contains("myself") ||
    lower.contains("individual")) {
  teamType = 'Individual';
        } else if (lower.contains("team") || lower.contains("2") ||
            lower.contains("3") || lower.contains("4") || lower.contains("5") ||
            lower.contains("small") || lower.contains("group") ||
            lower.contains("larger") || lower.contains("6")) {
          teamType = _formatTeamAnswer(answer);
        }
      }

      // Use case — question about what they want to use the product for
      if ((question.contains("use") && question.contains("product")) ||
    question.contains("use palmpay for") ||
    question.contains("primarily want") ||
          question.contains("hoping to") || question.contains("want to") ||
          question.contains("use it for") || question.contains("goal") ||
          question.contains("achieve")) {
        if (useCase == null && answer.length > 2) {
          useCase = _truncate(answer, 40);
        }
      }

      // Pain point — question about challenges/problems
      if (question.contains("pain") || question.contains("challenge") ||
          question.contains("struggle") || question.contains("difficult") ||
          question.contains("biggest") || question.contains("problem")) {
        if (painPoint == null && answer.length > 2) {
          painPoint = _truncate(answer, 40);
        }
      }
    }

    return LiveProfile(
      name: name,
      teamType: teamType,
      useCase: useCase,
      painPoint: painPoint,
    );
  }

  static String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  static String _formatTeamAnswer(String answer) {
  final lower = answer.toLowerCase();
  if (lower.contains("solo") || lower.contains("just me") ||
      lower.contains("individual") || lower.contains("personal")) {
    return 'Individual';
  }
  if (lower.contains("business") || lower.contains("owner") ||
      lower.contains("freelance") || lower.contains("company")) {
    return 'Business owner';
  }
  if (lower.contains("small") || lower.contains("2") || lower.contains("5")) {
    return 'Small team';
  }
  if (lower.contains("larger") || lower.contains("6") || lower.contains("big")) {
    return 'Larger team';
  }
  return _truncate(answer, 20);
}

  static String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…';
  }
}
