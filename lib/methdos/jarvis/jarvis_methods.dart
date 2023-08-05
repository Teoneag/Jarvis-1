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

// TODO add delete info funcitonality
// TODO log all the things are done before showing an answer
// TODO detect what part of speach is each word
// TODO solve pb when changing chats while processing
// TODO implement abreviation

class JarvisM {
  static Future<void> _processPendingSentenceFromJarvis(
      String pendingSentence, String sentence, HSV hSV) async {
    try {
      late Word? word;

      if (sentence.contains(' ')) {
        print('contains spaces');
        word = await FirestoreM.searchWord(sentence, collectionName: mwesS);
      } else {
        print('does not contain spaces');
        word = await FirestoreM.searchWord(sentence);
      }

      if (word == null) {
        print('The word $sentence does not exist in the database');
        // TODO
      } else {
        if (word.tags.contains(partOfSpeachS)) {
          print('${word.text} is a part of speach');
          // TODO don't hard code this
          String pattern = r'What part of speach is "(.+?)"\?';
          Match? match = RegExp(pattern).firstMatch(pendingSentence);
          if (match == null) {
            print("U're not looking for a part of speach");
            // TODO
          } else {
            String wordAsked = match.group(1)!;
            print('wordAsked: $wordAsked');
            await FirestoreM.setPartOfSpeach(wordAsked, sentence);
            await ChatM.sendMessage(
                Message(
                  text: 'Set part of speach of "$wordAsked" to "$sentence"',
                  isMe: false,
                  isAux: true,
                ),
                hSV);
            hSV.pendingSentences.removeLast();
            await FirestoreM.modifyPendingSentences(hSV);
            await processSentence(null, hSV);
          }
        } else {
          // TODO check for abreviations
          print(
              'say that you need the part of speach of ... and you can answer with ...');
          // TODO say that you need the part of speach of ... and you can answer with ...
        }
      }
    } catch (e) {
      print('this is from _processPendingSentence: $e');
    }
  }

  static Future<void> processSentence(Message? message, HSV hSV) async {
    try {
      if (hSV.pendingSentences.isNotEmpty) {
        print(hSV.pendingSentences);
        final pendingSentence = hSV.messages
            .where((e) => e.date == hSV.pendingSentences.last)
            .first;
        if (!pendingSentence.isMe) {
          print('pending sentence (${pendingSentence.text}) is from jarvis');
          await _processPendingSentenceFromJarvis(
              pendingSentence.text, message!.text, hSV);
          return;
        }
        print('pending sentence(${pendingSentence.text}) is from me');
        message = pendingSentence;
      }
      final lowercaseText = message!.text.trim().toLowerCase();
      final words = lowercaseText.split(' ');
      List<String> partsOfSpeach = [];
      // TODO: assing numbers to each part of speach so you don't have to compare strings
      for (var text in words) {
        // print(word);
        final word = await FirestoreM.searchOrAddWord(text);
        if (word.partOfSpeach != '') {
          partsOfSpeach.add(word.partOfSpeach);
          continue;
        }

        final response = await MWApiM.dictGetJson(text);
        final data = json.decode(response);
        if (data is! List) {
          partsOfSpeach.add('');
          print('not a list');
          continue;
        }
        if (data.isEmpty) {
          partsOfSpeach.add('');
          print('empty list');
          continue;
        }
        if (data[0] is! Map) {
          partsOfSpeach.add('');
          print('no maps in list');
          continue;
        }
        if (data[0]['fl'] == null) {
          partsOfSpeach.add('');
          print('no fl');
          continue;
        }
        partsOfSpeach.add(data[0]['fl']);
        await FirestoreM.setPartOfSpeach(text, data[0]['fl']);
      }

      String response = '';
      for (int i = 0; i < words.length; i++) {
        response += '${words[i]}: ${partsOfSpeach[i]}\n';
        switch (partsOfSpeach[i]) {
          case '':
            // TODO solve the ineficiency of doing basically this function again
            final date = hSV.messages.first.date;
            hSV.pendingSentences.add(date);
            await FirestoreM.modifyPendingSentences(hSV);
            final message = Message(
              text: 'What part of speach is "${words[i]}"?',
              isAux: true,
              isMe: false,
            );
            await ChatM.sendMessage(
              message,
              hSV,
            );
            hSV.pendingSentences.add(message.date);
            await FirestoreM.modifyPendingSentences(hSV);
            return;
        }
      }
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
}

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
