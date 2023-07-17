import 'package:flutter/material.dart';
import '/utils.dart';

class NavBar1 extends StatelessWidget {
  final List<String> chatNames;
  final ValueChanged<int> onIndexChange;
  final int navIndex;
  final BoolW isSyncing;

  // add RailState

  const NavBar1(
      this.chatNames, this.onIndexChange, this.navIndex, this.isSyncing,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return isSyncing.v
        ? loadingCenter()
        : chatNames.length < 2
            ? const Text('Please add one more chat')
            : NavigationRail(
                // TODO: make it 3 states: extended, hover, hidden
                // TODO: make the highlight look right
                minWidth: 90,
                destinations: chatNames.map((chat) {
                  return NavigationRailDestination(
                    icon: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              chat,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ),
                        // TODO: add delete chat
                      ],
                    ),
                    label: Text(chat),
                  );
                }).toList(),
                selectedIndex: navIndex,
                onDestinationSelected: (int index) => onIndexChange(index),
              );
  }
}

// enum RailState {
//   visible,
//   hidden,
// }
