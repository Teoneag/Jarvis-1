import 'package:flutter/material.dart';
import '/utils.dart';
import '/methdos/chat/chat_methods.dart';

class NavBar1 extends StatelessWidget {
  final RailObj rO;
  final ChatObj cO;
  final Function(int) onIndexChange;
  final int navIndex;

  const NavBar1(this.rO, this.cO, this.onIndexChange, this.navIndex,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return rO.sO.isSyncing.v
        ? loadingCenter()
        : rO.chatNames.isEmpty
            ? const Text('Please add at least one chat')
            : rO.chatNames.length == 1
                ? railTile(context, rO, cO, 0, navIndex, onIndexChange)
                : NavigationRail(
                    // TODO: make it hover if the screen is smaller than x
                    groupAlignment: 0,
                    destinations: [
                      for (int i = 0; i < rO.chatNames.length; i++)
                        NavigationRailDestination(
                          icon: railTile(
                              context, rO, cO, i, navIndex, onIndexChange),
                          label: Text(rO.chatNames[i]),
                        )
                    ],
                    selectedIndex: navIndex,
                    onDestinationSelected: (int index) => onIndexChange(index),
                  );
  }
}

Widget railTile(
  BuildContext context,
  RailObj rO,
  ChatObj cO,
  int removeI,
  int selectedI,
  Function(int) onIndexChange,
) {
  return GestureDetector(
    onLongPress: () => ChatM.removeDialog(
      context,
      rO,
      cO,
      removeI,
      selectedI,
      onIndexChange,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        rO.chatNames[removeI],
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
