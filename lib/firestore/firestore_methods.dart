import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/word_model.dart';
import '/models/message_model.dart';
import '/utils.dart';

const chatsS = 'chats';
const messagesS = 'messages';
const generalS = 'general';
const chatNamesS = 'chatNames';
const wordsS = 'words';
const pendingSentenceS = 'pendingSentence';

class FirestoreM {
  static final firestore = FirebaseFirestore.instance;

  static Future<String> setPartOfSpeach(
      String word, String partOfSpeach) async {
    try {
      await firestore.collection(wordsS).doc(word).update({
        partOfSpeachS: partOfSpeach,
      });
      return successS;
    } catch (e) {
      print('this is setPartOfSpeach: $e');
      return '$e';
    }
  }

  static Future<Word?> searchWord(String text) async {
    try {
      final snap = await firestore.collection(wordsS).doc(text).get();
      if (snap.exists) {
        return Word.fromJson(snap.data()!);
      }
      return null;
    } catch (e) {
      print('this is searchWord: $e');
      return null;
    }
  }

  static Future<Word> searchOrAddWord(String text) async {
    try {
      final snap = await firestore.collection(wordsS).doc(text).get();
      if (snap.exists) {
        return Word.fromJson(snap.data()!);
      }
      final word = Word(text);
      await firestore.collection(wordsS).doc(text).set(word.toJson());
      return word;
    } catch (e) {
      print('this is searchOrAddWord: $e');
      return Word('$e');
    }
  }

  static Future<String> addChat(String chatName) async {
    try {
      await firestore.collection(generalS).doc(chatsS).update({
        chatNamesS: FieldValue.arrayUnion([chatName])
      });
      await firestore.collection(chatsS).doc(chatName).set({
        pendingSentenceS: [],
      });
      return successS;
    } catch (e) {
      if (e.toString() ==
          'FirebaseError: [code=not-found]: No document to update: projects/jarvis-tn-1/databases/(default)/documents/general/chats') {
        await firestore.collection(generalS).doc(chatsS).set({
          chatNamesS: [chatName]
        });
        return successS;
      }
      print('this is addChat: $e');
      return '$e';
    }
  }

  static Future<DocumentSnapshot> loadChatNames() async {
    try {
      return await firestore.collection(generalS).doc(chatsS).get();
    } catch (e) {
      print('this is loadChatNames: $e');
      throw Error();
    }
  }

  static Future<QuerySnapshot> loadMessages(chatName) async {
    try {
      return await firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .get();
    } catch (e) {
      print('this is loadMessages: $e');
      throw Error();
    }
  }

  static Future<QuerySnapshot> loadMessagesByTimestamp(chatName) async {
    try {
      return await firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .orderBy(dateS, descending: true)
          .get();
    } catch (e) {
      print('this is loadMessagesByTimestamp: $e');
      throw Error();
    }
  }

  static Future<DocumentSnapshot> loadChat(chatName) async {
    try {
      return await firestore.collection(chatsS).doc(chatName).get();
    } catch (e) {
      print('this is loadChat: $e');
      throw Error();
    }
  }

  // TODO: when there are to many messages to be loaded, load them in batches

  static Future<String> removeChat(String chatName) async {
    try {
      await firestore.collection(generalS).doc(chatsS).update({
        chatNamesS: FieldValue.arrayRemove([chatName])
      });

      final snap = await firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .get();

      await Future.wait(snap.docs.map((doc) => doc.reference.delete()));
      await firestore.collection(chatsS).doc(chatName).delete();
      return successS;
    } catch (e) {
      print('this is removeChat: $e');
      return '$e';
    }
  }

  static Future<String> sendMessage(Message message, String chatName) async {
    try {
      await firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .doc(message.uid)
          .set(message.toJson());
      return successS;
    } catch (e) {
      print('this is sendMessage: $e');
      return '$e';
    }
  }
}
