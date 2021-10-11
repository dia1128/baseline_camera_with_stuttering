import 'dart:convert' show utf8;
import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera_app/stuttering/passage.dart';
import 'package:camera_app/stuttering/survey.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../camera_navigator.dart';
import '../main.dart';
import 'background_questions.dart';

class HomeNavigation extends StatelessWidget {

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
                      onPressed: () async{

                        String id;
                        bool check;

                        getID().then((value){
                          id = value.toString(); //This is how we store a future returned value. That is the device ID here.
                          print("Device ID: " + id.toString());

                        });

                        var data = await downloadPassages() as List;
                        //print(data.length());

                        getURL().then((directory){ //get S3 directory named on device name
                          print("Existing Devices:" + directory.toString());
                          check = directory.contains(id);
                          print("Check " + check.toString());

                          ///if device id already exists as a directory name in s3 we users will go to passage reading screen directly
                          ///Otherwise a background questioner will prompt in a new new screen
                          if(directory.contains(id) == true){
                            Navigator.push(

                                context,
                                MaterialPageRoute(builder: (context) => ReadPassage(deviceID: id, passageContent: data.toList()))
                            );
                          }
                          else{
                            Navigator.push(

                                context,
                                MaterialPageRoute(builder: (context) => SurveyNew ())
                            );
                          }
                        });
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
  ///Collecting the folder name
  ///All unique name with one extra file of questions which doesn't matter
  static Future<List<String>> getURL() async {
    List<String> objects = [];
    try {
      final ListResult result = await Amplify.Storage.list();
      String folder;
      //final documentDir = await getApplicationDocumentsDirectory();
      result.items.forEach((element) {

        folder = element.key.toString().split("/").first;
        if(objects.contains(folder) == false)
          objects.add(folder.toString());
      });

      return objects;
    } on StorageException catch (e) {
      print('Error listing items: $e');
    }
  }

  ///Collecting device ID
  Future<String> getID() async {

    String deviceId = await PlatformDeviceId.getDeviceId;

    return deviceId.toString();

  }
  ///Download files from aws, create a temporary csv file
  ///create a list from the file and return the list
  Future downloadPassages() async {
    // Create a file to store downloaded contents
    final documentsDir = await getApplicationDocumentsDirectory();
    //final filepath = documentsDir.path + '/example.csv';
    final filepath = documentsDir.path + '/passages.csv';
    final file = File(filepath);
    List fields = [];


    // Set access level and Cognito Identity ID.
    // Note: `targetIdentityId` is only needed when downloading
    // protected files of a user other than the one currently
    // logged in.
    final downloadOptions = S3DownloadFileOptions(
      accessLevel: StorageAccessLevel.guest,
    );

    // Download gues file and read contents
    try {
      await Amplify.Storage.downloadFile(
        key: 'passages.csv',
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
}