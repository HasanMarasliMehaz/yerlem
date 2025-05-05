import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/bottombar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Expanded(child: BottomBar())]));
  }
}
