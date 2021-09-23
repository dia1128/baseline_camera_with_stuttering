/*
  Created By: Nathan Millwater
  Description: Hold the logic for interacting with the cloud storage repository
 */

import 'dart:io';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/camera_view_build.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sortedmap/sortedmap.dart';

import 'actions/edit_action.dart';



/// Holds values related to an action entry
class ActionEntry {

  String action;
  LocationData location;
  String startDateTime;
  String endDateTime;
  int count;
  Duration startTime;
  Duration endTime;
  bool durationComplete;

  ActionEntry({this.action, this.location, this.startDateTime,
    this.count, this.startTime, this.endTime, this.durationComplete
  });
}

/// This class handles interacting with the storage repository.
/// The storage repository in this project is AWS
class StorageRepository {

  String storedDate;
  File actionFile;
  SortedMap<Duration, ActionEntry> actionTable;
  Stopwatch timeElapsed;
  List<ActionEntry> actionCount;
  LocationData savedLocation; // default location data

  // initialize variables in the constructor
  StorageRepository() {
    timeElapsed = Stopwatch();
    actionTable = SortedMap<Duration, ActionEntry>(Ordering.byKey());
    actionCount = [];
    getDefaultLocation();
  }

  Future<void> getDefaultLocation() async {
    Location location = Location();
    savedLocation = await location.getLocation();
  }

  /// Takes in a username, userId, File and extension and stores this information
  /// in AWS. It also stores the csv file containing any actions that were marked
  /// in the video recording
  /// Parameters: The user's username, the File object being uploaded and the file extension
  /// Returns: A future string with the upload file result
  Future<String> uploadFile(String username, File file, String extension,
      String userId, LocationData loc, ChunkVideoData chunk, CameraController c) async {
    if (username == null) {
      username = "null";
    }
    // name of uploaded file
    String fileName;
    username = username.trim();
    // create folders to separate videos and photos
    String type;
    if (extension == ".jpg")
      type = "photos";
    else
      type = "videos";

    // If this is the first video chunk, store the date
    if (chunk.videoCount == 1)
      storedDate = DateTime.now().toIso8601String();
    if (chunk.videoCount == 0 && actionTable.isEmpty) {
      // single video no actions listed
      fileName = '$userId/${userId}_' + DateTime.now().toIso8601String().substring(0, 19);
      fileName = fileName.replaceAll('T', '_');
    } else if (chunk.videoCount == 0 && actionTable.isNotEmpty) {
      // single video with actions
      fileName = '$userId/${userId}_' + DateTime.now().toIso8601String().substring(0, 19);
      fileName = fileName.replaceAll("T", "_");
      storedDate = DateTime.now().toIso8601String();
    } else {
      // chunked video with actions
      fileName = '$userId/$userId' + storedDate.substring(0, 19) + "--"
          + chunk.videoCount.toString();
      fileName = fileName.replaceAll('T', '_');
    }

    // Stores file metadata in the file upload options
    final options = fileMetadata(username, extension, userId, loc);
    // Amplify upload video file function
    final result = await Amplify.Storage.uploadFile(
      local: file,
      key: fileName + extension, // The file name
      options: options, // File upload options
    );
    // upload the action file if a video was uploaded
    if (extension == ".mp4") {
      await writeActionFile(userId);
      await uploadActionFile(userId, c);
    }

    return result.key;
  }

  /// Upload the action file with actions and the time they occurred
  /// to AWS. Include the location with the upload
  /// Parameters: The devices Id string
  /// Returns: A future object indicating this function is asynchronous
  Future<void> uploadActionFile(String userId, CameraController c) async {
    // make sure we have actions to upload and we are not recording
    if (actionTable.isEmpty || c.value.isRecordingVideo) {
      print("No actions submitted");
      return;
    }
    print("Now uploading text file");
    // store the csv file in the same directory as the video file(s)
    String fileName = '$userId/$userId' + storedDate.substring(0, 19);
    fileName = fileName.replaceAll("T", "_");
    // Amplify upload function
    await Amplify.Storage.uploadFile(
        local: actionFile, key: fileName + ".csv");
  }

  /// Write the data stored in the actionTable to a buffer so
  /// we can save it to a file ona the device
  /// Parameters: The device ID for the header
  /// Returns: A future void object which is not synchronous
  Future<void> writeActionFile(String id) async {
    // save data to string buffer because strings are immutable
    var buffer = new StringBuffer();
    buffer.write("Recorded on device: " + id);
    buffer.write("\nTotal length of video " + timeElapsed.elapsed.inSeconds.toString());
    buffer.write("."+timeElapsed.elapsed.inMilliseconds.toString());
    // header for csv file
    buffer.write("\nstart_time,end_time,duration,start_datetime"
        ",end_datetime,longitude,latitude,name");
    // loop through the action table and write the action to the buffer
    actionTable.forEach((key, value) {
      String millisecond = (key.inMilliseconds % 1000).toString();
      buffer.write("\n" + key.inSeconds.toString() + "." + millisecond);
      if (value.durationComplete == null) {
        // we know it is a frequency action
        buffer.write("," + key.inSeconds.toString() + "." + millisecond);
        buffer.write(",0");
        buffer.write("," + DateTime.now().toIso8601String().substring(0, 10));
        buffer.write(" " + value.startDateTime);
        buffer.write("," + DateTime.now().toIso8601String().substring(0, 10));
        buffer.write(" " + value.startDateTime);
      } else {
        // we know it is a duration action
        String millisecond = (value.endTime.inMilliseconds % 1000).toString();
        buffer.write("," + value.endTime.inSeconds.toString() + "."+ millisecond);
        var duration = value.endTime - value.startTime;
        millisecond = (duration.inMilliseconds % 1000).toString();
        buffer.write("," + duration.inSeconds.toString() + "." + millisecond);
        buffer.write("," + DateTime.now().toIso8601String().substring(0, 10));
        buffer.write(" " + value.startDateTime);
        buffer.write("," + DateTime.now().toIso8601String().substring(0, 10));
        buffer.write(" " + value.endDateTime);
      }
      // make sure location is not null
      if (value.location == null && savedLocation == null) {
        buffer.write(",null,null");
      } else if (savedLocation != null) {
        buffer.write("," + savedLocation.longitude.toString());
        buffer.write("," + savedLocation.latitude.toString());
      } else {
        buffer.write("," + value.location.longitude.toString());
        buffer.write("," + value.location.latitude.toString());
      }
      // the action name
      buffer.write("," + value.action);
    });
    // to save time open file only once and write everything
    actionFile.writeAsString(buffer.toString());
  }

