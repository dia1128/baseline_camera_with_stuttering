import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/camera_view_build.dart';
import 'package:camera_app/stuttering/survey.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../main.dart';
import 'dart:convert' show utf8;
import 'package:csv/csv.dart';

class ReadPassage extends StatefulWidget {
  final passageContent;
  ReadPassage({this.title,this.deviceID, this.passageContent});

  String title = "Read Passage";
  String deviceID;





  @override
  _ReadPassageState createState() => _ReadPassageState();
}




class _ReadPassageState extends State<ReadPassage> {

  //String sessionText = "A trip to Israel should be a rite of passage for every Christian. There is no substitute for walking the land where Jesus walked and traversing the paths of the patriarchs, kings, prophets, and the first disciples. The origins of both ancient Biblical faith and of a present-day nation, rich with culture, diversity, beauty, and challenges, are in Israel. The land and the people of Israel have a story to tell. By coming to Israel, you make Israel’s story part of your own.";
  CameraController controller;
  String filePath;
  BooleanWrap isFileFinishedUploading;
  bool enableAudio = true;
  String uploadMessage;
  bool enableVideo = false;
  int count = 0;
  final _random = Random();
  final readPassages = [];
  int rand = 0;


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
              {
                onStartPressed();

              }

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
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*.04,
                    bottom:MediaQuery.of(context).size.height*.01,
                    left: MediaQuery.of(context).size.height*.01,
                    right: MediaQuery.of(context).size.height*.01
                ),
                decoration: BoxDecoration(

                    border: Border.all(color: enableVideo == true ? Colors.red: Colors.white, width:4),
                    color: Colors.white

                ),
                //color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                            widget.passageContent[rand][1].toString() ,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.left
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Text(
                            widget.passageContent[rand][2].toString() ,
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.left
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
          Center(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 20),

                child: captureControlRowWidget()
            ),
          )
        ],
      ),
    );
  }

  Future<void> onStartPressed() async {
    // Creates the file path where the video is to be saved
    enableVideo = true;
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
    enableVideo =false;
    await controller.stopVideoRecording();

    setState(() {});
    String date = DateTime.now().toIso8601String().substring(0, 19);
    print("onStopPressed()");

    // try {
    //   final result = await Amplify.Storage.uploadFile(
    //
    //     local: File(filePath),
    //     key: '${widget.deviceID}/Stuttering/${widget.deviceID}_' + '$date.mp4',
    //   );
    //   print('Successfully uploaded file: ${result.key}');
    // } on StorageException catch (e) {
    //   print('Error uploading file: $e');
    // }
    var data = await downloadProtected() as List;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context,) => Survey(questions: data.toList(), id: widget.deviceID.toString()), //list is forwarded to the next screen
        ));
  }



  ///Download files from aws, create a temporary csv file
  ///create a list from the file and return the list
  Future downloadProtected() async {
    // Create a file to store downloaded contents
    final documentsDir = await getApplicationDocumentsDirectory();
    //final filepath = documentsDir.path + '/example.csv';
    final filepath = documentsDir.path + '/example_survey.csv';
    final file = File(filepath);
    List fields = [];


    // Set access level and Cognito Identity ID.
    // Note: `targetIdentityId` is only needed when downloading
    // protected files of a user other than the one currently
    // logged in.
    final downloadOptions = S3DownloadFileOptions(
      accessLevel: StorageAccessLevel.guest,
    );

    //Download gues file and read contents
    try {
      await Amplify.Storage.downloadFile(
        key: 'questions.csv',
        local: file,
        options: downloadOptions,
      );

      final input = file.openRead();
      fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();

      //print("List"+ fields.toString());
      return fields;

    } on StorageException catch (e) {
      print('Error downloading protected file: $e');
    }

  }

  int nextInt(int min, int max) => min + _random.nextInt((max + 1) - min);


  @override
  void initState() {
    super.initState();
    rand = nextInt(1, nextInt(1,widget.passageContent.length));

  }




}

