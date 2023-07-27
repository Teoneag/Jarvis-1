import 'package:http/http.dart' as http;
import '/merriam_webster/m_w_api_key.dart';

const baseUrl = 'https://dictionaryapi.com/api/v3/references/';
const learners = 'learners';
const dictionary = 'collegiate';

class MWApiM {
  static Future<String> learnersGetJson(String word) async {
    return getJson(word, true);
  }

  static Future<String> dictGetJson(String word) async {
    return getJson(word, false);
  }

  static Future<String> getJson(String word, bool isLearner) {
    try {
      final urlString =
          '$baseUrl${isLearner ? learners : dictionary}/json/$word'
          '?key=${isLearner ? mWLearnerApiKey : mWDictApiKey}';
      // print(urlString);
      final url = Uri.parse(urlString);
      return http.get(url).then((response) => response.body);
    } catch (e) {
      print(e);
      return Future.value('$e');
    }
  }
}
