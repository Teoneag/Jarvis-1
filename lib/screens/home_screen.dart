import 'package:flutter/material.dart';
import '/widgets/chat_widget.dart';
import '/widgets/nav_rail.dart';
import '/widgets/app_bar.dart';
import '/models/message_model.dart';
import '/utils.dart';
import '/chat/chat_methods.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _isSyncing = BoolW(false);
  final _isRailSyncing = BoolW(false);
  final _isChatSyncing = BoolW(false);
  late final SyncObj _sO;
  int _navIndex = 0;
  final List<String> _chatNames = [];
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _sO = SyncObj(setState, _isSyncing);
    ChatM.loadChatNamesAndChat(
        _chatNames, _messages, _sO, _isRailSyncing, _isChatSyncing);
  }

  void _onIndexChange(int index) {
    setState(() {
      _navIndex = index;
    });
    ChatM.loadMessages(_chatNames[_navIndex], _messages, _sO, _isChatSyncing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar1(_chatNames, _sO),
      body: Row(
        children: [
          NavBar1(_chatNames, _onIndexChange, _navIndex, _isRailSyncing),
          const VerticalDivider(),
          Expanded(
            child: _isChatSyncing.v
                ? loadingCenter()
                : ChatWidget(_messages, _chatNames[_navIndex], _isChatSyncing),
          ),
        ],
      ),
    );
  }
}
