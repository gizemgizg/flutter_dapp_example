import 'package:flutter/material.dart';
import 'package:flutter_dapp_example/view/user_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter User Dapp',
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      home: UserView(),
    );
  }
}
