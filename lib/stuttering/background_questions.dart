import 'package:flutter/material.dart';

class SurveyNew extends StatefulWidget {


  @override
  _SurveyNewState createState() => _SurveyNewState();
}

class _SurveyNewState extends State<SurveyNew> {
  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GeeksforGeeks'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  width: 250,
                  child: Text("Age")
                )
              ),
              Expanded(
                flex:1,
          child: Container(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Something',
                focusColor: Colors.green,
              ),
              controller: fieldText,
            ),
          ),
              ),
              Expanded(
                flex: 1,
                    child: RaisedButton(
                onPressed: clearText,
                color: Colors.green,
                child: Text('Clear'),
                textColor: Colors.white,
              ),
              )



            ],
          ),
        ),
      ),
    );
  }
}




