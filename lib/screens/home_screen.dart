import 'package:flutter/material.dart';
import '/methdos/jarvis/jarvis_methods.dart';
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

// TODO modify this to use global variables

class _HomeScreenState extends State<HomeScreen> {
  final isAppSyncing = BoolW(false);
  final isRailSyncing = BoolW(false);
  final isChatSyncing = BoolW(false);
  final isRailHidden = BoolW(false);
  final navIndex = IntW(0);
  final List<DateTime> pendngSentences = [];
  final List<String> chatNames = [];
  final List<Message> messages = [];
  final indent = IntW(0);
  final logIndent = IntW(1);

  late final HSV hSV;
  final List<ChatObj> cOList = [];
  // late final ChatObj cO;

  // list ChatObj, one for every chat

  @override
  void initState() {
    super.initState();
    hSV = HSV(
      isAppSyncing,
      isRailSyncing,
      isChatSyncing,
      isRailHidden,
      navIndex,
      chatNames,
      onIndexChange,
      onRailChange,
      setState,
    );

    JarvisM.hSV = hSV;
    ChatM.laodChatNamesAndChatList(hSV, cOList);
  }

  void onIndexChange(int index) {
    setState(() {
      navIndex.v = index;
    });
  }

  void onRailChange() {
    setState(() {
      isRailHidden.v = !isRailHidden.v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar1(hSV, cOList[navIndex.v]),
      body: Row(
        children: [
          !isRailHidden.v
              ? Row(children: [
                  NavBar1(hSV),
                  const VerticalDivider(),
                ])
              : Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isChatSyncing.v
                  ? loadingCenter()
                  : chatNames.isEmpty
                      ? const Text('Please select a chat')
                      : ChatWidget(hSV, cOList[navIndex.v]),
            ),
          ),
        ],
      ),
    );
  }
}
