import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/camera_view_build.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';


class ReadPassage extends StatefulWidget {
  ReadPassage({this.title});

  String title = "Read Passage";




  @override
  _ReadPassageState createState() => _ReadPassageState();
}


/// A wrapper class that wraps the upload file boolean variables
class BooleanWrap {
  BooleanWrap(bool a, bool b, bool c) {
    this.finished = a;
    this.started = b;
    this.upload = c;
  }
  bool finished;
  bool started;
  bool upload;
}


class _ReadPassageState extends State<ReadPassage> {

  String sessionText = "A trip to Israel should be a rite of passage for every Christian. There is no substitute for walking the land where Jesus walked and traversing the paths of the patriarchs, kings, prophets, and the first disciples. The origins of both ancient Biblical faith and of a present-day nation, rich with culture, diversity, beauty, and challenges, are in Israel. The land and the people of Israel have a story to tell. By coming to Israel, you make Israel’s story part of your own.";
  CameraController controller;
  String filePath;
  CameraViewBuild cameraview = new CameraViewBuild();
  BooleanWrap isFileFinishedUploading;
  bool enableAudio = true;
  String uploadMessage;



  _ReadPassageState() {

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
 ///Widget for camera options
  Widget captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[

        IconButton(
            icon: const Icon(Icons.videocam),
            color: Colors.blue,
            // If all boolean values are true, activate button otherwise do nothing
            onPressed: () async {
              print("Started Recording");
              if (controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo

                      // only if finished uploading
              ) if (await isInternetConnected())
                onStartPressed();
              else
                showInSnackBar("You are not connected to the internet");
            }),
        IconButton(
          icon: controller != null && controller.value.isRecordingPaused
              ? Icon(Icons.play_arrow)
              : Icon(Icons.pause),
          color: Colors.blue,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed:

                controller != null &&
                controller.value.isInitialized &&
                controller.value.isRecordingVideo
                ? (controller != null && controller.value.isRecordingPaused
                ? onResumeButtonPressed
                : onPauseButtonPressed)
        : null,
    ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? onStopPressed
              : null,
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //cameraview widget


    return Scaffold(
      //body: Padding(
        //padding: const EdgeInsets.only(top: 40, bottom: 10),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Container(
                  height :MediaQuery.of(context).size.height,width:MediaQuery.of(context).size.width,
                  //padding: EdgeInsets.all(80),
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*.08,
                                          bottom:MediaQuery.of(context).size.height*.01,
                                          left: MediaQuery.of(context).size.height*.02,
                                          right: MediaQuery.of(context).size.height*.02
                    ),
                  color: Colors.blueGrey[100],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      sessionText.toString(),
                      style: TextStyle(fontSize: 25, backgroundColor: Colors.blue),
                    ),
                  ),
                )
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                // child: ElevatedButton(
                //   style: ButtonStyle(
                //     //foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                //   ),
                //   onPressed: () {
                //     if (!controller.value.isRecordingVideo)
                //       onStartPressed();
                //     else
                //       onStopPressed();
                //   },
                //   child: controller.value.isRecordingVideo ?
                //   Text("stop recording") : Text('Start Session'),
                //   //child: Text("Recording")
                // ),
                child: captureControlRowWidget()
              ),
            )
          ],
        ),
    );
  }

  Future<void> onStartPressed() async {
    // Creates the file path where the video is to be saved
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    String date = DateTime.now().toIso8601String();
    filePath = '$dirPath/$date.mp4';


    await controller.startVideoRecording(filePath);
    setState(() {});
  }

  /// create the snack bar and display in Scaffold
  /// Parameters: Message to display in snackbar
  void showInSnackBar(String message) {
    SnackBar bar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }

  /// Resumes the video recording and displays a snack bar
  /// , calls resumeVideoRecording()
  Future<void> onResumeButtonPressed() {
    // resume stopwatch
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed.');

    });

  }


  /// Pauses the video recording and displays a snack bar,
  /// calls pauseVideoRecording()
  void onPauseButtonPressed() {
    // pause stopwatch

    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused.');
    });
  }

  /// Pauses the recording using the camera controller
  /// Returns: A future object, indicates function is not synchronous
  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  /// Resumes the recording using the camera controller
  /// Returns: A future object, indicates function is not synchronous
  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }



  /// Print out the camera error message
  /// Parameters: CameraException error
  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  ///Strops the video and uploaeds file
  Future<void> onStopPressed() async {
    await controller.stopVideoRecording();
    setState(() {});
    String date = DateTime.now().toIso8601String();
    print("onStopPressed()");
    try {
      final result = await Amplify.Storage.uploadFile(

        local: File(filePath),
        key: '$date.mp4',
      );
      print('Successfully uploaded file: ${result.key}');
    } on StorageException catch (e) {
      print('Error uploading file: $e');
    }
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => Survey ()));
    }




  }


