/*
  Created By: Nathan Millwater
  Description: Holds the camera home widget tree. Once the user
               has logged in, the session starts and this widget
               tree is displayed.
 */

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/actions/action_catalog.dart';
import 'package:camera_app/camera_example_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_app/actions/edit_action.dart';

import 'camera_cubit.dart';
import 'main.dart';
import 'models/cart_model.dart';
import 'models/catalog_model.dart';

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

/// Wrapper class that stores the isVideoChunked boolean variable
/// and the number of chunked videos created
class ChunkVideoData {
  bool chunkVideo;
  int videoCount;

  ChunkVideoData({this.chunkVideo, this.videoCount});
}

class CameraViewBuild {
  BuildContext context;
  CameraExampleHomeState state;
  CameraController controller;
  BooleanWrap isFileFinishedUploading;
  bool enableAudio;
  String uploadMessage;
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // named parameter constructor
  CameraViewBuild(
      {this.context,
      this.state,
      this.controller,
      this.isFileFinishedUploading,
      this.enableAudio,
      this.uploadMessage});

  /// Messages for the snack bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// This called by the main build function in the home class
  Widget build() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: chooseAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                // box around camera preview
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          // Camera control buttons
          captureControlRowWidget(),
          Text("Action Buttons"),
          // The action buttons
          captureActionRowWidget(),
          // Button to show camera options widget
          cameraOptionsButton(),
          // Display the camera options
          cameraOptionsRow(),
        ],
      ),
      // Navigation bar to switch pages
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [

          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize), label: "Action Catalog"),
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: "Actions"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: "Stuttering"),


        ],
        currentIndex: 2,
        onTap: controller != null &&
                controller.value.isInitialized &&
                !controller.value.isRecordingVideo &&
                !isFileFinishedUploading.started
            ? (index) {
                print("index " + index.toString());
                changePage(index, context);
              }
            : null,
      ),
    );
  }

  /// The button widget that brings up the camera options
  /// to the user
  /// Returns: A size changeable widget that depends on the animation
  /// controller
  Widget cameraOptionsButton() {
    return SizeTransition(
      // link to the animation
      sizeFactor: state.actionsRowAnimation,
      child: ClipRect(
        child: Center(
          child: TextButton(
              onPressed: controller != null
                  ? state.onCameraOptionsButtonPressed
                  : null,
              child: Text(
                "Camera Options",
                style: TextStyle(fontSize: 15),
              )),
        ),
      ),
    );
  }

  /// Changes to the corresponding page on the bottom navigation bar
  /// Parameters: The index of the selected page, and the build context
  /// to read from
  void changePage(int index, BuildContext context) {
    if (index == 0)
      {
        context.read<CameraCubit>().showActionCatalog();
        print("pressed Action Catalog");
      }

    else if (index == 1)
      {
        print("Pressed ActionList");
        context.read<CameraCubit>().showActionList();
      }
    else if (index == 3)
    {
      print("Pressed AStuttering");
      context.read<CameraCubit>().showStutteringCatalog();
    }

  }

  /// Chooses the appbar based on the device platform
  /// Returns: Appbar Widget
  Widget chooseAppBar() {
    Icon icon;
    if (Theme.of(context).platform == TargetPlatform.iOS)
      icon = Icon(Icons.flip_camera_ios);
    else
      icon = Icon(Icons.flip_camera_android);
    return AppBar(
      title: Text("Camera Home"),
      actions: [
        IconButton(
          icon: icon,
          onPressed: () {
            // Switch to a different camera
            state.cameraToggleButtonPressed();
          },
        )
      ],
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  /// Returns: the camera preview widget
  Widget cameraPreviewWidget() {
    // Check if file has started uploading
    if (isFileFinishedUploading.started) {
      // Check if file has finished uploading
      if (isFileFinishedUploading.finished) {
        return Text(
          "Upload Complete",
          style: TextStyle(color: Colors.white, fontSize: 30),
        );
      } else {
        // Display uploading indicator
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "File Uploading",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        );
      }
    }
    // Display the camera preview
    if (cameras.isEmpty || !state.controller.value.isInitialized) {
      return const Text(
        'No cameras detected',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      // Show camera preview
      return RotatedBox(
        quarterTurns:
            MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 0,
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      );
    }
  }

  /// Returns: toggle recording audio widget
  Widget toggleAudioWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Enable Audio:',
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(
          width: 5,
        ),
        // Android switch or IOS switch
        enableAudioSwitchType(),
        SizedBox(
          width: 10,
        ),
        chunkRateActionSheet(),
      ],
    );
  }

  /// A function that holds the action sheet for changing the chunk rate
  /// Returns: An action sheet widget
  Widget chunkRateActionSheet() {
    return CupertinoButton(
      onPressed: !controller.value.isRecordingVideo
          ? () async {
              final currentResolution = state.resolution.toString();
              // store the returned result in a variable to use later
              var returned = await showCupertinoModalPopup<String>(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  title: Text('Choose a video chunking rate',
                      style: TextStyle(fontSize: 18)),
                  message: Text("The chunk rate is currently set at " +
                      CameraExampleHomeState.getVideoChunkRateString()),
                  // list of all options to choose from
                  actions: <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                        child: const Text('None'),
                        onPressed: () {
                          Navigator.of(context).pop("none");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('30 Minutes'),
                        onPressed: () {
                          Navigator.of(context).pop("30");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('10 Minutes'),
                        onPressed: () {
                          Navigator.of(context).pop("10");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('5 Minutes'),
                        onPressed: () {
                          Navigator.of(context).pop("5");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('1 Minute'),
                        onPressed: () {
                          Navigator.of(context).pop("1");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('30 Seconds'),
                        onPressed: () {
                          Navigator.of(context).pop("0.5");
                        })
                  ],
                  cancelButton: CupertinoActionSheetAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop("cancel");
                      }),
                ),
              );
              // call for chunking rate change
              state.changeVideoChunkRate(returned);
            }
          : null,
      // The text of the button
      child: const Text('Video Chunk Rate'),
    );
  }

  /// Choose the type of enable audio switch depending on the device platform
  /// Returns: a switch widget
  Widget enableAudioSwitchType() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Use a cupertino switch if platform is IOS
      return CupertinoSwitch(
        value: state.enableAudio,
        onChanged: !controller.value.isRecordingVideo
            ? (bool value) {
                state.enableAudioSwitchChanged(value);
              }
            : null,
      );
    } else {
      // Use a material switch if platform is Android
      return Switch(
        value: state.enableAudio,
        onChanged: (bool value) {
          enableAudio = value;
          if (controller != null && state.audioSwitchState) {
            state.enableAudioSwitchChanged(value);
          }
        },
      );
    }
  }

  /// Displays the animation for brining up the camera options
  /// Returns: A dynamic sized widget according to the animation
  /// controller
  Widget cameraOptionsRow() {
    return SizeTransition(
      // link to the animation
      sizeFactor: state.optionsRowAnimation,
      child: ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            changeResolutionWidget(),
            toggleAudioWidget(),
            // Display device Id
            TextButton(
                onPressed: () {
                  state.displayId = state.displayId ? false : true;
                  state.updateUI();
                },
                child: state.displayId
                    ? Text(
                        state.deviceId,
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      )
                    : Text(
                        "Display Device ID",
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      )),
          ],
        ),
      ),
    );
  }

  /// Display the change resolution widget on the page
  /// Returns: A row that holds the text and buttons for changing the
  /// camera resolution
  Widget changeResolutionWidget() {
    // Get the current resolution from the camera controller
    String currentResolution = state.resolution.toString().substring(17);
    currentResolution = currentResolution.substring(0, 1).toUpperCase() +
        currentResolution.substring(1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(
              "Resolution: ",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              currentResolution,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        // option to change resolutions
        cupertinoActionSheet(),
      ],
    );
  }

  /// Displays an action menu for the user to change the camera resolution
  /// Returns: A button that brings up an action sheet of choices
  Widget cupertinoActionSheet() {
    return CupertinoButton(
      onPressed: !controller.value.isRecordingVideo
          ? () async {
              final currentResolution = state.resolution.toString();
              // store the returned result in a variable to use later
              var returned = await showCupertinoModalPopup<String>(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  title: Text('Choose a resolution',
                      style: TextStyle(fontSize: 18)),
                  message: Text("The resolution is currently set at " +
                      currentResolution.substring(17)),
                  // list of all options to choose from
                  actions: <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                        child: const Text('High'),
                        onPressed: () {
                          Navigator.of(context).pop("high");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('Medium'),
                        onPressed: () {
                          Navigator.of(context).pop("medium");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('Low'),
                        onPressed: () {
                          Navigator.of(context).pop("low");
                        })
                  ],
                  cancelButton: CupertinoActionSheetAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop("cancel");
                      }),
                ),
              );
              // call for resolution change
              state.changeResolution(returned);
            }
          : null,
      child: const Text('Change Resolution'),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  /// Returns: a Row widget with 4 buttons
  Widget captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
            icon: const Icon(Icons.camera_alt),
            color: Colors.blue,
            // If all boolean values are true, activate button otherwise do nothing
            onPressed: () async {
              if (controller != null &&
                      controller.value.isInitialized &&
                      !controller.value.isRecordingVideo &&
                      !isFileFinishedUploading
                          .started // only if finished uploading
                  ) if (await isInternetConnected())
                state.onTakePictureButtonPressed();
              else
                state.showInSnackBar("You are not connected to the internet");
            }),
        IconButton(
            icon: const Icon(Icons.videocam),
            color: Colors.blue,
            // If all boolean values are true, activate button otherwise do nothing
            onPressed: () async {
              print("Started Recording");
              if (controller != null &&
                      controller.value.isInitialized &&
                      !controller.value.isRecordingVideo &&
                      !isFileFinishedUploading
                          .started // only if finished uploading
                  ) if (await isInternetConnected())
                state.onVideoRecordButtonPressed();
              else
                state.showInSnackBar("You are not connected to the internet");
            }),
        IconButton(
          icon: controller != null && controller.value.isRecordingPaused
              ? Icon(Icons.play_arrow)
              : Icon(Icons.pause),
          color: Colors.blue,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo
              ? (controller != null && controller.value.isRecordingPaused
                  ? state.onResumeButtonPressed
                  : state.onPauseButtonPressed)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo
              ? state.onStopButtonPressed
              : null,
        )
      ],
    );
  }

  /// Gets the associated action entry name from the Item object
  /// Parameters: The item from the action catalog
  /// Returns: The string name of the item
  String getButtonTitle(Item item) {
    int count = 0;
    String title;
    if (state.storageRepo.getAction(item.name) != null) {
      count = state.storageRepo.getAction(item.name).count;
      title = '${item.name} ($count)';
    } else {
      title = '${item.name}';
    }
    return title;
  }

  /// Gets the text for displaying under the button
  /// Parameters: The item from the action catalog
  /// Returns: The string of what to display under the button
  String getButtonSubtitle(Item item) {
    if (item.actionType == ActionType.duration &&
        state.storageRepo.isActionRunning(item.name)) {
      return item.actionType.toShortString() + " Running";
    }
    return item.actionType.toShortString();
  }

  /// Display all the currently selected action buttons on the home
  /// screen.
  /// Returns: A GridView widget that stores all the buttons in a grid
  /// which can be adjusted to show more or less buttons at one time
  Widget captureActionRowWidget() {
    // We must create a list of widgets to add
    var cart = context.watch<CartModel>();
    List<Widget> buttons = [];
    // cycle through the items list and create a button widget
    for (Item item in cart.items) {
      String title = getButtonTitle(item);
      String subtitle = getButtonSubtitle(item);
      Widget button = TextButton(
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo &&
                  !controller.value.isRecordingPaused
              ? () async {
                  // update the UI to reflect the new count
                  state.onActionButtonPressed(item.name, item.actionType);
                  state.updateUI();
                }
              : null,
          child: Column(
            children: [
              SizedBox(
                  height: 30,
                  child: DecoratedBox(
                      child: Center(
                          child: Text(title,
                              style: TextStyle(color: Colors.white))),
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ))),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black))
            ],
          ));
      buttons.add(button);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: controller.value.isRecordingVideo ? 20 : 0,
      ),
      child: SizedBox(
        // Define the height of the gridview
        height: buttons.length > 3
            ? 125
            : buttons.length == 0
                ? 0
                : 62.5,
        child: GridView.count(
          childAspectRatio: MediaQuery.of(context).size.width / 219.428,
          crossAxisCount: 3,
          children: buttons,
        ),
      ),
    );
  }

  /// Displays a dialog box that prompts the user if they want to upload their file
  /// Returns: A future object, indicates function is not synchronous
  Future<void> showUploadDialogBox() {
    if (Theme.of(context).platform == TargetPlatform.android)
      return materialDialog();
    else
      return materialDialog();
  }

  /// Separate function to return a cupertino dialog box
  /// instead of a material dialog box
  /// Returns: A future widget object that does not return until
  /// the user has chosen an option
  Future<Widget> cupertinoDialog() {
    return showCupertinoDialog<Widget>(
        // User cannot dismiss the dialog
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(uploadMessage),
            content: Text("Do you want to upload this file to AWS?"),
            actions: [
              // No button
              CupertinoDialogAction(
                  onPressed: () {
                    isFileFinishedUploading.upload = false;
                    Navigator.of(context).pop();
                  },
                  child: Text("No")),
              // Yes button
              CupertinoDialogAction(
                  onPressed: () async {
                    final connected = await isInternetConnected();
                    Navigator.of(context).pop();
                    if (connected) {
                      isFileFinishedUploading.upload = true;
                    } else {
                      state.showInSnackBar(
                          "You are not connected to the internet");
                    }
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  /// The widget object for prompting the user to upload their file
  /// Returns: A future widget object that does not return until
  /// the user has chosen an option
  Future<Widget> materialDialog() async {
    return showDialog<Widget>(
        // User cannot dismiss the dialog
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text("Additional Parameters"),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
                    // Name form field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        icon: Icon(Icons.pending_actions),
                      ),
                      controller: titleController,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text("Description",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    // Description form field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        icon: Icon(Icons.message),
                      ),
                      controller: descriptionController,
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // No button
              TextButton(
                  onPressed: () {
                    isFileFinishedUploading.upload = false;
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")),
              // Yes button
              TextButton(
                  onPressed: () async {
                    final connected = await isInternetConnected();
                    Navigator.of(context).pop();
                    if (connected) {
                      isFileFinishedUploading.upload = true;
                      // upload title and description
                      // upload image
                    } else {
                      state.showInSnackBar(
                          "You are not connected to the internet");
                    }
                  },
                  child: Text("Submit"))
            ],
          );
        });
  }

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

  // /// Display the thumbnail of the captured image or video.
  // /// Is not currently being used
  // Widget thumbnailWidget() {
  //   return Expanded(
  //     child: Align(
  //       alignment: Alignment.centerRight,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           videoController == null && imagePath == null
  //               ? Container()
  //               : SizedBox(
  //             child: (videoController == null)
  //                 ? Image.file(File(imagePath))
  //                 : Container(
  //               child: Center(
  //                 child: AspectRatio(
  //                     aspectRatio:
  //                     videoController.value.size != null
  //                         ? videoController.value.aspectRatio
  //                         : 1.0,
  //                     child: VideoPlayer(videoController)),
  //               ),
  //               decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.pink)),
  //             ),
  //             width: 64.0,
  //             height: 64.0,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

}
