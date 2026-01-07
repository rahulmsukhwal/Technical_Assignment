import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../auth/auth_controller.dart';
import 'note.dart';
import 'notes_repository.dart';

class NotesController extends GetxController {
  final NotesRepository _repository = NotesRepository(FirebaseFirestore.instance);
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Note> notes = <Note>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> error = Rx<String?>(null);
  
  StreamSubscription<List<Note>>? _notesSubscription;

  @override
  void onInit() {
    super.onInit();
    // Load notes immediately if user is authenticated
    if (_authController.currentUserId != null) {
      loadNotes();
    } else {
      // Wait for auth state to be ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_authController.currentUserId != null) {
          loadNotes();
        }
      });
    }
  }

  @override
  void onClose() {
    _notesSubscription?.cancel();
    super.onClose();
  }

  void loadNotes() {
    final userId = _authController.currentUserId;
    if (userId == null) {
      notes.clear();
      return;
    }

    // Cancel existing subscription if any
    _notesSubscription?.cancel();

    // Set up new stream subscription with proper error handling
    _notesSubscription = _repository.fetchNotesStream(userId).listen(
      (notesList) {
        // Update the reactive list - assignAll triggers UI rebuild
        notes.assignAll(notesList);
        error.value = null;
        print('✅ Notes updated: ${notesList.length} notes');
      },
      onError: (e) {
        error.value = 'Failed to load notes: $e';
        print('❌ Notes stream error: $e');
      },
      cancelOnError: false, // Keep listening even on error
    );
    
    print('🔵 Stream subscription started for user: $userId');
  }
  
  void _loadNotes() => loadNotes();

  Future<void> refreshNotes() async {
    final userId = _authController.currentUserId;
    if (userId == null) return;

    isLoading.value = true;
    try {
      final notesList = await _repository.fetchNotes(userId);
      notes.value = notesList;
      error.value = null;
    } catch (e) {
      error.value = 'Failed to refresh notes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createNote({
    required String title,
    required String content,
  }) async {
    final userId = _authController.currentUserId;
    if (userId == null) return 'User not authenticated';

    try {
      await _repository.createNote(
        title: title,
        content: content,
        userId: userId,
      );
      return null;
    } catch (e) {
      return 'Failed to create note: $e';
    }
  }

  Future<String?> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      await _repository.updateNote(
        id: id,
        title: title,
        content: content,
      );
      return null;
    } catch (e) {
      return 'Failed to update note: $e';
    }
  }

  Future<String?> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      return null;
    } catch (e) {
      return 'Failed to delete note: $e';
    }
  }

  List<Note> get filteredNotes {
    if (searchQuery.value.isEmpty) {
      return notes.toList();
    }
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      return notes.toList();
    }
    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }
  
  bool get hasNotes => notes.isNotEmpty;
  bool get hasSearchQuery => searchQuery.value.trim().isNotEmpty;
}
