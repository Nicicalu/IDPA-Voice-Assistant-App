import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/pages/loginPage.dart';
import 'package:voice_assistant/pages/signup.dart';
import 'package:voice_assistant/pages/welcomePage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voice_assistant/models/main_model.dart';
import 'package:voice_assistant/helper/string_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_assistant/pages/settings.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => SpeechScreen(),
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/settings': (context) => SettingsPage()
      },
    );
  }
}

class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({@required this.messageContent, @required this.messageType});
}

class SpeechScreen extends StatefulWidget {
  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  int resultListened = 0;
  String answer;
  bool loading = false;
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  //Text to speech
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener, debugLogging: true);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      if (null != systemLocale) {
        _currentLocaleId = systemLocale.localeId;
      } else {
        _currentLocaleId = 'en_US';
      }
      //_currentLocaleId = 'de';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  List<ChatMessage> messages = [
    ChatMessage(
        messageContent: "Hallo, wie kann ich dir helfen?",
        messageType: "receiver"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: SliverAppBar für Scroll und so
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        automaticallyImplyLeading: false,
        title: SizedBox(
          child: title(),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: Icon(
                  Icons.settings,
                  size: 26.0,
                ),
              )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: speech.isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: Container(
          child: FloatingActionButton(
            heroTag: "button1",
            onPressed: !_hasSpeech || speech.isListening
                ? stopListening
                : startListening,
            child: Container(
              width: 60,
              height: 60,
              child: Icon(speech.isListening ? Icons.mic : Icons.mic_none,
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
          child: Column(
            children: [
              ListView.builder(
                itemCount: messages.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                    child: Align(
                      alignment: (messages[index].messageType == "receiver"
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Container(
                        constraints:
                            BoxConstraints(minWidth: 10, maxWidth: 250),
                        decoration: BoxDecoration(
                          borderRadius:
                              messages[index].messageType == "receiver"
                                  ? BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(15.0),
                                      bottomRight: Radius.circular(10.0),
                                    )
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(15.0),
                                    ),
                          color: (messages[index].messageType == "receiver"
                              ? Colors.orange
                              : Colors.blue[200]),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Text(
                          messages[index].messageContent,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Text(
                lastWords,
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Visibility(
                      child: SpinKitWave(
                        color: Colors.orange,
                        size: 50.0,
                      ),
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: (loading ? true : false),
                    ),
                  )),
              /*DropdownButton(
                onChanged: (selectedVal) => _switchLang(selectedVal),
                value: _currentLocaleId,
                items: _localeNames
                    .map(
                      (localeName) => DropdownMenuItem(
                        value: localeName.localeId,
                        child: Text(localeName.name),
                      ),
                    )
                    .toList(),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Hero(
      tag: "title",
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headline4,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: 'BM ',
                style: TextStyle(color: Color(0xffd95d00), fontSize: 30),
              ),
              TextSpan(
                text: 'Voice ',
                style: TextStyle(fontSize: 30),
              ),
              TextSpan(
                text: 'Assistant',
                style: TextStyle(color: Color(0xffd95d00), fontSize: 30),
              ),
            ]),
      ),
    );
  }

  void startListening() {
    lastWords = '';
    lastError = '';
    flutterTts.stop();
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    ++resultListened;
    print('Result listener $resultListened');
    setState(() {
      lastWords = '${result.recognizedWords}'.capitalize();
    });
    if (result.finalResult) {
      setState(() {
        messages.add(
          ChatMessage(
              messageContent: result.recognizedWords.capitalize(),
              messageType: "sender"),
        );
        loading = true;
        lastWords = "";
      });
      getAnswer(result.recognizedWords.capitalize())
          .then((answer) {
            setState(() {
              var ttsResult = flutterTts.speak(answer.capitalize());
              messages.add(
                ChatMessage(
                    messageContent: answer.capitalize(),
                    messageType: "receiver"),
              );
              loading = false;
            });
          })
          .catchError((e) => print(e))
          .whenComplete(() {});
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    //print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    print(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}
