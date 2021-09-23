/*
  Created By: Nathan Chan
  Description: Holds the logic for using the camera controller.
               The widget tree invokes functions in this class
 */

import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera_app/camera_view_build.dart';
import 'package:camera_app/storage_repository.dart';

import 'actions/edit_action.dart';
import 'main.dart';
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:device_info/device_info.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';


/// Home Screen of the application
/// Displays the camera and a few buttons that performs the actions of the camera
class CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  ResolutionPreset resolution = ResolutionPreset.medium;
  String deviceId;
  String latitudeAndLongitude; // latitude-longitude
  int cameraDescriptionIndex = 0;
  StorageRepository storageRepo;
  BooleanWrap isFileFinishedUploading;
  //String username; //username from user
  //String userID; // userId from user
  String uploadMessage; // Message when uploading
  bool controllerInitialized = false; // is controller initialized
  bool audioSwitchState = true; // holds state of audio switch
  bool displayId = false; // display the device id or not
  ChunkVideoData chunkData;
  CameraViewBuild widgets; // the camera view widgets
  static int videoChunkRate = 10000000; // in seconds
  Timer chunkTimer; // timer for video chunking
  // animation objects that control simple animations
  AnimationController optionsAnimationController;
  Animation<double> optionsRowAnimation;
  AnimationController actionsAnimationController;
  Animation<double> actionsRowAnimation;


  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// A static method that gets the string representation of the
  /// chunk rate
  /// Returns: A string representing the chunk rate
  static String getVideoChunkRateString() {
    if (CameraExampleHomeState.videoChunkRate > 1800)
      return "None";
    else if (CameraExampleHomeState.videoChunkRate < 60)
      return CameraExampleHomeState.videoChunkRate.toString() + " Seconds";
    else if (CameraExampleHomeState.videoChunkRate == 60)
      return "1 Minute";
    else
      return (CameraExampleHomeState.videoChunkRate~/60).toString()
          + " Minutes";
  }
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  // Constructor
  // CameraExampleHomeState(String username, String userID) {
  //   this.username = username;
  //   this.userID = userID;
  // }

  // Called upon initialization of the object
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    if (cameras.isNotEmpty) {
      // initialize camera controller
      controller = CameraController(
        cameras[cameraDescriptionIndex],
        ResolutionPreset.medium,
        enableAudio: enableAudio,
      );
    } else {
      controller = CameraController(
        CameraDescription(),
        ResolutionPreset.medium,
        enableAudio: enableAudio,
      );
    }
    controller.initialize();

    // initialize the following animation control objects
    optionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    optionsRowAnimation = CurvedAnimation(
      parent: optionsAnimationController,
      curve: Curves.easeInCubic,
    );
    actionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    actionsRowAnimation = CurvedAnimation(
      parent: actionsAnimationController,
      curve: Curves.easeInCubic,
    );
    // start by showing the camera options button
    actionsAnimationController.value = 1;

    // initialize storage repository
    storageRepo = StorageRepository();
    // initialize boolean wrap object
    isFileFinishedUploading = BooleanWrap(false, false, false);
    // initialize chunk video object
    chunkData = ChunkVideoData(chunkVideo: false, videoCount: 0);
    // set upload default message;
    uploadMessage = "Upload";
    // set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // wait for camera controller to initialize
    waitForCamera();
  }

  // Called when widget is deleted
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    optionsAnimationController.dispose();
    actionsAnimationController.dispose();
    super.dispose();
  }

  /// Requests location permission and saves device data
  /// Returns: A future object that returns asynchronously
  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    // Checks the device type. (Android or ios)
    try {
      if (Platform.isAndroid) {
        deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        deviceId = deviceData['id'];
      } else if (Platform.isIOS) {
        deviceData = readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        deviceId = deviceData['identifierForVendor'];
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    // Gets the initial location of user. It serves as a permission grantor.
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // checks if location service has been enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Checks if location permission has been granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // saves device data
    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  /// Stores the android device information in a Map.
  /// Parameters: device info object
  /// Returns: Map of a string to a info object attribute
  Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  /// Stores the ios device information in a Map.
  /// Parameters: device info object
  /// Returns: Map of a string to a info object attribute
  Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  /// App state changed before we got the chance to initialize.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        // Initialized a new camera
        onNewCameraSelected(controller.description);
      }
    }
  }


  /// Builds the application. Sets the layout and functionality of the application.
  /// Is defined automatically by the stateless widget class
  @override
  Widget build(BuildContext context) {
    // initialize the widgets
    widgets = CameraViewBuild(
      context: context,
      state: this,
      controller: this.controller,
      isFileFinishedUploading: this.isFileFinishedUploading,
      enableAudio: this.enableAudio,
      uploadMessage: this.uploadMessage
    );
    if (!controller.value.isRecordingVideo) {
      actionsAnimationController.value = 1;
    }
    return widgets.build();
  }


  /// Is called when the camera switch button is pressed. Initializes a new
  /// camera
  void cameraToggleButtonPressed() {
    // Do nothing if no cameras are detected
    if (cameras.isEmpty) {
      return;
    } else {
      if (controller != null && controller.value.isRecordingVideo) {
        return;
      }
      else {
        // Cycle through cameras
        cameraDescriptionIndex++;
        if (cameraDescriptionIndex == cameras.length) {
          cameraDescriptionIndex = 0;
        }
        // Initialize new camera
        onNewCameraSelected(cameras[cameraDescriptionIndex]);
      }
    }
  }

  /// Changes the animation of the camera options widget.
  /// Displays the options when collapsed and vise versa
  void onCameraOptionsButtonPressed() {
    if (optionsAnimationController.value == 1) {
      optionsAnimationController.reverse();
    } else {
      optionsAnimationController.forward();
    }
  }

  /// Changes the animation of the camera options button
  /// Displays the button when not recording and hides the
  /// button when recording starts
  void hideCameraOptionsButton() {
    if (actionsAnimationController.value == 1) {
      actionsAnimationController.reverse();
    } else {
      actionsAnimationController.forward();
    }
  }

  /// Timestamp when a picture or video is taken.
  /// Returns: String containing current time
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// create the snack bar and display in Scaffold
  /// Parameters: Message to display in snackbar
  void showInSnackBar(String message) {
    SnackBar bar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }

  /// Give the camera time to initilize before the user
  /// tries changing the switch state again. Without the 1
  /// second delay, errors would be thrown
  /// Parameters: The current state of the audio switch
  void enableAudioSwitchChanged(bool value) async {
    audioSwitchState = false;
    enableAudio = value;
    if (controller != null) {
      onNewCameraSelected(controller.description);
    }
    await wait(1);
    audioSwitchState = true;
  }

  /// Dispose of CameraController and reinitialize new when a different camera is selected.
  /// Parameters: Description of the new camera to be initialized
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(
      cameraDescription,
      resolution,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Change the resolution of the camera as specified by the user
  /// Parameters: String option which holds the desired resolution
  /// setting chosen by the user
  void changeResolution(String option) {
    if (option == "high")
      resolution = ResolutionPreset.high;
    else if (option == "medium")
      resolution = ResolutionPreset.medium;
    else if (option == "low")
      resolution = ResolutionPreset.low;
    // create a new camera with desired resolution
    if (option != "cancel" && option != null) {
      onNewCameraSelected(cameras[cameraDescriptionIndex]);
    }
  }

  /// Changes the chunk rate variable to the option chosen by the user
  /// Parameters: The string option that the user chose in the
  /// cupertino action sheet
  void changeVideoChunkRate(String option) {
    if (option == "none")
      videoChunkRate = 1000000000;
    else if (option == "30")
      videoChunkRate = 1800;
    else if (option == "10")
      videoChunkRate = 600;
    else if (option == "5")
      videoChunkRate = 300;
    else if (option == "1")
      videoChunkRate = 60;
    else if (option == "0.5")
      videoChunkRate = 30;
    print("Set chunk rate to " + option);
  }

  /// Handles the action button being pressed. Passes the action to the
  /// storage repository to add to the text file
  /// Parameters: ActionButton enumeration which indicates the action chosen
  /// Returns: How many times the action has occurred so far
  void onActionButtonPressed(String name, ActionType type) async {
    if (type == ActionType.frequency)
      final count = await storageRepo.addAction(name);
    else
      storageRepo.addActionDuration(name);
    //print("Count is now: "+ count.toString());
  }

  /// Set variables accordingly for taking a picture, calls takePicture()
  void onTakePictureButtonPressed() {
    uploadMessage = "Upload";
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          //showInSnackBar('Picture saved to gallery.');
        }
      }
    });
  }

  /// Starts video recording and displays a snack bar,
  /// calls startVideoRecording()
  Timer onVideoRecordButtonPressed() {
    uploadMessage = "Upload";
    // create the action file for video
    storageRepo.createActionTextFile();
    // start stopwatch
    storageRepo.timeElapsed.start();
    startVideoRecording().then((String filePath) async {
      if (mounted) setState(() {});
      //if (filePath != null) showInSnackBar('Video recording started.');
      // Run the timer to chunk the video at the specified time
        final duration = Duration(seconds: videoChunkRate);
        // save time so it can be canceled later
        chunkTimer = Timer.periodic(duration, chunkVideo);
        return chunkTimer;
      }
    );
    return null;
  }

  /// This function is called when the video chunk timer is activated
  /// It stops the recording and starts a new recording. The finished
  /// recording is uploaded to AWS. This function is continuous called
  /// until the timer is canceled.
  /// Parameters: the timer that calls this function every cycle
  void chunkVideo(Timer t) async {
    // mark the video for chunking and increase the count
    chunkData.videoCount++;
    chunkData.chunkVideo = true;
    showInSnackBar("Time limit reached, video will be chunked");
    File video;

    // Creates the file path where the video is to be saved
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$deviceId${timestamp()}.mp4';

    try {
      // stop recording
      video = File(videoPath);
      videoPath = filePath;
      // stop stopwatch
      storageRepo.timeElapsed.stop();
      controller.stopVideoRecording();
      controller.prepareForVideoRecording();
      // start recording again
      await controller.startVideoRecording(filePath);
      storageRepo.timeElapsed.start();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    // Upload video to AWS S3
    try {
      // Record location data
      Location location = new Location();
      LocationData myLocation = await location.getLocation();

      // Upload function from storage repo
      // final videoKey = await storageRepo.uploadFile(
      //     username, video, '.mp4', userID, myLocation);
      final videoKey = await storageRepo.uploadFile(
          "Null username", video, '.mp4', deviceId, myLocation, chunkData, controller);
    } on StorageException catch (e) {
      print(e.message);
    }
  }

  /// Stops video recording, calls stopVideoRecording()
  void onStopButtonPressed() {
    // stop all duration actions still running
    storageRepo.stopAllDurationActions();
    // clear action count
    storageRepo.clearActionCount();
    if (chunkData.videoCount != 0)
      chunkData.videoCount++;
    // Stop the video chunk timer
    chunkTimer.cancel();
    print(chunkTimer.toString());
    // stop and reset the stopwatch
    storageRepo.timeElapsed.stop();
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      //showInSnackBar('Video recorded to gallery.');
    });
  }

  /// Pauses the video recording and displays a snack bar,
  /// calls pauseVideoRecording()
  void onPauseButtonPressed() {
    // pause stopwatch
    storageRepo.timeElapsed.stop();
    if (chunkTimer != null)
      chunkTimer.cancel();
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      //showInSnackBar('Video recording paused.');
    });
  }

  /// Resumes the video recording and displays a snack bar
  /// , calls resumeVideoRecording()
  Timer onResumeButtonPressed() {
    // resume stopwatch
    storageRepo.timeElapsed.start();
    final duration = Duration(seconds: videoChunkRate);
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      //showInSnackBar('Video recording resumed.');
      chunkTimer = Timer.periodic(duration, chunkVideo);
      return chunkTimer;
    });

  }


  /// Sets the path and starts the recording process.
  /// Returns: A future string object that returns the filepath of the video
  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      // Controller is not initialized
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    // Creates the file path where the video is to be saved
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$deviceId${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    // Start recording video
    try {
      videoPath = filePath;
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    // hide the camera options button
    hideCameraOptionsButton();

    return filePath;
  }

  /// Stop the recording and save the video. Once saving is finished,
  /// upload the video to AWS
  /// Returns: A future object, indicates function is not synchronous
  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    // Record location data
    Location location = new Location();
    LocationData myLocation = await location.getLocation();

    try {
      // Save the video to the camera roll
      await controller.stopVideoRecording();
      // saving disabled for now
      // GallerySaver.saveVideo(videoPath);

      // ask the user if they want to upload to AWS if
      // video has not been chunked
      if (!chunkData.chunkVideo)
        await widgets.showUploadDialogBox();
      else
        isFileFinishedUploading.upload = true;

      if (isFileFinishedUploading.upload) {
        // Change state of camera preview to show the upload process
        isFileFinishedUploading.finished = false;
        setState(() {isFileFinishedUploading.started = true;});

        // Upload video to AWS S3
        try {
          final video = File(videoPath);
          // Upload function from storage repo
          // final videoKey = await storageRepo.uploadFile(
          //     username, video, '.mp4', userID, myLocation);
          final videoKey = await storageRepo.uploadFile(
              "Null username", video, '.mp4', deviceId, myLocation, chunkData, controller);

          // Change the state of the camera preview to show upload complete
          setState(() {
            isFileFinishedUploading.finished = true;
          });
          await wait(2); // wait 2 seconds
          // Change camera preview back to camera
          setState(() {
            isFileFinishedUploading.started = false;
          });
        } on StorageException catch (e) {
          print(e.message);
          showInSnackBar(e.message);
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    // reset the stopwatch
    storageRepo.timeElapsed.reset();
    // change variable back to initial state
    chunkData.chunkVideo = false;
    chunkData.videoCount = 0;
    // display camera options button again
    hideCameraOptionsButton();

    // for video playback, not used
    //await _startVideoPlayer();
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

  /// Start playing the video that was just saved, not used
  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
    VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    final VideoPlayerController oldController = videoController;
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
    await oldController?.dispose();
  }

  /// Save the image to the camera roll. Once saving is finished,
  /// upload the image to AWS
  /// Returns: A future string that is a filepath to the image
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    // Get the location data for the image
    Location location = new Location();
    LocationData myLocation = await location.getLocation();

    // Get and save the filepath of the image
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$deviceId${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      // Save the image to the camera roll
      await controller.takePicture(filePath);
      // saving disabled for now due to android bug
      //GallerySaver.saveImage(filePath);

      // ask the user if they want to upload to AWS
      await widgets.showUploadDialogBox();
      if (isFileFinishedUploading.upload) {
        // change state of camera preview
        isFileFinishedUploading.finished = false;
        setState(() {isFileFinishedUploading.started = true;});

        // upload image to AWS S3
        try {
          File image = File(filePath);
          // Upload function from storage repo
          // final imageKey = await storageRepo.uploadFile(
          //     username, image, '.jpg', userID, myLocation);
          final imageKey = await storageRepo.uploadFile(
              "Null username", image, '.jpg', deviceId, myLocation, chunkData, controller);

          // Change the state of the camera preview to show upload complete
          setState(() {
            isFileFinishedUploading.finished = true;
          });
          await wait(2); // wait 2 seconds
          // Change camera preview back to camera
          setState(() {
            isFileFinishedUploading.started = false;
          });

        } on StorageException catch (e) {
          print(e.message);
          showInSnackBar(e.message);
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  /// Print out the camera error message
  /// Parameters: CameraException error
  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  /// Simple wait function that delays by a certain amount of seconds
  /// Must be used with "await" keyword
  /// Parameters: Integer with amount of seconds to wait
  /// Returns: A future object, indicates function is not synchronous
  Future<void> wait(int seconds) {
    return Future.delayed(Duration(seconds: seconds));
  }

  /// Provide a delay before showing camera preview to give the
  /// controller time to initialize
  /// Returns: A future object indicating an asynchronous function
  Future<void> waitForCamera() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      controllerInitialized = true;
    });
  }

  /// Simple method to update the UI by calling set state
  void updateUI () {
    setState(() {});
  }

}