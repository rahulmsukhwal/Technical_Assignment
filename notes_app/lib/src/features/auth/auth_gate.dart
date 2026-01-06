import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../notes/notes_page.dart';
import 'auth_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return session.when(
      data: (value) => value == null ? const AuthPage() : const NotesPage(),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Something went wrong: $error')),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}


