import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/models/location_model.dart';
import 'package:voice_assistant/pages/settings.dart';
import 'package:voice_assistant/helper/globals.dart' as globals;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> getAnswer(String text) async {
  globals.debugText = globals.debugText + " Determine Position|";
  Position position = await determinePosition().timeout(Duration(seconds: 10));
  globals.debugText = globals.debugText + " Building URL|";
  // set up POST request arguments
  String url = 'https://idpa-303108.ew.r.appspot.com/API/answer';
  if (kIsWeb) {
    url = "https://tools.k26.ch/cors/proxy.php?csurl=" +
        url; // Benutze den HTTP Proxy für die Webseite --> Sonst gibt es CORS Probleme
  }
  //String url = 'http://127.0.0.1:5000/API/answer';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json =
      '{"question": "$text", "properties": {  "location": {    "longitude": ' +
          position.longitude.toString() +
          ',     "latitude": ' +
          position.latitude.toString() +
          '}, "schuelernr": "' +
          globals.getSetting("schuelernr") +
          '","name": "' +
          globals.getSetting("name") +
          '"}}';

  globals.debugText = globals.debugText + " Sending Request: '" + json + "' |";
  // make POST request
  var response = await http
      .post(url, headers: headers, body: json)
      .timeout(Duration(seconds: 20));
  // check the status code for the result
  int statusCode = response.statusCode;

  globals.debugText =
      globals.debugText + " Statuscode: " + statusCode.toString() + "|";

  print("--------------");
  print("Status-Code: $statusCode");

  if (statusCode != 200) {
    print("--------------");
    return "Keine Verbindung zum Server. Statuscode: " + statusCode.toString();
  }

  // this API passes back the id of the new item added to the body
  final body = jsonDecode(response.body);

  print("Body: " + body['answer']);
  print("--------------");

  return body['answer'];
}
