import 'package:flutter/material.dart';
import '/models/message_model.dart';
import '/utils.dart';
import '/chat/chat_methods.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _isSyncing = BoolW(false);
  final _isRailSyncing = BoolW(false);
  final _isChatSyncing = BoolW(false);
  final _titleC = TextEditingController();
  final _messageC = TextEditingController();
  late final SyncObj sO;
  late final SyncObj sO2;
  late final SyncObj sO3;
  List<String> chatNames = [];
  List<Message> messages = [];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    sO = SyncObj(setState, _isSyncing);
    sO2 = SyncObj(setState, _isRailSyncing);
    sO3 = SyncObj(setState, _isChatSyncing);
    ChatM.loadChatNamesAndChat(chatNames, messages, sO2, _isChatSyncing);
  }

  @override
  void dispose() {
    _titleC.dispose();
    _messageC.dispose();
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
                    // ChatM.loadChatNames(chatNames, sO2); // TODO: make this
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
                            ChatM.loadMessages(messages, sO3, chatNames[index]);
                          });
                        },
                      ),
                const VerticalDivider(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _isChatSyncing.v
                            ? loadingCenter()
                            : ListView.builder(
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(messages[index].text),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: _messageC,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => ChatM.sendMessage(
                                  _messageC, chatNames[_index], sO, messages),
                              icon: const Icon(Icons.send),
                            ),
                          ),
                          onSubmitted: (_) => ChatM.sendMessage(
                              _messageC, chatNames[_index], sO, messages),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
