import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_note_app/models/note.dart';
import 'package:math_note_app/providers/note_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:math_note_app/providers/folder_viewmodel.dart';
import 'package:flutter_painter/flutter_painter.dart';

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

  // PainterController 초기화
  late PainterController _painterController;

  @override
  void initState() {
    super.initState();

    // PainterController 설정
    _painterController = PainterController(
      settings: PainterSettings(
        freeStyle: FreeStyleSettings(
          color: Colors.black,
          strokeWidth: 5,
          mode: FreeStyleMode.draw, // 기본 모드를 그리기로 설정
        ),
        // 다른 도구 설정 (텍스트, 도형 등)은 필요에 따라 추가
      ),
    );

    if (widget.note != null) {
      _isEditing = true;
      _titleController.text = widget.note!.title;
      _latexController.text = widget.note!.content;
      _latexInput = widget.note!.content;
      if (widget.note!.drawings != null && widget.note!.drawings!.isNotEmpty) {
        try {
          final List<Drawable> loadedDrawables = widget.note!.drawings!
              .map((json) {
                // Drawable.fromJson이 실제로는 어떤 Drawable 타입을 반환할지 모르므로,
                // 그리고 null을 반환할 수도 있으므로 주의해야 함.
                // flutter_painter 패키지는 내부적으로 json['type']을 보고 맞는 Drawable 객체를 생성 시도함.
                return Drawable.fromJson(json);
              })
              .where((drawable) => drawable != null) // null이 아닌 경우만 필터링
              .cast<Drawable>() // 명시적으로 Drawable로 캐스팅
              .toList();
          _painterController.addDrawables(loadedDrawables);
        } catch (e, stackTrace) {
          print("Error loading drawings: $e\n$stackTrace");
          // 사용자에게 로딩 실패를 알리는 UI를 표시할 수도 있습니다.
        }
      }
    } else {
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
    _painterController.dispose(); // PainterController 해제
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text;
    final latexContent = _latexController.text;
    final List<Map<String, dynamic>> drawingData = _painterController.drawables
        .map((d) => (d as dynamic).toJson() as Map<String, dynamic>)
        .toList();

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
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: latexContent,
        drawings: drawingData,
      );
      noteViewModel.updateNote(updatedNote);
    } else {
      final Note newNote = noteViewModel.addNote(
        title: title,
        content: latexContent,
        drawings: drawingData,
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
        padding: const EdgeInsets.all(8.0), // 패딩 약간 줄임
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
            const SizedBox(height: 8),
            TextField(
              controller: _latexController,
              decoration: const InputDecoration(
                labelText: 'LaTeX Code (Optional)',
                border: OutlineInputBorder(),
                hintText: r'eg. \\frac{a}{b}',
              ),
              minLines: 1, // LaTeX 입력은 필수가 아니므로 줄 수 조절
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 8),
            // LaTeX 미리보기 (필요하다면 크기 조절 또는 숨김 처리)
            if (_latexInput.isNotEmpty)
              SizedBox(
                height: 50, // LaTeX 미리보기 높이 제한
                child: SingleChildScrollView(
                  child: Math.tex(
                    _latexInput,
                    textStyle: const TextStyle(fontSize: 20),
                    onErrorFallback: (e) => Text(
                      'LaTeX Error: ${e.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // 필기 영역 타이틀
            const Text(
              'Freehand Drawing:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Painter 도구 모음 (간단한 버전)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () => _painterController.undo(),
                  tooltip: "Undo",
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () => _painterController.redo(),
                  tooltip: "Redo",
                ),
                IconButton(
                  icon: const Icon(Icons.brush),
                  tooltip: "Pen",
                  onPressed: () {
                    _painterController.freeStyleMode = FreeStyleMode.draw;
                    _painterController.freeStyleColor = Colors.black;
                    _painterController.freeStyleStrokeWidth = 5;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline), // 아이콘 변경
                  tooltip: "Eraser",
                  onPressed: () {
                    _painterController.freeStyleMode = FreeStyleMode.erase;
                    // 지우개 모드일 때 스트로크 너비를 더 크게 설정할 수 있음
                    // _painterController.freeStyleStrokeWidth = 10;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () =>
                      _painterController.clearDrawables(), // clearDrawables 사용
                  tooltip: "Clear All",
                ),
                // TODO: 색상 선택, 굵기 조절 등 추가
              ],
            ),
            // FlutterPainter 위젯
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.white, // 필기 영역 배경색
                ),
                child: FlutterPainter(controller: _painterController),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
