import 'package:flutter/material.dart';
import '/utils.dart';
import '/methdos/chat/chat_methods.dart';

class NavBar1 extends StatefulWidget {
  final ValueChanged<String> onChatChange;

  const NavBar1(this.onChatChange, {super.key});

  @override
  State<NavBar1> createState() => _NavBar1State();
}

class _NavBar1State extends State<NavBar1> {
  final _isSyncing = BoolW(false);
  int _navIndex = 0;
  final List<String> _chatNames = [];
  late final SyncObj sO;

  void addChat(String chatName) {
    print(chatName);
  }

  @override
  void initState() {
    super.initState();
    sO = SyncObj(setState, _isSyncing);
    ChatM.loadChatNames(_chatNames, sO, widget.onChatChange);
  }

  @override
  Widget build(BuildContext context) {
    return _isSyncing.v
        ? loadingCenter()
        : _chatNames.isEmpty
            ? const Text('Please add at least one chat')
            : _chatNames.length == 1
                ? railTile(context, _chatNames, 0, 0, widget.onChatChange)
                : NavigationRail(
                    // TODO: make it hover if the screen is smaller than x
                    groupAlignment: 0,
                    destinations: [
                      for (int i = 0; i < _chatNames.length; i++)
                        NavigationRailDestination(
                          icon: railTile(context, _chatNames, i, _navIndex,
                              widget.onChatChange),
                          label: Text(_chatNames[i]),
                        )
                    ],
                    selectedIndex: _navIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _navIndex = index;
                      });
                      widget.onChatChange(_chatNames[index]);
                    });
  }
}

Widget railTile(
  BuildContext context,
  List<String> chatNames,
  int removeI,
  int selectedI,
  ValueChanged<String> onChatChange,
) {
  return GestureDetector(
    // onLongPress: () => ChatM.removeDialog(
    //   context,
    //   removeI,
    //   selectedI,
    //   onIndexChange,
    // ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        chatNames[removeI],
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