  /// Create the metadata map to upload with the file
  /// Parameters: The user's username, userID, file extension, and location data
  /// Returns: metadata for the file to store on AWS
  S3UploadFileOptions fileMetadata(String username, String extension,
      String userId, LocationData loc) {

    Map<String, String> metadata = Map<String, String>();
    //metadata["username"] = username;
    // metadata["user_id"] = userId;
    metadata["device_id"] = userId;
    metadata["date_created"] = DateTime.now().toIso8601String();
    metadata["type"] = extension;
    metadata["latitude"] = loc.latitude.toString();
    metadata["longitude"] = loc.longitude.toString();

    final options = S3UploadFileOptions(
      metadata: metadata,
      accessLevel: StorageAccessLevel.guest, // the access level of the data
    );
    return options;
  }

  /// Create the csv file used to store the action data. This
  /// function does not write to the file, only creates it
  /// Returns: A file that is created asynchronously
  Future<File> createActionTextFile() async {
    // reset the action table
    actionTable = SortedMap<Duration, ActionEntry>(Ordering.byKey());
    // get the app's storage directory
    final Directory extDir = await getApplicationDocumentsDirectory();
    // path in local files
    final String dirPath = '${extDir.path}/camera_app/text_action_files';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/' + DateTime.now().toString();
    // The file name
    File file = File(filePath);
    actionFile = file;
    return file;
  }

  /// Adds a frequency action to the action table data structure by storing
  /// all necessary data.
  /// Parameters: A string representing the name of the action
  /// Returns: How many times the action has occurred so far
  Future<int> addAction(String action) async {
    // save entry in a table
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final duration = timeElapsed.elapsed;

    // get how many times the action has occured so far
    ActionEntry entry = getAction(action);
    if (entry == null)
      // first time the user has tapped the button
      actionCount.add(ActionEntry(action: action, count: 1));
    else
      entry.count++;
    // log the time
    actionTable[duration] =
        ActionEntry(action: action, startDateTime: time);
    print("Action Time Submitted");

    // Record location data
    Location location = new Location();
    LocationData myLocation = await location.getLocation();
    // set location after time because location is not synchronous
    actionTable[duration].location = myLocation;
    if (entry == null)
      return 1;
    return entry.count;
  }

  /// Adds a duration action to the action table. Keeps track of
  /// whether the action is complete or not
  /// Parameters: A string representing the name of the action
  void addActionDuration(String action) async {
    // save entry in a table
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final elapsed = timeElapsed.elapsed;

    // find the action in the table
    ActionEntry entry;
    actionTable.forEach((key, value) {
      if (value.action == action && !value.durationComplete)
        entry = value;
    });
    if (entry == null) {
      // add to the table
      actionTable[elapsed] =
          ActionEntry(action: action, startDateTime: time,
              startTime: elapsed, durationComplete: false);

      // Record location data
      Location location = new Location();
      print("starttime: " + elapsed.inSeconds.toString());
      LocationData myLocation = await location.getLocation();
      // set location after time because location is not synchronous
      actionTable[elapsed].location = myLocation;
    } else {
      entry.durationComplete = true;
      entry.endTime = timeElapsed.elapsed;
      print("Endtime: " + entry.endTime.inSeconds.toString());
      entry.endDateTime = time;
    }
  }

  /// Stops all duration actions if there are any still running when
  /// the user stops recording video.
  void stopAllDurationActions() {
    actionTable.forEach((key, value) {
      if (value.durationComplete == false) {
        final time = DateTime.now().toIso8601String().substring(11, 19);
        value.durationComplete = true;
        value.endTime = timeElapsed.elapsed;
        print("End time: " + value.endTime.inSeconds.toString());
        value.endDateTime = time;
      }
    });
  }

  /// Gets the action associated with the string name
  /// Parameters: The string name of the action to find
  /// Returns: The action entry object found or null if no match was found
  ActionEntry getAction(String action) {
    var entry;
    actionCount.forEach((element) {
      if (element.action == action) {
        entry = element;
      }
    });
    return entry;
  }

  /// Find the action in the table and it's running status
  /// Parameters: The string name of the action to find
  /// Returns: True if the action is still running, false otherwise
  bool isActionRunning(String name) {
    bool result = false;
    actionTable.forEach((key, value) {
      if (value.action == name && !value.durationComplete) {
        result = true;
      }
    });
    return result;
  }

  /// Clear the action count list
  void clearActionCount() {
    actionCount.clear();
  }

}