import 'package:flutter/material.dart';
import 'package:jarvis_1/models/message_model.dart';
import '/firestore/firestore_methods.dart';

import '/utils.dart';

class ChatM {
  static Future displayDialog(
      BuildContext context, TextEditingController titleC, SyncObj sO) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a task'),
        content: TextField(
          controller: titleC,
          decoration: const InputDecoration(hintText: 'Type your task'),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            addChat(titleC.text, sO);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              addChat(titleC.text, sO);
              titleC.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future addChat(String chatName, SyncObj sO) async {
    await syncFun(sO, () async => await FirestoreM.addChat(chatName));
  }

  static Future removeChat(String chatName, SyncObj sO) async {
    await syncFun(sO, () async => await FirestoreM.removeChat(chatName));
  }

  static Future sendMessage(
      Message message, String chatName, SyncObj sO) async {
    await syncFun(
      sO,
      () async => await FirestoreM.sendMessage(message, chatName),
    );
  }
}

Future<void> syncFun(SyncObj sO, Function callback) async {
  sO.setState(() {
    sO.isSyncing.v = true;
  });
  await callback();
  sO.setState(() {
    sO.isSyncing.v = false;
  });
}
