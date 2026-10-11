import 'package:flutter/material.dart';

import 'data/chat_loader.dart';
import 'models/chat_data.dart';
import 'theme/app_theme.dart';
import 'ui/chat_screen.dart';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat UI',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: FutureBuilder<ChatData>(
        future: loadChatSample(),
        builder: (context, snap) {
          if (snap.hasData) return ChatScreen(data: snap.data!);
          if (snap.hasError) {
            return Scaffold(
              body: Center(child: Text(chatLoadErrorMessage)),
            );
          }
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    );
  }
}
