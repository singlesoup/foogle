import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'models/answers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foogle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // for search text field
  var _controller = TextEditingController();

  // for making the icon to clear visible
  bool _visible = false;

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Answer _currentAnswer;

  // process of getting the ansers
  void handleGetAnswer() async {
    String questionText = _controller.text?.trim();
    if (questionText == null ||
        questionText.length == 0 ||
        questionText[questionText.length - 1] != "?") {
      final snack = SnackBar(
        key: _key,
        content:
            Text('🤪 Not a question!!  Ask your question ending with a "?"'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
      return;
    }
    try {
      http.Response response = await http.get('https://yesno.wtf/api');
      // print(response.statusCode); if its 200 then its ok
      if (response.statusCode == 200 && response.body != null) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        Answer answer = Answer.fromMap(responseBody);
        setState(() {
          _currentAnswer = answer;
        });
      }
    } catch (err, stacktrace) {
      print('error - $err');
      print('stacktrace- $stacktrace');
    }
  }

  _launchFormURL() async {
    const formUrl = 'https://forms.gle/ix8FjZ2sFL3MiEMp6';
    if (await canLaunch(formUrl)) {
      await launch(formUrl);
    } else {
      throw 'Could not launch $formUrl';
    }
  }

  _launchGithubURL() async {
    const ghUrl = 'https://github.com/singlesoup/foogle';
    if (await canLaunch(ghUrl)) {
      await launch(ghUrl);
    } else {
      throw 'Could not launch $ghUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      key: _key,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: mediaQuery.size.height * 0.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Foogle',
              child: Container(
                height: mediaQuery.size.height * 0.3,
                width: mediaQuery.size.width * 0.3,
                decoration: BoxDecoration(
                  // color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    // image: AssetImage('images/foogle.png'),
                    image: NetworkImage(
                        'https://drive.google.com/uc?export=view&id=1NdYYgQhJWBtVCaLd3yc0SUJ11lPxk4ID'),
                  ),
                ),
              ),
            ),
            Tooltip(
              message: 'search',
              child: Container(
                width: mediaQuery.size.width * 0.5,
                child: TextField(
                  onTap: () {
                    setState(() {
                      _visible = true;
                    });
                  },
                  controller: _controller,
                  cursorColor: Colors.grey[400],
                  decoration: InputDecoration(
                      suffixIcon: Visibility(
                        visible: _visible,
                        child: GestureDetector(
                          onTap: () => _controller.clear(),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.grey[400],
                        ),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.grey[400],
                        ),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      hintText: "Ask your question",
                      fillColor: Colors.white70),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if (_currentAnswer != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _currentAnswer.answer,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: mediaQuery.size.width * 0.02,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: mediaQuery.size.height * 0.3,
                    width: mediaQuery.size.width * 0.4,
                    decoration: BoxDecoration(
                        //color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          //fit: BoxFit.cover,
                          image: NetworkImage(_currentAnswer.image),
                        )),
                  ),
                ],
              ),
            if (_currentAnswer != null)
              SizedBox(
                height: 20,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  color: Colors.white,
                  onPressed: handleGetAnswer,
                  child: Text('Foogle search'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(6),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                RaisedButton(
                  color: Colors.white,
                  onPressed: reset,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(6),
                  ),
                  child: Text('Another Question'),

                  /// this will make it dark mode when presed again it will show light mode
                ),
              ],
            ),
            SizedBox(
              height: 200,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.bolt),
                FlatButton(
                  color: Colors.white,
                  onPressed: _launchGithubURL,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(6),
                  ),
                  child: Text(
                    'Github',
                    style: TextStyle(color: Colors.indigo[800]),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                FlatButton(
                  color: Colors.white,
                  onPressed: _launchFormURL,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(6),
                  ),
                  child: Text(
                    'Wanna Try a new App?',
                    style: TextStyle(color: Colors.indigo[800]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      _currentAnswer = null;
      _controller.clear();
    });
  }
}
