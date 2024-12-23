import 'package:flutter/material.dart';
import 'screens/post_list_screen.dart';
import 'screens/post_form_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Post',
      initialRoute: '/post_list',
      routes: {
        '/post_list': (context) => PostListScreen(),
        '/create_post': (context) => PostFormScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
