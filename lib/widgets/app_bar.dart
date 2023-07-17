import 'package:flutter/material.dart';
import '/utils.dart';
import '/chat/chat_methods.dart';

class AppBar1 extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  final SyncObj sO;
  final List<String> chatNames;

  const AppBar1(this.chatNames, this.sO, {super.key});

  @override
  State<AppBar1> createState() => _AppBar1State();
}

class _AppBar1State extends State<AppBar1> {
  @override
  void dispose() {
    _titleC.dispose();
    super.dispose();
  }

  final _titleC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('Jarvis'), // TODO: change to conv name or date
      actions: [
        IconButton(
          onPressed: () => ChatM.displayDialog(
              context, _titleC, widget.sO, widget.chatNames),
          icon: const Icon(Icons.add),
        ),
        widget.sO.isSyncing.v
            ? const CircularProgressIndicator()
            : IconButton(
                onPressed: () {
                  // ChatM.loadChatNames(chatNames, sO2); // TODO: make this
                },
                icon: const Icon(Icons.sync),
              ),
        const SizedBox(width: 30), // TODO: delete this & remove debug banner
      ],
    );
  }
}
