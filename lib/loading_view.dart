/*
  Created By: Nathan Millwater
  Description: The widget tree that makes up the loading view when amplify
               has not finished configuring
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {

  /// Initial build method that displays two images and a wait indicated
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
         child: Column(
             children: [
               Image(image: AssetImage("assets/open_cloud.jpeg")),
               Image(image: AssetImage("assets/camera_app.jpg")),
               SizedBox(height: 100,),
               CircularProgressIndicator(),
             ]
         ),
       ),
    );
  }
}
