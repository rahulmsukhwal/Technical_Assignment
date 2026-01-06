import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'note.dart';
import 'notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return NotesRepository(client);
});

final notesSearchQueryProvider = StateProvider<String>((_) => '');

final notesProvider =
    AutoDisposeAsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AutoDisposeAsyncNotifier<List<Note>> {
  NotesNotifier();

  NotesRepository get _repository => ref.read(notesRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    final session = await ref.watch(sessionProvider.future);
    final userId = session?.user.id;
    if (userId == null) return [];
    return _repository.fetchNotes(userId);
  }

  Future<void> refreshNotes() async {
    final session = await ref.watch(sessionProvider.future);
    final userId = session?.user.id;
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchNotes(userId));
  }

  Future<String?> addNote(String title, String content) async {
    final session = await ref.watch(sessionProvider.future);
    final userId = session?.user.id;
    if (userId == null) return 'No active user session';

    try {
      final newNote = await _repository.createNote(
        title: title,
        content: content,
        userId: userId,
      );
      final current = state.value ?? [];
      state = AsyncData([newNote, ...current]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateNote(String id, String title, String content) async {
    try {
      final updated = await _repository.updateNote(
        id: id,
        title: title,
        content: content,
      );
      final current = state.value ?? [];
      state = AsyncData(
        current
            .map((note) => note.id == id ? updated : note)
            .toList(growable: false),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      final current = state.value ?? [];
      state = AsyncData(
        current.where((note) => note.id != id).toList(growable: false),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}


