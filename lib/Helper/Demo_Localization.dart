import 'dart:convert';

import 'package:flutter/services.dart';

import 'Session.dart';
import 'String.dart';

//change language and convert string
class DemoLocalization {
  static Map<String, String>? _localizedValues;
  static String? jsonStringValues;

  static loadValue() async {
    String? code = await getPrefrence(LANGUAGE_CODE);
    if (code == null) {
      defaultLoadValue();
    } else {
      jsonStringValues = await getPrefrence(code);
      Map<String, dynamic> mappedJson = json.decode(jsonStringValues!);
      _localizedValues =
          mappedJson.map((key, value) => MapEntry(key, value.toString()));
    }
  }

  static String? translate(String key) {
    loadValue();
    if (_localizedValues != null) {
      if (_localizedValues![key] == null) {
        defaultLoadValue();
        return _localizedValues![key];
      } else {
        return _localizedValues![key];
      }
    }
  }

  static defaultLoadValue() async {
    jsonStringValues = await rootBundle.loadString('lib/Language/en.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues!);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }
}
