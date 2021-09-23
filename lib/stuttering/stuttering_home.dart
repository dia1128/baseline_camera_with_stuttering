
import 'package:camera_app/stuttering/passage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../camera_navigator.dart';
import '../main.dart';

class HomeNavigation extends StatelessWidget {

  //

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(
        child: Column(
            children: [

              Expanded(
                  flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(top:200,bottom:100),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.teal),
                            onPressed: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReadPassage())
                              );
                            },
                              child: Text("Read Passage")

                    ),
                      ),

              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(bottom:300),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      onPressed: () {

                      },
                    child: Text("Upload Image")

                  ),
                ),
              )
            ]
        ),
      ),
    );
  }
}
