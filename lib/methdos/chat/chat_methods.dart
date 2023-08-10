import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/methdos/jarvis/jarvis_methods.dart';
import '/models/message_model.dart';
import '/firestore/firestore_methods.dart';
import '/utils.dart';

// TODO if 2 chats have the same name

class ChatM {
  static Future addDialog(BuildContext context, TextEditingController titleC,
      HSV hSV, List<ChatObj> cOList) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a chat'),
        content: TextField(
          controller: titleC,
          decoration: const InputDecoration(hintText: 'Type your chat name'),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _addChat(titleC.text, hSV, cOList);
            titleC.clear();
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
              _addChat(titleC.text, hSV, cOList);
              titleC.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future _addChat(String chatName, HSV hSV, List<ChatObj> cOList) async {
    hSV.chatNames.add(chatName);
    hSV.onIndexChange(hSV.chatNames.length - 1);
    cOList[hSV.chatNames.length - 1].indent.v = 0;
    await FirestoreM.addChat(chatName);
  }

  static Future removeDialog(
    HSV hSV,
    BuildContext context,
    int removeI,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove a task'),
        content:
            Text('Are you sure you want to remove ${hSV.chatNames[removeI]}?'),
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
              _removeChat(hSV, removeI);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  static Future _removeChat(
    HSV hSV,
    int removeI,
  ) async {
    try {
      final chatName = hSV.chatNames[removeI];
      hSV.setState(() {
        hSV.chatNames.removeAt(removeI);
      });
      if (hSV.chatNames.isNotEmpty) {
        if (removeI == hSV.navIndex.v) {
          int newI = hSV.navIndex.v - 1;
          if (newI < 0) newI = 0;
          hSV.onIndexChange(newI);
        } else if (removeI < hSV.navIndex.v) {
          hSV.onIndexChange(hSV.navIndex.v - 1);
        }
      }
      await FirestoreM.removeChat(chatName);
    } catch (e) {
      print(e);
    }
  }

  // static Future loadChatNamesAndChat(HSV hSV, ChatObj cO) async {
  //   await loadChatNames(hSV);
  //   if (hSV.chatNames.isNotEmpty) {
  //     hSV.navIndex.v = 0;
  //     await loadMessages(hSV, cO);
  //   }
  // }

  static Future laodChatNamesAndChatList(HSV hSV, List<ChatObj> cOList) async {
    await loadChatNames(hSV);
    cOList.clear();
    if (hSV.chatNames.isNotEmpty) {
      hSV.navIndex.v = 0;
      for (int i = 0; i < hSV.chatNames.length; i++) {
        cOList.add(ChatObj([], [], IntW(0), IntW(0)));
        await loadMessages(hSV, cOList[i]);
      }
    }
  }

  static Future loadChatNames(HSV hSV) async {
    await syncFun(SyncObj(hSV.setState, hSV.isRailSyncing), () async {
      try {
        final snap = await FirestoreM.loadChatNames();
        hSV.chatNames.clear();
        hSV.chatNames
            .addAll((snap[chatNamesS] as List<dynamic>).cast<String>());
      } catch (e) {
        print('This is loadChatNames: $e');
      }
    });
  }

  static Future loadMessages(HSV hSV, ChatObj cO) async {
    await syncFun(SyncObj(hSV.setState, hSV.isChatSyncing), () async {
      try {
        final snap = await FirestoreM.loadMessagesByTimestamp(hSV.chatName);
        cO.messages.clear();
        cO.messages.addAll(snap.docs
            .map((doc) =>
                Message.fromSnap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());

        final snap2 = await FirestoreM.loadChat(hSV.chatName);
        cO.pendingSentences.clear();
        cO.pendingSentences.addAll(List<DateTime>.from((snap2[pendingSentenceS])
            .map((timestamp) => (timestamp).toDate())));
      } catch (e) {
        print('This is loadMessages: $e');
      }
    });
  }

  static Future sendMessageMe(
      HSV hSV, ChatObj cO, TextEditingController textC) async {
    syncFun(SyncObj(hSV.setState, hSV.isAppSyncing), () async {
      try {
        final text = textC.text.trim();
        if (text.isEmpty) return;
        textC.clear();
        Message message = Message(text, indent: cO.indent.v);
        await sendMessage(message, hSV, cO);
        await JarvisM.processSentence(message, cO);
      } catch (e) {
        print(e);
      }
    });
  }

  static Future sendMessage(Message message, HSV hSV, ChatObj cO) async {
    try {
      cO.messages.insert(0, message);
      hSV.setState(() {});
      FirestoreM.sendMessage(message, hSV.chatName);
      // print(JarvisM.isSentenceQuestion(textC.text));
    } catch (e) {
      print(e);
    }
  }

  static void handleKeyPress(
    RawKeyEvent event,
    IntW i,
    TextEditingController c,
    List<Message> messages,
  ) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      i.v++;
      if (i.v >= messages.length) i.v = messages.length - 1;
      c.text = messages[i.v].text;
    } else if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      i.v--;
      if (i.v < -1) i.v = -1;
      if (i.v == -1) {
        c.clear();
      } else {
        c.text = messages[i.v].text;
      }
    }
  }

  static Future<String> resetJarvis(
      BuildContext context, HSV hSV, List<ChatObj> cOList) async {
    try {
      // TODO show loading while reseting
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset jarvis'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirestoreM.resetJarvis();
                laodChatNamesAndChatList(hSV, cOList);
                Navigator.of(context).pop();
              },
              child: const Text('Reset jarvis'),
            ),
          ],
        ),
      );
      return successS;
    } catch (e) {
      print('this is resetJarvis: $e');
      return '$e';
    }
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

class HSV {
  final BoolW isAppSyncing;
  final BoolW isRailSyncing;
  final BoolW isChatSyncing;
  final BoolW isRailHidden;
  final IntW navIndex;
  final List<String> chatNames;
  final void Function(int) onIndexChange;
  final void Function() onRailChange;
  final StateSetter setState;

  HSV(
    this.isAppSyncing,
    this.isRailSyncing,
    this.isChatSyncing,
    this.isRailHidden,
    this.navIndex,
    this.chatNames,
    this.onIndexChange,
    this.onRailChange,
    this.setState,
  );

  String get chatName => chatNames[navIndex.v];
}

class ChatObj {
  final List<DateTime> pendingSentences;
  final List<Message> messages;
  final IntW indent;
  final IntW logIndent;

  ChatObj(
    this.pendingSentences,
    this.messages,
    this.indent,
    this.logIndent,
  );
}
