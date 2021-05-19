import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_assistant/helper/globals.dart' as globals;

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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xfffbb448), Color(0xffe46b10)],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      onTap: () {
                        print("tab");
                        _displayTextInputDialog(
                            context, "name", "Name ändern", "Name");
                      },
                      title: Text(
                        globals.getSetting("name"),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: CircleAvatar(
                        //TODO: Bild lokal speichern (Copright beachten.)
                        backgroundImage: NetworkImage(
                            "https://www.vzpm.ch/fileadmin/bilder/personen/dummy_person.png"),
                      ),
                      trailing: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.lock_outline,
                          color: Colors.orange,
                        ),
                        title: Text("Passwort ändern"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {},
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: Icon(
                          Icons.person,
                          color: Colors.orange,
                        ),
                        title: Text("Schüler-Nummer ändern"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          _displayTextInputDialog(context, "schuelernr",
                              "Schüler-Nummer ändern", "Schüler-Nummer");
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Einstellungen",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SwitchListTile(
                  activeColor: Colors.orange,
                  contentPadding: const EdgeInsets.all(0),
                  value: globals.getSetting("showDebug") == "true",
                  title: Text("Debug Info zeigen"),
                  onChanged: (val) {
                    setState(() {
                      globals.setSetting("showDebug", val ? "true" : "false");
                    });
                  },
                ),
                const SizedBox(height: 60.0),
                Visibility(
                  child: Column(
                    children: [
                      Text(
                        "Debug Info",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SingleChildScrollView(
                        reverse: true,
                        child: Container(
                          child: Text(
                            globals.debugText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: (globals.getSetting("showDebug") == "true"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
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

  String valueText;

  TextEditingController _textFieldController =
      TextEditingController(text: "Fehler...");
  Future<void> _displayTextInputDialog(
    BuildContext context,
    String setting,
    String title,
    String placeholder,
  ) async {
    valueText = globals.getSetting(setting);
    _textFieldController = TextEditingController(text: valueText);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: placeholder),
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
                    globals.setSetting(setting, valueText);
                    print(setting);
                    print(globals.settings[setting]);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}

showAlertDialog(BuildContext context, String title, String text) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(text),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
