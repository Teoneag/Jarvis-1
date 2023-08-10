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
// TODO Add to jarvis: common actions
// TODO implement abreviation
// TODO solve pb when changing chats while processing
// TODO split HSV in 2
// HSV (isAppSyncing, isRailSYincing, isChatSYcinging, isRailHidden, navIndex, chatNames, onRailChange, onIndexChange, setState)
// Chat (pendingSentences, messages, indent, logIndent)
// make every chat to have a Chat object, that you send to processSentence

class JarvisM {
  static late HSV hSV;
  static late DateTime startTime;
  static Future<void> _processPendingSentenceFromJarvis(
      String pendingSentence, String message, ChatObj cO) async {
    try {
      cO.logIndent.v = 1;
      startTime = DateTime.now();
      late Word? word;

      if (message.contains(' ')) {
        log('Your response contains spaces => looking in mwes', cO);
        word = await FirestoreM.searchWord(message, collectionName: mwesS);
      } else {
        log("Your response doesn't contain spaces => looking in words", cO);
        word = await FirestoreM.searchWord(message);
      }

      if (word == null) {
        log('The word $message does not exist in the database', cO);
        // TODO
      } else {
        if (word.tags.contains(partOfSpeachS)) {
          log('"${word.text}" is a part of speach', cO);
          // TODO don't hard code this
          String pattern = r'What part of speach is "(.+?)"\?';
          Match? match = RegExp(pattern).firstMatch(pendingSentence);
          if (match == null) {
            print("U're not looking for a part of speach");
            // TODO
          } else {
            String wordAsked = match.group(1)!;
            log('Set part of speach of "$wordAsked" to "$message"', cO);
            FirestoreM.setPartOfSpeach(wordAsked, message);
            log('Removing pending sentence', cO);
            cO.pendingSentences.removeLast();
            cO.indent.v--;
            FirestoreM.modifyPendingSentences(
                cO.pendingSentences, hSV.chatName);
            processSentence(null, cO);
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

  static Future<void> processSentence(Message? message, ChatObj cO) async {
    try {
      cO.logIndent.v = 1;
      startTime = DateTime.now();
      if (cO.pendingSentences.isNotEmpty) {
        final pendingSentence =
            cO.messages.where((e) => e.date == cO.pendingSentences.last).first;
        if (!pendingSentence.isMe) {
          log('Processing pending sentence "${pendingSentence.text}" from jarvis, with response "${message!.text}"',
              cO);
          _processPendingSentenceFromJarvis(
              pendingSentence.text, message.text, cO);
          return;
        }
        log('Processing pending sentence "${pendingSentence.text}" from me, with response "${message?.text}"',
            cO);
        message = pendingSentence;
        cO.pendingSentences.removeLast();
        FirestoreM.modifyPendingSentences(cO.pendingSentences, hSV.chatName);
      }

      final lowercaseText = message!.text.trim().toLowerCase();
      final words = lowercaseText.split(' ');
      log('Words to be processed: $words', cO, i: 1);
      List<String> partsOfSpeach = [];
      // TODO: assing numbers to each part of speach so you don't have to compare strings
      for (var text in words) {
        log('Processing word "$text"', cO, i: 1);
        final word = await FirestoreM.searchOrAddWord(text);
        if (word.partOfSpeach != '') {
          log('"$text" found in database', cO, i: -1);
          partsOfSpeach.add(word.partOfSpeach);
          continue;
        }
        log('"$text" not found in database => searching in merriam webster', cO,
            i: 1);
        final data = json.decode(await MWApiM.dictGetJson(text));
        if (data is! List) {
          partsOfSpeach.add('');
          log('The response: Not a list', cO, i: -2);
          continue;
        }
        if (data.isEmpty) {
          partsOfSpeach.add('');
          log('The response: empty list', cO, i: -2);
          continue;
        }
        if (data[0] is! Map) {
          partsOfSpeach.add('');
          log('The response: no maps in list', cO, i: -2);
          continue;
        }
        if (data[0]['fl'] == null) {
          partsOfSpeach.add('');
          log('The response: no fl', cO, i: -2);
          continue;
        }
        log('"$text" found properly => part of speach = "${data[0]['fl']}"', cO,
            i: -2);
        partsOfSpeach.add(data[0]['fl']);
        await FirestoreM.setPartOfSpeach(text, data[0]['fl']);
      }
      cO.logIndent.v--;
      log('Done with all words, now going to each one of them', cO, i: 1);
      String response = '';
      for (int i = 0; i < words.length; i++) {
        response += '${words[i]}: ${partsOfSpeach[i]}\n';
        switch (partsOfSpeach[i]) {
          case '':
            log('"${words[i]}"\'s part of speach is not known => asking', cO);
            // TODO - ineficiency: calculating this again + paralell waiting
            cO.pendingSentences.add(message.date);
            FirestoreM.modifyPendingSentences(
                cO.pendingSentences, hSV.chatName);
            cO.indent.v++;
            final auxResponse = Message(
              'What part of speach is "${words[i]}"?',
              isMe: false,
              indent: cO.indent.v,
            );
            await ChatM.sendMessage(
              auxResponse,
              hSV,
              cO,
            );
            cO.pendingSentences.add(auxResponse.date);
            FirestoreM.modifyPendingSentences(
                cO.pendingSentences, hSV.chatName);
            return;
        }
      }
      log('Done with all words, now sending response', cO);
      print(response);

      await ChatM.sendMessage(
        Message(
          'Response to "${message.text}"\n $response',
          isMe: false,
          indent: cO.indent.v,
        ),
        hSV,
        cO,
      );

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
      print('This is processSentence: $e');
    }
  }

  static void log(String text, ChatObj cO, {int? i}) {
    final timeTaken =
        (DateTime.now().difference(startTime)).toString().substring(5, 10);
    // final string = NumberFormat
    ChatM.sendMessage(
        Message(
          '$timeTaken $text',
          isMe: false,
          indent: -cO.logIndent.v,
        ),
        hSV,
        cO);
    cO.logIndent.v += i ?? 0;
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
