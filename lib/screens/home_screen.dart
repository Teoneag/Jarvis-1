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
  final isRailHidden = BoolW(false);
  final pendingSentence = StringNW();
  final navIndex = IntW(0);
  final List<String> chatNames = [];
  final List<Message> messages = [];

  // late final SyncObj sO;
  late final HSV hSV;

  @override
  void initState() {
    super.initState();
    // rO = RailObj(chatNames, SyncObj(setState, isRailSyncing));
    // cO = ChatObj(
    //     '', messages, SyncObj(setState, isChatSyncing), isRespondWaited);
    // sO = SyncObj(setState, isAppSyncing);
    hSV = HSV(
      isAppSyncing,
      isRailSyncing,
      isChatSyncing,
      isRailHidden,
      pendingSentence,
      navIndex,
      chatNames,
      messages,
      onIndexChange,
      onRailChange,
      setState,
    );
    ChatM.loadChatNamesAndChat(hSV);
  }

  void onIndexChange(int index) {
    setState(() {
      navIndex.v = index;
    });
    ChatM.loadMessages(hSV);
  }

  void onRailChange() {
    setState(() {
      isRailHidden.v = !isRailHidden.v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar1(hSV),
      body: Row(
        children: [
          !isRailHidden.v
              ? Row(children: [
                  NavBar1(hSV),
                  const VerticalDivider(),
                ])
              : Container(),
          Expanded(
            child: isChatSyncing.v
                ? loadingCenter()
                : chatNames.isEmpty
                    ? const Text('Please select a chat')
                    : ChatWidget(hSV),
          ),
        ],
      ),
    );
  }
}
