import 'package:flutter/material.dart';

import '/utils.dart';
import '/methdos/chat/chat_methods.dart';

class NavBar1 extends StatelessWidget {
  final HSV hSV;
  const NavBar1(this.hSV, {super.key});

  @override
  Widget build(BuildContext context) {
    return hSV.isRailSyncing.v
        ? loadingCenter()
        : hSV.chatNames.isEmpty
            ? const Text('Please add at least one chat')
            : hSV.chatNames.length == 1
                ? railTile(hSV, context, 0)
                : NavigationRail(
                    // TODO: hover(small screen)/use zoom drawer/animated list
                    groupAlignment: 0,
                    destinations: [
                      for (int i = 0; i < hSV.chatNames.length; i++)
                        NavigationRailDestination(
                          icon: railTile(hSV, context, i),
                          label: Text(hSV.chatNames[i]),
                        )
                    ],
                    selectedIndex: hSV.navIndex,
                    onDestinationSelected: (int index) =>
                        hSV.onIndexChange(index),
                  );
  }
}

Widget railTile(
  HSV hSV,
  BuildContext context,
  int removeI,
) {
  return GestureDetector(
    onLongPress: () => ChatM.removeDialog(hSV, context, hSV.navIndex),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        hSV.chatNames[removeI],
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
