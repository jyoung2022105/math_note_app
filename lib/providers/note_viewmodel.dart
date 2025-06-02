import 'dart:convert';
import 'dart:math'; // Random ID
import 'package:flutter/foundation.dart';
import 'package:math_note_app/models/note.dart'; // Note 모델 import
import 'package:shared_preferences/shared_preferences.dart';

const String _notesStorageKey = 'notes_data'; // 저장소 키

class NoteViewModel extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NoteViewModel() {
    _loadNotes(); // 생성 시 노트 로드
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString(_notesStorageKey);
    if (notesString != null) {
      final List<dynamic> noteJson = jsonDecode(notesString) as List;
      _notes = noteJson
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String notesString = jsonEncode(
      _notes.map((note) => note.toJson()).toList(),
    );
    await prefs.setString(_notesStorageKey, notesString);
  }

  // 노트 추가
  Note addNote({
    required String title,
    required String content,
    String? folderId,
  }) {
    final newNote = Note(
      id: Random().nextInt(100000).toString(), // 임시 ID
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      folderId: folderId, // 폴더 ID 설정
    );
    _notes.add(newNote);
    _saveNotes();
    notifyListeners();
    return newNote; // 생성된 노트 객체 반환
  }

  // 노트 수정
  void updateNote(Note updatedNote) {
    int index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(updatedAt: DateTime.now());
      _saveNotes();
      notifyListeners();
    }
  }

  // 노트 삭제 (기본)
  void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
    _saveNotes();
    notifyListeners();
    // TODO: FolderViewModel과 연동하여 folder.noteIds에서도 제거
  }

  Note? getNoteById(String noteId) {
    try {
      return _notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  // TODO: 특정 폴더의 노트 가져오기, 노트 검색 등 추가 기능 구현
}
