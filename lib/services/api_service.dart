import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/business_config.dart';
import '../models/chat_message.dart';
import '../models/onboarding_profile.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SendMessageResult {
  final String sessionId;
  final String reply;
  final String status;

  SendMessageResult({
    required this.sessionId,
    required this.reply,
    required this.status,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Api-Key': kApiKey,
      };

  Future<BusinessConfig> fetchBusinessConfig(String businessId) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/business/$businessId');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BusinessConfig.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException('Business not found. Check your kBusinessId constant.',
            statusCode: 404);
      } else {
        throw ApiException('Failed to load business config (${response.statusCode})',
            statusCode: response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: Could not reach the server. Check kBackendUrl.');
    }
  }

  Future<SendMessageResult> sendMessage({
    required String businessId,
    required String? sessionId,
    required String message,
  }) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/chat');
      final body = jsonEncode({
        'business_id': businessId,
        'session_id': sessionId,
        'message': message,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SendMessageResult(
          sessionId: json['session_id'] as String,
          reply: json['reply'] as String,
          status: json['status'] as String,
        );
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          json['error'] as String? ?? 'Failed to send message',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: Could not reach the server.');
    }
  }

  Future<OnboardingProfile> fetchProfile(String sessionId) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/profile/$sessionId');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return OnboardingProfile.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException('Profile not found for this session.', statusCode: 404);
      } else {
        throw ApiException('Failed to load profile (${response.statusCode})',
            statusCode: response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: Could not reach the server.');
    }
  }
}
