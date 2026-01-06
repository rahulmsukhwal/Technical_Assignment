import 'package:supabase_flutter/supabase_flutter.dart';

import 'note.dart';

class NotesRepository {
  NotesRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'notes';

  Future<List<Note>> fetchNotes(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => Note.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<Note> createNote({
    required String title,
    required String content,
    required String userId,
  }) async {
    final response = await _client.from(_table).insert({
      'title': title,
      'content': content,
      'user_id': userId,
    }).select();

    return Note.fromMap((response as List).first as Map<String, dynamic>);
  }

  Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final response = await _client
        .from(_table)
        .update({
          'title': title,
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select();

    return Note.fromMap((response as List).first as Map<String, dynamic>);
  }

  Future<void> deleteNote(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}


