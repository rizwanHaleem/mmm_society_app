import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/member_profile.dart';

class MemberService {
  MemberService._();

  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<List<MemberProfile>> getMembers() async {
    final response = await _supabase
        .from('profiles')
        .select(
          'id, username, full_name, phone, email, role, '
          'is_active, first_login, created_at',
        )
        .order('full_name');

    return (response as List<dynamic>)
        .map(
          (item) => MemberProfile.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  static Future<MemberProfile> getMember(String memberId) async {
    final response = await _supabase
        .from('profiles')
        .select(
          'id, username, full_name, phone, email, role, '
          'is_active, first_login, created_at',
        )
        .eq('id', memberId)
        .single();

    return MemberProfile.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  static Future<void> createMember({
    required String fullName,
    required String username,
    required String temporaryPassword,
    required String role,
  }) async {
    await _invokeFunction(
      functionName: 'create-member',
      body: {
        'fullName': fullName.trim(),
        'username': username.trim().toLowerCase(),
        'temporaryPassword': temporaryPassword,
        'role': role,
      },
    );
  }

  static Future<void> updateMember({
    required String memberId,
    required String fullName,
    required String username,
    required String role,
  }) async {
    await _invokeFunction(
      functionName: 'manage-member',
      body: {
        'action': 'update_profile',
        'memberId': memberId,
        'fullName': fullName.trim(),
        'username': username.trim().toLowerCase(),
        'role': role,
      },
    );
  }

  static Future<void> setMemberActive({
    required String memberId,
    required bool isActive,
  }) async {
    await _invokeFunction(
      functionName: 'manage-member',
      body: {
        'action': 'set_active',
        'memberId': memberId,
        'isActive': isActive,
      },
    );
  }

  static Future<void> resetMemberPassword({
    required String memberId,
    required String temporaryPassword,
  }) async {
    await _invokeFunction(
      functionName: 'manage-member',
      body: {
        'action': 'reset_password',
        'memberId': memberId,
        'temporaryPassword': temporaryPassword,
      },
    );
  }

  static Future<void> _invokeFunction({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception(
        'Your login session has expired. Please sign in again.',
      );
    }

    final response = await _supabase.functions.invoke(
      functionName,
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: body,
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception(
        'The server returned an unexpected response.',
      );
    }

    final responseData = Map<String, dynamic>.from(data);

    if (responseData['success'] != true) {
      throw Exception(
        responseData['message']?.toString() ??
            'The requested operation could not be completed.',
      );
    }
  }
}