import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_assistant/pages/welcomePage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voice_assistant/models/main_model.dart';
import 'package:voice_assistant/helper/string_extension.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        backgroundColor: const Color(0xFFE5E5E5),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: const Color(0xFF212121),
      ),
      themeMode: ThemeMode.system,
      home: WelcomePage(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText speech;
  bool isListening = false;
  String text = 'Knopf drücken und reden...';
  double confidence = 1.0;

  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: SizedBox(
          child: title(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: Container(
          child: FloatingActionButton(
            onPressed: listen,
            child: Container(
              width: 60,
              height: 60,
              child: Icon(isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xfffbb448), Color(0xffe46b10)]),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void listen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == "notListening") {
            print("Finaler Text: $text");
            var result = flutterTts.speak(text);
            getAnswer(text);
            setState(() {
              print("SetState mit isListening = false");
              isListening = false;
            });
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) => setState(() {
            text = val.recognizedWords;
            text = text.capitalize();
            if (val.hasConfidenceRating && val.confidence > 0) {
              confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  Widget title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'BM',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: 'Voice',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'Assistant',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }
}
