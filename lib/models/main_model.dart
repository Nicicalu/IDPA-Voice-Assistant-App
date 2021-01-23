import 'package:http/http.dart' as http;

void getAnswer(String text) async {
  final response = await http.get('https://idpa.k26.ch/backend.php?text=Hallo');

  print("----1");
  print(response.body);
  print("----2");
}
