import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class SyncManager {
  // static final _prefs = SharedPreferences.getInstance();
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> initApp() async {
    try {
      // TODO check if there was a version of this
    } catch (e) {
      print('This is initApp: $e');
    }
  }

  static Future<void> resetApp() async {
    try {} catch (e) {
      print('This is resetApp: $e');
    }
  }

  static Future<void> startApp() async {
    try {} catch (e) {
      print('This is startApp: $e');
    }
  }

  static Future<void> loadLocally() async {
    try {} catch (e) {
      print('This is loadLocally: $e');
    }
  }

  static Future<void> loadCloud() async {
    try {} catch (e) {
      print('This is loadCloud: $e');
    }
  }

  static Future<void> saveLocally() async {
    try {} catch (e) {
      print('This is saveLocally: $e');
    }
  }

  static Future<void> saveCloud() async {
    try {} catch (e) {
      print('This is saveLocally: $e');
    }
  }

  static Future<void> sync() async {
    try {} catch (e) {
      print('This is saveLocally: $e');
    }
  }
}
