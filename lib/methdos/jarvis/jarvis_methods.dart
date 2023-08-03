import 'dart:async';
import 'dart:convert';

import '/firestore/firestore_methods.dart';
import '/models/word_model.dart';
import '/methdos/chat/chat_methods.dart';
import '/models/message_model.dart';
import '/merriam_webster/m_w_api_methods.dart';

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

class JarvisM {
  static Future<void> processSentence(String sentence, HSV hSV) async {
    try {
      // TODO add delete funcitonality
      // TODO log all the things are done before showing an answer
      // TODO detect what part of speach is each word
      // TODO implement auxiliary questions?
      // TODO implement abreviation
      // TODO add multiple pendng sentences as timestamps
      if (hSV.pendingSentences.isNotEmpty) {
        // print('response is waited');
        // final word = await FirestoreM.searchWord(sentence);
        // if (word == null) {
        //   // TODO ask if this is a part of speach
        // } else {
        //   if (word.partOfSpeach == partOfSpeachS) {
        //     // TODO set the part of speach of the pendinsentence to this
        //   } else {
        //     // TODO say that you need the part of speach of ... and you can answer with ...
        //   }
        // }
        // // TODO check if it's a part of speach
        // // switch (sentence) {
        // //   case 'v':
        // //     await FirestoreM.setPartOfSpeach(hSV.messages[1].text, verbS);
        // //     // TODO send message like this is saved as this
        // //     break;
        // // }
        // sentence = hSV.pendingSentences.v!;
      }
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
        word.partOfSpeach = oovWordS;
        if (data[0]['fl'] == null) {
          partsOfSpeach.add(oovWordS);
          // print('no fl');
          continue;
        }
        partsOfSpeach.add(data[0]['fl']);
        await FirestoreM.setPartOfSpeach(text, data[0]['fl']);
      }
      String response = '';
      for (int i = 0; i < words.length; i++) {
        response += '${words[i]}: ${partsOfSpeach[i]}\n';
        if (partsOfSpeach[i] == oovWordS) {
          hSV.pendingSentences.add(hSV.messages[0].date);
          final message = Message(
            text: 'What part of speach is the follwoing word?',
            isAux: true,
            isMe: false,
          );
          await ChatM.sendMessage(message, hSV);
          final message2 = Message(
            text: words[i],
            isAux: true,
            isMe: false,
          );
          await ChatM.sendMessage(message2, hSV);
          return;
        }
      }
      // TODO set pendingSentence to null if everything goes smoothly
      print(response);
      await ChatM.sendMessage(Message(text: response, isMe: false), hSV);

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
