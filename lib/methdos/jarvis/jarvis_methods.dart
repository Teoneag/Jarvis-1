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
      String pendingSentence, String message) async {
    try {
      hSV.logIndent.v = 1;
      startTime = DateTime.now();
      late Word? word;

      if (message.contains(' ')) {
        log('Your response contains spaces => looking in mwes');
        word = await FirestoreM.searchWord(message, collectionName: mwesS);
      } else {
        log("Your response doesn't contain spaces => looking in words");
        word = await FirestoreM.searchWord(message);
      }

      if (word == null) {
        log('The word $message does not exist in the database');
        // TODO
      } else {
        if (word.tags.contains(partOfSpeachS)) {
          log('"${word.text}" is a part of speach');
          // TODO don't hard code this
          String pattern = r'What part of speach is "(.+?)"\?';
          Match? match = RegExp(pattern).firstMatch(pendingSentence);
          if (match == null) {
            print("U're not looking for a part of speach");
            // TODO
          } else {
            String wordAsked = match.group(1)!;
            log('Set part of speach of "$wordAsked" to "$message"');
            FirestoreM.setPartOfSpeach(wordAsked, message);
            log('Removing pending sentence');
            hSV.pendingSentences.removeLast();
            hSV.indent.v--;
            FirestoreM.modifyPendingSentences(hSV);
            processSentence(null);
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

  static Future<void> processSentence(Message? message) async {
    try {
      hSV.logIndent.v = 1;
      startTime = DateTime.now();
      if (hSV.pendingSentences.isNotEmpty) {
        final pendingSentence = hSV.messages
            .where((e) => e.date == hSV.pendingSentences.last)
            .first;
        if (!pendingSentence.isMe) {
          log('Processing pending sentence "${pendingSentence.text}" from jarvis, with response "${message!.text}"');
          _processPendingSentenceFromJarvis(pendingSentence.text, message.text);
          return;
        }
        log('Processing pending sentence "${pendingSentence.text}" from me, with response "${message?.text}"');
        message = pendingSentence;
        hSV.pendingSentences.removeLast();
        FirestoreM.modifyPendingSentences(hSV);
      }

      final lowercaseText = message!.text.trim().toLowerCase();
      final words = lowercaseText.split(' ');
      log('Words to be processed: $words', i: 1);
      List<String> partsOfSpeach = [];
      // TODO: assing numbers to each part of speach so you don't have to compare strings
      for (var text in words) {
        log('Processing word "$text"', i: 1);
        final word = await FirestoreM.searchOrAddWord(text);
        if (word.partOfSpeach != '') {
          log('"$text" found in database', i: -1);
          partsOfSpeach.add(word.partOfSpeach);
          continue;
        }
        log('"$text" not found in database => searching in merriam webster',
            i: 1);
        final data = json.decode(await MWApiM.dictGetJson(text));
        if (data is! List) {
          partsOfSpeach.add('');
          log('The response: Not a list', i: -2);
          continue;
        }
        if (data.isEmpty) {
          partsOfSpeach.add('');
          log('The response: empty list', i: -2);
          continue;
        }
        if (data[0] is! Map) {
          partsOfSpeach.add('');
          log('The response: no maps in list', i: -2);
          continue;
        }
        if (data[0]['fl'] == null) {
          partsOfSpeach.add('');
          log('The response: no fl', i: -2);
          continue;
        }
        log('"$text" found properly => part of speach = "${data[0]['fl']}"',
            i: -2);
        partsOfSpeach.add(data[0]['fl']);
        await FirestoreM.setPartOfSpeach(text, data[0]['fl']);
      }
      hSV.logIndent.v--;
      log('Done with all words, now going to each one of them', i: 1);
      String response = '';
      for (int i = 0; i < words.length; i++) {
        response += '${words[i]}: ${partsOfSpeach[i]}\n';
        switch (partsOfSpeach[i]) {
          case '':
            log('"${words[i]}"\'s part of speach is not known => asking');
            // TODO - ineficiency: calculating this again + paralell waiting
            hSV.pendingSentences.add(message.date);
            FirestoreM.modifyPendingSentences(hSV);
            hSV.indent.v++;
            final auxResponse = Message(
              'What part of speach is "${words[i]}"?',
              isMe: false,
              indent: hSV.indent.v,
            );
            await ChatM.sendMessage(
              auxResponse,
              hSV,
            );
            hSV.pendingSentences.add(auxResponse.date);
            FirestoreM.modifyPendingSentences(hSV);
            return;
        }
      }
      log('Done with all words, now sending response');
      print(response);

      await ChatM.sendMessage(
          Message(
            'Response to "${message.text}"\n $response',
            isMe: false,
            indent: hSV.indent.v,
          ),
          hSV);

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

  static void log(String text, {int? i}) {
    final timeTaken =
        (DateTime.now().difference(startTime)).toString().substring(5, 10);
    // final string = NumberFormat
    ChatM.sendMessage(
        Message(
          '$timeTaken $text',
          isMe: false,
          indent: -hSV.logIndent.v,
        ),
        hSV);
    hSV.logIndent.v += i ?? 0;
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
