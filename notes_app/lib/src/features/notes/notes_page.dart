import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/glass_widget.dart';
import '../auth/auth_controller.dart';
import 'note.dart';
import 'note_editor_page.dart';
import 'notes_controller.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get or create controller - ensure it's a singleton
    final notesController = Get.put(NotesController(), permanent: true);
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade300,
              Colors.indigo.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Notes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await authController.signOut();
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Sign out',
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  width: double.infinity,
                  height: 56,
                  borderRadius: 16,
                  blur: 20,
                  border: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      notesController.searchQuery.value = value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notes List
              Expanded(
                child: Obx(() {
                  // Watch notes list directly to ensure reactive updates
                  final notesList = notesController.notes;
                  final filteredNotes = notesController.filteredNotes;
                  final isLoading = notesController.isLoading.value;
                  final error = notesController.error.value;
                  final hasNotes = notesController.hasNotes;
                  final hasSearchQuery = notesController.hasSearchQuery;

                  if (isLoading && !hasNotes) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  if (error != null && !hasNotes) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Show appropriate message based on search state
                  if (filteredNotes.isEmpty) {
                    String message;
                    if (hasSearchQuery) {
                      message = 'No notes match your search.\nTry a different keyword.';
                    } else {
                      message = 'No notes yet.\nTap + to create one.';
                    }
                    
                    return Center(
                      child: GlassContainer(
                        width: 300,
                        height: 150,
                        borderRadius: 20,
                        blur: 20,
                        border: 1,
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => notesController.refreshNotes(),
                    color: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return _NoteCard(note: note);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to<bool>(
            () => const NoteEditorPage(),
          );
          // No need to manually refresh - Firestore stream updates automatically
        },
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),

      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final notesController = Get.find<NotesController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        width: double.infinity,
        borderRadius: 16,
        blur: 20,
        border: 1,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            note.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              note.content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () async {
                  await Get.to<bool>(
                    () => NoteEditorPage(note: note),
                  );
                },
                tooltip: 'Edit note',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () async {
                  final confirmed = await Get.dialog<bool>(
                    AlertDialog(
                      backgroundColor: Colors.grey.shade900,
                      title: const Text(
                        'Delete Note',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this note?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final error = await notesController.deleteNote(note.id);
                    if (error != null) {
                      Get.snackbar(
                        'Error',
                        error,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    }
                  }
                },
                tooltip: 'Delete note',
              ),
            ],
          ),
          onTap: () async {
            await Get.to<bool>(
              () => NoteEditorPage(note: note),
            );
          },
        ),
      ),
    );
  }
}
