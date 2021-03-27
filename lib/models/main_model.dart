import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/models/location_model.dart';
import 'dart:async';
import 'dart:convert';

Future<String> getAnswer(String text) async {
  Position position = await determinePosition();
  // set up POST request arguments
  String url = 'https://idpa-303108.ew.r.appspot.com/API/answer';
  //String url = 'https://192.168.1.125:5000/API/answer';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json =
      '{"auth": "asto1j950h215", "question": "$text", "properties": {  "location": {    "longitude": ' +
          position.longitude.toString() +
          ',     "latitude": ' +
          position.latitude.toString() +
          '}  }}';

  // make POST request
  var response = await http.post(url, headers: headers, body: json);
  // check the status code for the result
  int statusCode = response.statusCode;

  if (statusCode != 200) {
    return "Es konnte keine Verbindung zum Server hergestellt werden. Bitte stelle sicher, dass eine Internetverbindung besteht.";
  }

  // this API passes back the id of the new item added to the body
  final body = jsonDecode(response.body);

  print("--------------");
  print("Status-Code: $statusCode");
  print("Body: " + body['answer']);
  print("--------------");

  return body['answer'];
}
