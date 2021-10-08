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
    // return  Scaffold(
    //     appBar: AppBar(
    //       title: Text('GeeksforGeeks'),
    //       backgroundColor: Colors.green,
    //     ),
    //     body: Center(
    //       child: Column(
    //
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           Expanded(
    //             child: Container(
    //               width: 250,
    //               child: Text("Age")
    //             )
    //           ),
    //           Expanded(
    //             flex:1,
    //       child: Container(
    //         width: 250,
    //         child: TextField(
    //           decoration: InputDecoration(
    //             hintText: 'Enter Something',
    //             focusColor: Colors.green,
    //           ),
    //           controller: fieldText,
    //         ),
    //       ),
    //           ),
    //           Expanded(
    //             flex: 1,
    //                 child: RaisedButton(
    //             onPressed: clearText,
    //             color: Colors.green,
    //             child: Text('Clear'),
    //             textColor: Colors.white,
    //           ),
    //           )
    //
    //
    //
    //         ],
    //       ),
    //     ),
    //   );

    // return SafeArea(
    //   child: Container (
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Container(padding: const EdgeInsets.all(10.0),
    //         //child: progress <1.0? LinearProgressIndicator(value:progress): Container())
    //       ];
    //     )
    //   )



  }
}




