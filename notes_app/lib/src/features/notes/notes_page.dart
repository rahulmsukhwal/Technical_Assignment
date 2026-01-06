import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'note.dart';
import 'note_editor_page.dart';
import 'notes_controller.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final query = ref.watch(notesSearchQueryProvider);

    List<Note> filteredNotes = notesState.valueOrNull ?? [];
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      filteredNotes = filteredNotes
          .where((note) => note.title.toLowerCase().contains(lower))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your notes'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider).signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notesProvider.notifier).refreshNotes(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by title',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    ref.read(notesSearchQueryProvider.notifier).state = value,
              ),
            ),
            Expanded(
              child: notesState.when(
                data: (_) {
                  if (filteredNotes.isEmpty) {
                    return const Center(
                      child: Text('No notes yet. Tap + to create one.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return _NoteCard(note: note);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: filteredNotes.length,
                  );
                },
                error: (error, _) =>
                    Center(child: Text('Failed to load notes: $error')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NoteEditorPage()),
          );
          if (created == true && context.mounted) {
            await ref.read(notesProvider.notifier).refreshNotes();
          }
        },
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onTap: () async {
          final updated = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
          );

          if (updated == true && context.mounted) {
            await ref.read(notesProvider.notifier).refreshNotes();
          }
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final error = await ref
                .read(notesProvider.notifier)
                .deleteNote(note.id);
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error)));
            }
          },
        ),
      ),
    );
  }
}
