import 'package:http/http.dart' as http;
import '/merriam_webster/m_w_api_key.dart';

const baseUrl = 'https://dictionaryapi.com/api/v3/references/';
const learners = 'learners';
const learnersUrl = '$baseUrl$learners/json/';

class MWApiM {
  static Future<String> getJson(String word) async {
    try {
      final urlString = '$learnersUrl$word?key=$mWLearnerApiKey';
      // print(urlString);
      final url = Uri.parse(urlString);
      final response = await http.get(url);
      return response.body;
    } catch (e) {
      print(e);
      return '$e';
    }
  }
}
