import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: SizedBox(
          child: title(),
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
}
