import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_note_app/models/note.dart';
import 'package:math_note_app/providers/note_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:math_note_app/providers/folder_viewmodel.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note; // 편집할 노트 (새 노트의 경우 null)
  final String? folderId; // 새 노트를 추가할 폴더 ID (옵션)

  const NoteDetailScreen({super.key, this.note, this.folderId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _latexController = TextEditingController();
  String _latexInput = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isEditing = true;
      _titleController.text = widget.note!.title;
      _latexController.text = widget.note!.content;
      _latexInput = widget.note!.content;
    } else {
      // 새 노트의 경우 LaTeX 에디터에 기본 예시 값 설정 (옵션)
      _latexInput = r'E = mc^2';
      _latexController.text = _latexInput;
    }

    _latexController.addListener(() {
      // LaTeX 입력이 너무 길 경우 화면 갱신이 느려질 수 있으므로
      // setState를 debounce하거나, 입력이 끝났을 때만 호출하는 것을 고려할 수 있습니다.
      if (mounted && _latexInput != _latexController.text) {
        setState(() {
          _latexInput = _latexController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latexController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _latexController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty.')));
      return;
    }

    final noteViewModel = Provider.of<NoteViewModel>(context, listen: false);
    final folderViewModel = Provider.of<FolderViewModel>(
      context,
      listen: false,
    );

    if (_isEditing) {
      final updatedNote = widget.note!.copyWith(title: title, content: content);
      noteViewModel.updateNote(updatedNote);
    } else {
      // 새 노트 추가
      final Note newNote = noteViewModel.addNote(
        title: title,
        content: content,
        folderId: widget.folderId,
      );

      if (widget.folderId != null) {
        folderViewModel.addNoteToFolder(widget.folderId!, newNote.id);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _latexController,
              decoration: const InputDecoration(
                labelText: 'Enter LaTeX code',
                border: OutlineInputBorder(),
                hintText: r'eg. \\frac{a}{b}, x^2 + y^2 = r^2', // 힌트 추가
              ),
              minLines: 3,
              maxLines: 8, // 여러 줄 입력 가능하도록 maxLines 증가
              keyboardType: TextInputType.multiline, // 여러 줄 입력 지원
            ),
            const SizedBox(height: 10),
            const Text(
              'Rendered Output:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: SingleChildScrollView(
                  child: Center(
                    child: Math.tex(
                      _latexInput, // 항상 _latexInput 사용 (초기값 또는 입력값)
                      textStyle: const TextStyle(fontSize: 24),
                      onErrorFallback: (FlutterMathException e) {
                        return Text(
                          'Error: ${e.message}\nCheck your LaTeX syntax.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
