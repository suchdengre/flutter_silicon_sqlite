
import 'dart:convert';

import 'package:flutter_silicon_app/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String key = 'user_data';

  static Future<void> saveUserDataLocally(Info user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentData = prefs.getStringList(key) ?? [];

    // Convert user data to JSON and add to the list
    currentData.add(json.encode(user.toMap()));

    // Save the updated list
    prefs.setStringList(key, currentData);
  }

  static Future<List<Info>> getAllUserDataLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonDataList = prefs.getStringList(key) ?? [];

    // Convert JSON data back to UserData objects
    List<Info> userDataList =
    jsonDataList.map((jsonString) => Info.fromMap(json.decode(jsonString))).toList();

    return userDataList;
  }

  static Future<int> countUserDataLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonDataList = prefs.getStringList(key) ?? [];

    // Return the count of stored user data entries
    return jsonDataList.length;
  }
}