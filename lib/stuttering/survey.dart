
import 'package:camera_app/stuttering/stuttering_home.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show utf8;


class Survey extends StatefulWidget {
  final questions; //to get the list from passage class
  Survey({this.title, this.questions});
  String title = "Survey";



  @override
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  int count = 0;
  var data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Padding(
      //padding: const EdgeInsets.only(top: 40, bottom: 10),
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 4,

              child: Container(
                  padding: const EdgeInsets.only(top:50, left: 25, right: 25),
                  height: 100,
                  child: Align(

                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        widget.questions[count][1].toString(),
                        style: TextStyle(fontSize: 25, color: Colors.blue),
                      ),

                    ),


                  )
              )
          ),

          Expanded(
            flex: 1,
            child: Container(
              margin:  EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * .3),
              child: ElevatedButton(
                style: ButtonStyle(
                  //foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  print("count" + count.toString());
                  print("length"+ widget.questions.length.toString());
                  print(widget.questions[count].toString());
                  if(count< widget.questions.length-1)
                  {

                    setState(() {
                      count = count + 1;
                    });

                  }
                  else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeNavigation()),);
                  }


                },
                child: Text("Next Question"),

              ),
            ),
            // child: Container(
            //   margin: const EdgeInsets.only(bottom: 10),
            //   child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(primary: Colors.green),
            //       onPressed: ()  async {
            //         print("Count "+ count.toString());
            //         //readPassage = new ReadPassage();
            //         //data = await readPassage.downloadProtected();
            //         //data = await downloadProtected() as List;
            //         print("length"+ widget.listVal.length.toString());
            //         print(widget.listVal[count]);
            //         if(count< widget.listVal.length-1){
            //           setState(() {
            //             count = count + 1;
            //           });
            //         }
            //         else {
            //           Navigator.push(
            //               context,
            //               MaterialPageRoute(builder: (context) => HomeNavigation ()));
            //         }
            //
            //       },
            //       child: Text("Next")
            //
            //   ),
            // ),
          ),

        ],
      ),
    );
  }
}



