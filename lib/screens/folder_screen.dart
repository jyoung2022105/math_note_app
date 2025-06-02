import 'package:flutter/material.dart';
import 'package:math_note_app/models/folder.dart';
import 'package:math_note_app/models/note.dart';
import 'package:math_note_app/providers/note_viewmodel.dart';
import 'package:math_note_app/providers/folder_viewmodel.dart';
import 'package:math_note_app/screens/note_detail_screen.dart';
import 'package:provider/provider.dart';

class FolderScreen extends StatelessWidget {
  final Folder folder; // 전달받을 폴더 객체

  const FolderScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    // NoteViewModel을 사용하여 이 폴더에 속한 노트들을 가져옵니다.
    // 현재 NoteViewModel은 모든 노트를 가지고 있으므로, folder.noteIds를 사용해 필터링합니다.
    final noteViewModel = Provider.of<NoteViewModel>(context);
    final List<Note> notesInFolder = noteViewModel.notes
        .where((note) => folder.noteIds.contains(note.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name), // 폴더 이름 표시
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Notes in ${folder.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: notesInFolder.isEmpty
                ? const Center(
                    child: Text('No notes in this folder yet. Add one!'),
                  )
                : ListView.builder(
                    itemCount: notesInFolder.length,
                    itemBuilder: (context, index) {
                      final note = notesInFolder[index];
                      return ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: Text(note.title),
                        subtitle: Text(
                          note.content.length > 50
                              ? '${note.content.substring(0, 50)}...'
                              : note.content, // 간단한 미리보기
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          // 수정/삭제 아이콘을 위해 Row 사용
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              note.updatedAt.toLocal().toString().substring(
                                0,
                                10,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Delete Note',
                              onPressed: () {
                                _confirmDeleteNoteDialog(
                                  context,
                                  noteViewModel,
                                  Provider.of<FolderViewModel>(
                                    context,
                                    listen: false,
                                  ),
                                  note,
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(
                                note: note,
                                folderId: folder.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NoteDetailScreen(folderId: folder.id), // 새 노트 작성 시 폴더 ID 전달
            ),
          );
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.note_add),
      ),
    );
  }

  void _confirmDeleteNoteDialog(
    BuildContext context,
    NoteViewModel noteVM,
    FolderViewModel folderVM,
    Note note,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text(
            'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                noteVM.deleteNote(note.id);
                if (note.folderId != null) {
                  // folderId가 있는 경우에만 폴더에서 제거
                  folderVM.removeNoteFromFolder(note.folderId!, note.id);
                }
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                // Optionally, show a snackbar: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${note.title}" deleted')));
              },
            ),
          ],
        );
      },
    );
  }
}
