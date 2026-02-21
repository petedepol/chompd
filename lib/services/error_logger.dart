import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight error logger that routes errors to the `app_events` table.
///
/// The outer catch ensures logging never crashes the app.
class ErrorLogger {
  ErrorLogger._();

  static Future<void> log({
    required String event,
    String? detail,
    String? stackTrace,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';

      await supabase.from('app_events').insert({
        'user_id': userId,
        'event_type': event,
        'metadata': {
          'detail': detail,
          'stack_trace': stackTrace != null
              ? (stackTrace.length > 500
                  ? stackTrace.substring(0, 500)
                  : stackTrace)
              : null,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });
    } catch (_) {
      // Don't let logging errors crash the app
    }
  }
}
