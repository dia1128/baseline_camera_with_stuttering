import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/camera_view_build.dart';
import 'package:camera_app/stuttering/stuttering_home.dart';
import 'package:camera_app/stuttering/survey.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../main.dart';
import 'dart:convert' show utf8;
import 'package:csv/csv.dart';

class Survey extends StatefulWidget {
  final questions;
  final id;//to get the list from passage class
  Survey({this.title, this.questions, this.id});
  String title = "Survey";


  @override
  _SurveyState createState() => _SurveyState();
}




class _SurveyState extends State<Survey> {

  int count = 0;
  var data;
  CameraController controller;
  String filePath;
  String uploadMessage;
  bool enableVideo = false;
  bool okay = false;

  _SurveyState() {

    setupCamera();
  }

  void setupCamera() {
    controller = CameraController(
        cameras[1],
        ResolutionPreset.medium,
        enableAudio: true);

    try {
      controller.initialize();
    } on CameraException catch (e) {
      print(e.toString());
    }
  }


  // checks internet
  /// Checks if the device is connected to the internet by trying
  /// to access a simple domain
  /// Returns: True if the device is connected to the internet, false
  /// otherwise
  Future<bool> isInternetConnected() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    //cameraview widget

    if(okay == true)
    {
      return Scaffold(

        body: Container(
          decoration: BoxDecoration(

              border: Border.all(color: enableVideo == true ? Colors.red: Colors.white, width:4),
              color: Colors.white

          ),
          child: Column(

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


                    ),

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
                    onPressed: () async {
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
                        onStopPressed();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeNavigation()),);
                      }


                    },
                    child: Text("Next Question"),

                  ),
                ),


              ),

            ],
          ),
        ),
      );
    }
    else
    {
      return Scaffold(
          body: Column(

          )
      );
    }

  }

  Future<void> onStartPressed() async {
    // Creates the file path where the video is to be saved
    enableVideo = true;
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    String date = DateTime.now().toIso8601String();
    filePath = '$dirPath/$date.mp4';

    print("Start recording in survey");
    await controller.startVideoRecording(filePath);
    setState(() {});
  }

  /// create the snack bar and display in Scaffold
  /// Parameters: Message to display in snackbar
  void showInSnackBar(String message) {
    SnackBar bar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }



  ///Strops the video and uploaeds file
  Future<void> onStopPressed() async {
    await controller.stopVideoRecording();

    setState(() {});
    String date = DateTime.now().toIso8601String().substring(0, 19);
    print("Recording stopped in Survey");

    // try {
    //   final result = await Amplify.Storage.uploadFile(
    //
    //     local: File(filePath),
    //     key: '${widget.id}/Stuttering/${widget.id}_' + '$date.mp4',
    //   );
    //   print('Successfully uploaded file: ${result.key}');
    // } on StorageException catch (e) {
    //   print('Error uploading file: $e');
    // }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context,) => HomeNavigation(), //list is forwarded to the next screen
        ));
  }




  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new AlertDialog(
          title: new Text("Message"),
          content: new Text("This section will be recorded"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                okay = true;
                Navigator.of(context).pop();
                onStartPressed();

              },
            ),
          ],
        ),
      );
    });
  }



}
