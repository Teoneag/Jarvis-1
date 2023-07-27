import 'dart:convert';
import 'package:jarvis_1/utils.dart';
import '/merriam_webster/m_w_api_methods.dart';

class JarvisM {
  // static bool isSentenceQuestion(String sentence) {
  //   try {
  //     if (sentence.trim().endsWith('?')) return true;
  //     final lowercaseText = sentence.trim().toLowerCase();
  //     final firstWord = lowercaseText.split(' ')[0];

  //     return auxVerbs.contains(firstWord) || whWords.contains(firstWord);
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  static Future<String> processSentence(String sentence) async {
    try {
      // TODO: detect what part of speach is each word
      final lowercaseText = sentence.trim().toLowerCase();
      final words = lowercaseText.split(' ');
      List<String> partsOfSpeach = [];
      for (var word in words) {
        // print(word);
        final response = await MWApiM.dictGetJson(word);
        final data = json.decode(response);
        if (data is! List) {
          partsOfSpeach.add(unknownS[0]);
          // print('not a list');
          continue;
        }
        if (data.isEmpty) {
          partsOfSpeach.add(unknownS[0]);
          // print('empty list');
          continue;
        }
        if (data[0] is! Map) {
          partsOfSpeach.add(unknownS[0]);
          // print('no maps in list');
          continue;
        }
        if (data[0]['fl'] == null) {
          partsOfSpeach.add(oovWord[0]);
          // print('no fl');
          continue;
        }
        partsOfSpeach.add(data[0]['fl'][0]);
      }
      String response = '';
      for (int i = 0; i < words.length; i++) {
        response += '${words[i]}: ${partsOfSpeach[i]}\n';
      }
      print(response);
      return response;

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
      return '$e';
    }
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
