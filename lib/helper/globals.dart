import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map settings = {"auth": "", "schuelernr": "", "language": ""};

var tmp;
var tmp2 = getSettingsInStorage();

String getSetting(String setting) {
  return settings[setting];
}

setSetting(String setting, var value) {
  settings[setting] = value;
  tmp = setSettingsInStorage();
}

Future<void> getSettingsInStorage() async {
  final prefs = await SharedPreferences.getInstance();

  dynamic value;
  settings.forEach((k, v) {
    value = prefs.getString(k);
    settings[k] = (value == null) ? "" : value;
    print("Get: " + k + ": " + v);
  });
}

Future<void> setSettingsInStorage() async {
  final prefs = await SharedPreferences.getInstance();

  dynamic value;
  settings.forEach((k, v) {
    value = prefs.setString(k, v);
    print("Set: " + k + ": " + v);
  });
}
