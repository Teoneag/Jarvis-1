import 'package:flutter/material.dart';
import '/widgets/app_bar.dart';
import '/widgets/nav_rail.dart';
import '/widgets/chat_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRailHidden = false;
  String _chatName = '';
  final List<String> _chatNames = [];

  void _onChangeRail() {
    setState(() {
      _isRailHidden = !_isRailHidden;
    });
  }

  void _onChatChange(String chatName) {
    if (chatName == _chatName) return;
    setState(() {
      _chatName = chatName;
    });
    print(_chatName);
  }

  void _addChat(String title) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar1(_onChangeRail, _addChat),
      body: Row(
        children: [
          !_isRailHidden
              ? Row(
                  children: [
                    NavBar1(_onChatChange),
                    const VerticalDivider(),
                  ],
                )
              : Container(),
          Expanded(
            child: ChatWidget(_chatName),
          ),
        ],
      ),
    );
  }
}
