import 'package:cs_chat_app/auxiliary/navigatorservice.dart';
import 'package:cs_chat_app/screens/chat.dart';
import 'package:cs_chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorService.navigatorKey,
      title: 'Flutter Demo',
      routes: {
        LoginScreen.route: (_) => LoginScreen(),
        ChatScreen.route: (_) => ChatScreen()
      },
    );
  }
}

