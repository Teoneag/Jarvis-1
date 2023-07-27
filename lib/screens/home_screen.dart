import 'package:flutter/material.dart';
import '/utils.dart';
import '/models/message_model.dart';
import '/methdos/chat/chat_methods.dart';
import '/widgets/app_bar.dart';
import '/widgets/nav_rail.dart';
import '/widgets/chat_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _isAppSyncing = BoolW(false);
  final _isRailSyncing = BoolW(false);
  final _isChatSyncing = BoolW(false);
  int _navIndex = 0;
  final _isRailHidden = BoolW(false);
  final List<String> _chatNames = [];
  final List<Message> _messages = [];
  late final RailObj rO;
  late final ChatObj cO;
  late final SyncObj sO;

  @override
  void initState() {
    super.initState();
    rO = RailObj(_chatNames, SyncObj(setState, _isRailSyncing));
    cO = ChatObj(_messages, SyncObj(setState, _isChatSyncing));
    sO = SyncObj(setState, _isAppSyncing);
    ChatM.loadChatNamesAndChat(rO, cO);
  }

  void _onIndexChange(int index) {
    setState(() {
      _navIndex = index;
    });
    ChatM.loadMessages(_chatNames[_navIndex], cO);
  }

  void _onRailChange() {
    setState(() {
      _isRailHidden.v = !_isRailHidden.v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar1(rO, _onRailChange, _onIndexChange, sO.isSyncing),
      body: Row(
        children: [
          !_isRailHidden.v
              ? Row(children: [
                  NavBar1(rO, cO, _onIndexChange, _navIndex),
                  const VerticalDivider(),
                ])
              : Container(),
          Expanded(
            child: _isChatSyncing.v
                ? loadingCenter()
                : _chatNames.isEmpty
                    ? const Text('Please select a chat')
                    : ChatWidget(_chatNames[_navIndex], cO, sO),
          ),
        ],
      ),
    );
  }
}
