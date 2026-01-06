import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL');
  final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    runApp(const ProviderScope(child: MissingEnvApp()));
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  runApp(const ProviderScope(child: NotesApp()));
}

class MissingEnvApp extends StatelessWidget {
  const MissingEnvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Missing configuration')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Missing Supabase configuration. '
              'Add SUPABASE_URL and SUPABASE_ANON_KEY to a .env file '
              'at the project root (see .env.example).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
