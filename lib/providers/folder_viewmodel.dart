import 'dart:convert'; // jsonEncode, jsonDecode 사용
import 'package:flutter/foundation.dart';
import 'package:math_note_app/models/folder.dart'; // Folder 모델 import
import 'dart:math'; // Random ID 생성을 위해 import
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferences import

const String _foldersStorageKey = 'folders_data'; // 저장소 키

class FolderViewModel extends ChangeNotifier {
  List<Folder> _folders = [];

  List<Folder> get folders => _folders;

  FolderViewModel() {
    _loadFolders(); // 생성 시 폴더 로드
  }

  Future<void> _loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? foldersString = prefs.getString(_foldersStorageKey);
    if (foldersString != null) {
      final List<dynamic> folderJson = jsonDecode(foldersString) as List;
      _folders = folderJson
          .map((json) => Folder.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final String foldersString = jsonEncode(
      _folders.map((folder) => folder.toJson()).toList(),
    );
    await prefs.setString(_foldersStorageKey, foldersString);
  }

  void addFolder(String name) {
    final newFolder = Folder(
      id: Random().nextInt(100000).toString(), // 임시 ID 생성
      name: name,
      noteIds: [],
      createdAt: DateTime.now(),
    );
    _folders.add(newFolder);
    _saveFolders(); // 변경 후 저장
    notifyListeners(); // UI 업데이트 알림
  }

  void addNoteToFolder(String folderId, String noteId) {
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index != -1) {
      if (!_folders[index].noteIds.contains(noteId)) {
        _folders[index].noteIds.add(noteId);
        _saveFolders();
        notifyListeners();
      }
    }
  }

  void removeNoteFromFolder(String? folderId, String noteId) {
    if (folderId == null) return; // folderId가 없으면 아무것도 안 함
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index != -1) {
      _folders[index].noteIds.remove(noteId);
      _saveFolders();
      notifyListeners();
    }
  }

  // TODO: Implement other folder management logic (delete, rename, etc.)
}
