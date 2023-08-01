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
  final isAppSyncing = BoolW(false);
  final isRailSyncing = BoolW(false);
  final isChatSyncing = BoolW(false);
  int navIndex = 0;
  final isRailHidden = BoolW(false);
  final List<String> chatNames = [];
  final List<Message> messages = [];
  final isRespondWaited = BoolW(false);

  late final RailObj rO;
  late final ChatObj cO;
  late final SyncObj sO;

  @override
  void initState() {
    super.initState();
    rO = RailObj(chatNames, SyncObj(setState, isRailSyncing));
    cO = ChatObj(messages, SyncObj(setState, isChatSyncing),
        isRespondWaited: isRespondWaited);
    sO = SyncObj(setState, isAppSyncing);
    ChatM.loadChatNamesAndChat(rO, cO);
  }

  void onIndexChange(int index) {
    setState(() {
      navIndex = index;
    });
    ChatM.loadMessages(chatNames[navIndex], cO);
  }

  void onRailChange() {
    setState(() {
      isRailHidden.v = !isRailHidden.v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar1(rO, onRailChange, onIndexChange, sO.isSyncing),
      body: Row(
        children: [
          !isRailHidden.v
              ? Row(children: [
                  NavBar1(rO, cO, onIndexChange, navIndex),
                  const VerticalDivider(),
                ])
              : Container(),
          Expanded(
            child: isChatSyncing.v
                ? loadingCenter()
                : chatNames.isEmpty
                    ? const Text('Please select a chat')
                    : ChatWidget(chatNames[navIndex], cO, sO, isRespondWaited),
          ),
        ],
      ),
    );
  }
}
