import 'package:flutter/material.dart';
import 'package:jarvis_1/methdos/chat/chat_methods.dart';
import '/utils.dart';

class NavBar1 extends StatelessWidget {
  final List<String> chatNames;
  final ValueChanged<int> onIndexChange;
  final int navIndex;
  final BoolW isSyncing;
  final SyncObj sO;

  const NavBar1(this.chatNames, this.onIndexChange, this.navIndex,
      this.isSyncing, this.sO,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return isSyncing.v
        ? loadingCenter()
        : chatNames.isEmpty
            ? const Text('Please add at least one chat')
            : chatNames.length == 1
                ? railTile(context, chatNames[0], sO, chatNames)
                : NavigationRail(
                    // TODO: make it hover if the screen is smaller than x
                    groupAlignment: 0,
                    destinations: chatNames.map((chat) {
                      return NavigationRailDestination(
                        icon: railTile(context, chat, sO, chatNames),
                        label: Text(chat),
                      );
                    }).toList(),
                    selectedIndex: navIndex,
                    onDestinationSelected: (int index) => onIndexChange(index),
                  );
  }
}

Widget railTile(BuildContext context, String chat, SyncObj sO,
        List<String> chatNames) =>
    GestureDetector(
      onLongPress: () => ChatM.removeDialog(context, chat, sO, chatNames),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          chat,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
