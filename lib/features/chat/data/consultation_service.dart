import 'package:flutter/foundation.dart';
import 'package:tenangin_mobile/core/supabase_client.dart';

class ConsultationService {

  String? get uid => SupabaseClientManager.client.auth.currentUser?.id;

  Future<void> initSessionStart(String threadId) async {
    debugPrint('>>> current uid: $uid');

    if (uid == null) {
      debugPrint('>>> ERROR: user not logged in!');
      throw Exception("User not logged in");
    }

    final payload = {
      'thread_id': threadId,
      'user_id': uid,
      'status': 'waiting',
      'started_at': DateTime.now().toIso8601String(),
    };

    debugPrint('>>> inserting consultation_sessions payload: $payload');

    try {
      final res = await SupabaseClientManager.client
          .from('consultation_sessions')
          .insert(payload)
          .select()
          .single();

      debugPrint('>>> insert response: $res');
    } catch (err, st) {
      debugPrint('>>> insert error: $err\n$st');
      rethrow;
    }
  }

  Future<void> setSessionActive(String threadId) async {
    if (uid == null) throw Exception("User not logged in");

    await SupabaseClientManager.client
        .from('consultation_sessions')
        .upsert({
          "thread_id": threadId,
          "user_id": uid,
          "status": "active",
        });
  }

  Future<void> endSession(String threadId) async {
    if (uid == null) throw Exception("User not logged in");

    await SupabaseClientManager.client
        .from('consultation_sessions')
        .update({
          "status": "ended",
          "ended_at": DateTime.now().toIso8601String(),
        }).eq("thread_id", threadId);
  }
}
