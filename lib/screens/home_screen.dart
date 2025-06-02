import 'package:flutter/material.dart';
import 'package:math_note_app/providers/folder_viewmodel.dart';
import 'package:math_note_app/screens/note_detail_screen.dart';
import 'package:math_note_app/screens/folder_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddFolderDialog(BuildContext context) {
    final TextEditingController folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: "Folder name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (folderNameController.text.isNotEmpty) {
                  Provider.of<FolderViewModel>(
                    context,
                    listen: false,
                  ).addFolder(folderNameController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // FolderViewModel 가져오기
    final folderViewModel = Provider.of<FolderViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline), // 테스트용 버튼 아이콘
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NoteDetailScreen(),
                ),
              );
            },
            tooltip: 'Test LaTeX Editor', // 툴크 추가
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Folders',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: folderViewModel.folders.isEmpty
                ? const Center(child: Text('No folders yet. Add one!'))
                : ListView.builder(
                    itemCount: folderViewModel.folders.length,
                    itemBuilder: (context, index) {
                      final folder = folderViewModel.folders[index];
                      return ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(folder.name),
                        subtitle: Text('${folder.noteIds.length} notes'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FolderScreen(folder: folder),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          // 기존의 LaTeX 테스트 버튼은 AppBar로 이동
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFolderDialog(context),
        tooltip: 'Add Folder',
        child: const Icon(Icons.add),
      ),
    );
  }
}
