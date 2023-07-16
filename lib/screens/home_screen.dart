import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarvis_1/models/message_model.dart';

import '/chat/chat_methods.dart';
import '/firestore/firestore_methods.dart';
import '/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _isSyncing = BoolW(false);
  int _selectedIndex = 0;
  final _titleC = TextEditingController();
  final _messageC = TextEditingController();
  late final SyncObj sO;

  @override
  void initState() {
    super.initState();
    sO = SyncObj(setState, _isSyncing);
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
            onPressed: () => ChatM.displayDialog(context, _titleC, sO),
            icon: const Icon(Icons.add),
          ),
          _isSyncing.v
              ? const CircularProgressIndicator()
              : IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.sync),
                ),
          const SizedBox(width: 30), // TODO: delete this & remove debug banner
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(chatsS).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCenter();
          }

          final chatDocs = snapshot.data!.docs;
          return Row(
            children: [
              NavigationRail(
                // extended: true,
                // TODO: make it 3 states: extended, collapsed, hidden
                // TODO: make the highlight look right
                minWidth: 90,
                destinations: chatDocs.map((chat) {
                  return NavigationRailDestination(
                    icon: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              chat.id,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ),
                        // IconButton( // TODO: add delete chat
                        //   onPressed: () => ChatM.removeChat(chat.id, sO),
                        //   icon: const Icon(Icons.delete),
                        // ),
                      ],
                    ),
                    label: Text(chat.id),
                  );
                }).toList(),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const VerticalDivider(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return ListTile(
                              // title: Text(chatDocs[_selectedIndex].id),
                              );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => ChatM.sendMessage(
                              Message(_messageC.text),
                              chatDocs[_selectedIndex].id,
                              sO,
                            ),
                            icon: const Icon(Icons.send),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
