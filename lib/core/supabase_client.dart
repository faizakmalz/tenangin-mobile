import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class SupabaseClientManager {
  static final SupabaseClientManager _instance = SupabaseClientManager._internal();
  factory SupabaseClientManager() => _instance;

  SupabaseClientManager._internal();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
        detectSessionInUri: true,
      ),
);
  }
}
