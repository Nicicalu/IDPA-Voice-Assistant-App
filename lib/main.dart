import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/services.dart';
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
import 'package:voice_assistant/helper/globals.dart' as globals;
import 'package:catex/catex.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:math_expressions/math_expressions.dart';

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
        '/settings': (context) => SettingsPage(),
        '/help': (context) => HelpPage()
      },
    );
  }
}

class ChatMessage {
  String messageContent;
  String messageType;
  Widget widget;
  ChatMessage({
    @required this.widget,
    @required this.messageContent,
    @required this.messageType,
  });
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
  var tmp = globals.getSettingsInStorage();

  //Text to speech
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    //await flutterTts.setVoice({"name": "de-de-x-nfh-local", "locale": "de-DE"});
    //await flutterTts.setSpeechRate(1);
    await flutterTts.setPitch(1);

    var hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener, debugLogging: true);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      if (null != systemLocale) {
        //_currentLocaleId = systemLocale.localeId;
      } else {
        //_currentLocaleId = 'en_US';
      }
      _currentLocaleId = 'de';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  List<ChatMessage> messages = [
    ChatMessage(
        widget: Text(
          "Hallo, wie kann ich dir helfen?",
          style: TextStyle(fontSize: 15),
        ),
        messageContent: "Hallo, wie kann ich dir helfen?",
        messageType: "receiver"),
  ];

  void newQuestion(String question, {String math = ""}) {
    setState(() {
      /*Map<String, String> replacements = {
        "plus": "+",
        "minus": "-",
        "geteilt durch": "/",
        "mal": "*",
        "klammer auf": "(",
        "klammer zu": ")",
        "klammer": "(",
        "berechne": "",
        "rechne": "",
        "Wieviel ist": "",
        "Wie viel ist": "",
        "Was ist": ""
      };
      replacements.forEach((k, v) {
        question = question.replaceAll(k, v);
      });*/
      if (question.contains(new RegExp(r'[0-9]'))) {
        //math = true;
      }
      if (math != "") {
        print("Match");
        messages.add(
          ChatMessage(
              widget: CaTeX(math),
              messageContent: question,
              messageType: "sender"),
        );
      } else {
        print("No match");
        messages.add(
          ChatMessage(
              widget: Text(question),
              messageContent: question,
              messageType: "sender"),
        );
      }
      loading = true;
      lastWords = "";
    });
    getAnswer(question)
        .then((answer) {
          setState(() {
            var ttsResult = flutterTts.speak(answer.capitalize());
            messages.add(
              ChatMessage(
                  widget: Text(
                    answer.capitalize(),
                    style: TextStyle(fontSize: 15),
                  ),
                  messageContent: answer.capitalize(),
                  messageType: "receiver"),
            );
            loading = false;
          });
        })
        .catchError((e) => print(e))
        .whenComplete(() {});
  }

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
                  Navigator.pushNamed(context, '/help');
                },
                child: Icon(
                  Icons.help,
                  size: 26.0,
                ),
              )),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            reverse: false,
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
                      return InkWell(
                        onTap: () {
                          if (messages[index].messageType == "sender") {
                            newQuestion(messages[index].messageContent);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0, right: 0, top: 10, bottom: 10),
                          child: Align(
                            alignment:
                                (messages[index].messageType == "receiver"
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
                                color:
                                    (messages[index].messageType == "receiver"
                                        ? Colors.orange
                                        : Colors.blue[200]),
                              ),
                              padding: EdgeInsets.all(16),
                              child: messages[index].widget,
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
          Positioned(
            bottom: -20,
            left: -20,
            child: Hero(
              tag: "button2",
              child: Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  gradient: RadialGradient(
                      colors: [Color(0xfffbb448), Color(0xffe46b10)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).backgroundColor.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 00,
            left: 00,
            child: IconButton(
              icon: Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
              onPressed: () {
                mathInput(context);
                //Navigator.pushNamed(context, '/welcome');
              },
            ),
          ),
        ],
      ),
    );
  }

  String finalValue = "";
  Future<void> mathInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Mathematik Formel Eingabe"),
            content: MathField(
              // No parameters are required.
              decoration: const InputDecoration(
                labelText: 'Mathe Formel',
                filled: true,
                border: OutlineInputBorder(),
              ), // Decorate the input field using the familiar InputDecoration.
              onChanged: (String value) {
                finalValue = value;
              }, // Respond to changes in the input field.
              onSubmitted: (String value) {
                finalValue = value;
              }, // Respond to the user submitting their input.
              autofocus:
                  true, // Enable or disable autofocus of the input field.
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Abbrechen'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Speichern'),
                onPressed: () {
                  setState(() {
                    final mathExpression = TeXParser(finalValue).parse();
                    newQuestion(mathExpression.toString(), math: finalValue);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  String translatorvalue = "";
  Future<void> translatorInput(
      BuildContext context, String questionTillNow) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Übersetzer Eingabe"),
            content: TextField(
              // No parameters are required.
              decoration: const InputDecoration(
                labelText: 'Text zu übersetzen',
                filled: true,
                border: OutlineInputBorder(),
              ), // Decorate the input field using the familiar InputDecoration.
              onChanged: (String value) {
                translatorvalue = value;
              }, // Respond to changes in the input field.
              onSubmitted: (String value) {
                translatorvalue = value;
              }, // Respond to the user submitting their input.
              autofocus:
                  true, // Enable or disable autofocus of the input field.
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Übersetzen'),
                onPressed: () {
                  setState(() {
                    newQuestion(questionTillNow + "|" + translatorvalue);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
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
    loading = false;

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
      if (result.recognizedWords.toLowerCase().contains("übersetze")) {
        print("Ja");
        translatorInput(context, result.recognizedWords.capitalize());
      } else {
        print("Nein");
        newQuestion(result.recognizedWords.capitalize());
      }
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
}
