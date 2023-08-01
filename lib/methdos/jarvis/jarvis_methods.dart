import 'dart:async';
import 'dart:convert';

import '/firestore/firestore_methods.dart';
import '/models/word_model.dart';
import '/methdos/chat/chat_methods.dart';
import '/models/message_model.dart';
import '/merriam_webster/m_w_api_methods.dart';

class JarvisM {
  static Future<void> processSentence(
      String sentence, String chatName, ChatObj cO) async {
    try {
      /*
      i am teo
        What is am?
        v
        
        What is teo?
        name
      Ok, user name set to "teo"
      
      i have a question
      processing
        i get a question
        i answer
      i get an answer

      */
      // TODO log all the things are done before showing an answer
      // TODO detect what part of speach is each word
      // TODO implement auxiliary questions?
      // TODO implement bing api
      final lowercaseText = sentence.trim().toLowerCase();
      final words = lowercaseText.split(' ');
      List<String> partsOfSpeach = [];
      // TODO: assing numbers to each part of speach so you don't have to compare strings
      for (var text in words) {
        // print(word);
        final word = await FirestoreM.searchOrAddWord(text);
        if (word.partOfSpeach != unknownS) {
          partsOfSpeach.add(word.partOfSpeach);
          continue;
        }

        final response = await MWApiM.dictGetJson(text);
        final data = json.decode(response);
        if (data is! List) {
          partsOfSpeach.add(unknownS);
          // print('not a list');
          continue;
        }
        if (data.isEmpty) {
          partsOfSpeach.add(unknownS);
          // print('empty list');
          continue;
        }
        if (data[0] is! Map) {
          partsOfSpeach.add(unknownS);
          // print('no maps in list');
          continue;
        }
        word.partOfSpeach = oovWord;
        if (data[0]['fl'] == null) {
          partsOfSpeach.add(oovWord);
          // print('no fl');
          continue;
        }
        partsOfSpeach.add(data[0]['fl']);
        await FirestoreM.setPartOfSpeach(text, data[0]['fl']);
      }
      String response = '';
      for (int i = 0; i < words.length; i++) {
        response += '${words[i]}: ${partsOfSpeach[i]}\n';
        //   if (partsOfSpeach[i] == oovWord) {
        //     final message = Message(
        //       text: 'What part of speach is ${words[i]}?',
        //       isAux: true,
        //       isMe: false,
        //     );
        //     await ChatM.sendMessage(message, chatName, cO);
        //   }
      }
      print(response);
      await ChatM.sendMessage(
          Message(text: response, isMe: false), chatName, cO);

      // TODO: split in parts execute every part
      // if (isSentenceQuestion(sentence)) {
      //   // handle question
      //   return;
      // }

      // handle statement: I am teo. Who am I?
      // split it in parts
      // detect verbs

      // TODO: at the end say smth like ok
    } catch (e) {
      print(e);
    }
  }

  static Future<String> askQuestion(String question) async {
    // final completer = Completer<String>();
    return '';
  }
}

// List<String> auxVerbs = modalVerbs + auxiliaryVerbs + semiModalAuxVerbs;

// List<String> modalVerbs = [
//   "can",
//   "could",
//   "may",
//   "might",
//   "will",
//   "would",
//   "shall",
//   "should",
//   "do",
//   "does",
//   "did",
//   "have",
//   "has",
//   "had",
// ];

// List<String> auxiliaryVerbs = [
//   "be",
//   "am",
//   "is",
//   "are",
//   "was",
//   "were",
// ];

// List<String> semiModalAuxVerbs = [
//   "ought",
//   "need",
//   "dare",
//   "used",
// ];

// List<String> whWords = [
//   "what",
//   "when",
//   "where",
//   "which",
//   "who",
//   "whom",
//   "whose",
//   "why",
//   "how",
// ];
