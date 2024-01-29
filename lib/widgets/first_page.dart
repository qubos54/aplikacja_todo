import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/second_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FirstPageState();
  }
}

class FirstPageState extends State<FirstPage> {
  String savedText = "";
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedText();
    _onTextChanged(savedText);
  }

  void _onTextChanged(String text) {
    setState(() {
      savedText = text;
      if (savedText.length < 3) {
        errorMessage = "Minimalna liczba znakow to 3";
      } else {
        errorMessage = null;
      }
    });
  }

  _onSaveButtonClick() async {
    if (errorMessage == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('savedTextKey', savedText);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return SecondPage();
        },
      ));
    }
  }

  _loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loadedText = prefs.getString('savedTextKey');
    if (loadedText != null && loadedText.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return SecondPage();
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pierwsza strona"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 32, right: 32),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Imie"),
                errorText: errorMessage,
              ),
              onChanged: _onTextChanged,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: OutlinedButton(
              child: Text("Zapisz"),
              onPressed: (errorMessage != null) ? null : _onSaveButtonClick,
            ),
          ),
        ],
      ),
    );
  }
}
