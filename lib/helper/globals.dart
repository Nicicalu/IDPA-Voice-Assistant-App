import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String debugText = "";
int counter = 0;

Map settings = {
  "name": "Max Mustermann",
  "schuelernr": "",
  "showDebug": "false"
};

var tmp;

String getSetting(String setting) {
  return settings[setting];
}

setSetting(String setting, var value) {
  settings[setting] = value;
  tmp = setSettingsInStorage();
}

Future<void> getSettingsInStorage() async {
  print("---------------- Get Settings in Storage ----------------");
  final prefs = await SharedPreferences.getInstance();

  var value;
  settings.forEach((k, v) {
    value = prefs.getString(k);
    settings[k] = (value == null) ? settings[k] : value;
    print("Get: " + k + ": " + settings[k]);
  });
}

var tmp2 = getSettingsInStorage();

Future<void> setSettingsInStorage() async {
  print("---------------- Set Settings in Storage ----------------");
  final prefs = await SharedPreferences.getInstance();

  dynamic value;
  settings.forEach((k, v) {
    value = prefs.setString(k, v);
    print("Set: " + k + ": " + v);
  });
}
