import 'package:flutter/material.dart';

import '/utils.dart';
import '/chat/chat_methods.dart';
import '/widgets/chat_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _isSyncing = BoolW(false);
  final _isRailSyncing = BoolW(false);
  final _titleC = TextEditingController();
  late final SyncObj sO;
  late final SyncObj sO2;
  List<String> chatNames = [];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    sO = SyncObj(setState, _isSyncing);
    sO2 = SyncObj(setState, _isRailSyncing);
    ChatM.loadChatNames(chatNames, sO2);
  }

  @override
  void dispose() {
    _titleC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Jarvis'), // TODO: change to conv name or date
        actions: [
          IconButton(
            onPressed: () =>
                ChatM.displayDialog(context, _titleC, sO, chatNames),
            icon: const Icon(Icons.add),
          ),
          _isSyncing.v
              ? const CircularProgressIndicator()
              : IconButton(
                  onPressed: () {
                    ChatM.loadChatNames(chatNames, sO2);
                  },
                  icon: const Icon(Icons.sync),
                ),
          const SizedBox(width: 30), // TODO: delete this & remove debug banner
        ],
      ),
      body: _isRailSyncing.v
          ? loadingCenter()
          : Row(
              children: [
                chatNames.length < 2
                    ? const Text('Please add one more chat')
                    : NavigationRail(
                        // TODO: make it 3 states: extended, collapsed, hidden
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
                        selectedIndex: _index,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _index = index;
                          });
                        },
                      ),
                const VerticalDivider(),
                Expanded(
                  child: ChatWidget(chatNames[_index]),
                ),
              ],
            ),
    );
  }
}
