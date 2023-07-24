import 'package:flutter/material.dart';

class AppBar1 extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onChangeRail;
  final void Function(String) addChat;

  const AppBar1(this.onChangeRail, this.addChat, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBar1> createState() => _AppBar1State();
}

class _AppBar1State extends State<AppBar1> {
  final _titleC = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _titleC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: IconButton(
        onPressed: widget.onChangeRail,
        icon: const Icon(Icons.menu),
      ),
      title: const Text('Jarvis'), // TODO: change to conv name or date
      actions: [
        IconButton(
          onPressed: () => widget.addChat(_titleC.text),
          icon: const Icon(Icons.add),
        ),
        // TODO: make the sync work widget.rO.sO.isSyncing.v ? const CircularProgressIndicator() :
        IconButton(
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
