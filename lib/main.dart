import 'package:flutter/material.dart';
import 'package:math_note_app/providers/folder_viewmodel.dart'; // FolderViewModel import
import 'package:math_note_app/providers/note_viewmodel.dart'; // NoteViewModel import
import 'package:math_note_app/screens/home_screen.dart'; // 경로 수정
import 'package:provider/provider.dart'; // Provider import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // MultiProvider로 감싸기
      providers: [
        ChangeNotifierProvider(create: (_) => FolderViewModel()),
        ChangeNotifierProvider(
          create: (_) => NoteViewModel(),
        ), // NoteViewModel 추가
        // 다른 ViewModel이 있다면 여기에 추가
      ],
      child: MaterialApp(
        title: 'Math Note App', // 앱 이름 변경
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ), // 테마 색상 변경 (예시)
          useMaterial3: true, // Material 3 사용 명시
        ),
        home: const HomeScreen(), // HomeScreen으로 변경
      ),
    );
  }
}

// MyHomePage 및 _MyHomePageState 클래스 삭제
