import '../../../core/supabase_client.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = SupabaseClientManager.client.auth.currentUser?.id;

    if (uid == null) return null;

    final res = await SupabaseClientManager.client
        .from("profiles")
        .select("*")
        .eq("id", uid)
        .maybeSingle();

    return res;
  }

  static Future<void> updateProfile({
    required String anonName,
    String? bio,
  }) async {
    final uid = SupabaseClientManager.client.auth.currentUser!.id;

    await SupabaseClientManager.client.from("profiles").update({
      'anon_name': anonName,
      'bio': bio,
    }).eq("id", uid);
  }
}
