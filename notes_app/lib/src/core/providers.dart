import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final sessionProvider = StreamProvider<Session?>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  yield client.auth.currentSession;
  yield* client.auth.onAuthStateChange.map((event) => event.session);
});

final userIdProvider = Provider<String?>((ref) {
  final session = ref.watch(sessionProvider).valueOrNull;
  return session?.user.id;
});
