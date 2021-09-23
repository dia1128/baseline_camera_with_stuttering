/*
  Created By: Nathan Millwater
  Description: Represents a the action catalog. Holds information related
               to the model
 */

import 'dart:io';
import 'dart:math';

import 'package:camera_app/actions/edit_action.dart';
import 'package:camera_app/camera_example_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_store/json_store.dart';

/// A class representing a model of the action catalog. Holds the list
/// of items that the user can select from
class CatalogModel {

  // constructor
  CatalogModel();
  // the catalog data structure
  List<Item> catalog;
  static var deviceID;
  final jsonStore = JsonStore();

  // a list of strings which are the default action names
  static List<String> itemNames = [
    'Running',
    'Speaking',
    'Yelling',
    'Sitting',
    'Standing',
    'Walking',
    'Jumping',
    'Sleeping',
    'Talking',
    'Hiding',
    'Crying',
    'Happy',
    'Sad',
  ];

  /// Generates a unique ID integer between 0 and 10000
  /// Returns: The generated id
  int uniqueID() {
    final rng = Random();
    bool equal;
    int id;
    do {
      id = rng.nextInt(10000);
      equal = false;
      for (Item item in catalog) {
        if (item.id == id) {
          equal = true;
          break;
        }
      }
    } while (equal);
    return id;
  }

  /// initialize the default model with default names
  initializeDefaultModel() {
    catalog = [];
    for (int i = 0; i < itemNames.length; i++) {
      int temp = uniqueID();
      final item =
        Item(id: temp, name: itemNames[i], actionType: ActionType.frequency);
      catalog.add(item);
    }
  }

  /// returns the catalog object
  List<Item> getCatalog() => catalog;

  /// add the item to the catalog
  void addToCatalog(Item item) {
    this.catalog.add(item);
  }

  /// remove the item from the catalog
  void removeFromCatalog(Item item) {
    this.catalog.remove(item);
  }

  /// Get item by [id].
  Item getById(int id) => catalog[id];

  /// returns the length of the catalog
  int getLength() => catalog.length;

  /// Get item by its position in the catalog.
  Item getByPosition(int position) {
    // In this simplified case, an item's position in the catalog
    // is also its id.
    return getById(position);
  }

  /// Stores the device id in a static variable
  /// It is called in the camera_navigator file
  /// Returns: A future object indicating an asynchronous function
  static Future<void> getDeviceID() async {
    try {
      if (Platform.isAndroid) {
        final info = await CameraExampleHomeState.deviceInfoPlugin.androidInfo;
        deviceID = info.id;
      } else {
        final info = await CameraExampleHomeState.deviceInfoPlugin.iosInfo;
        deviceID = info.identifierForVendor;
      }
    } on PlatformException {
      deviceID = "Failed to get deviceID";
    }
  }

  /// Saves the current state of the catalog in device storage
  /// in a json format.
  /// Returns: A future object indicating an asynchronous function
  Future<void> saveCatalogModel() async {
    // clear the database first
    await jsonStore.clearDataBase();
    // start the batch to store the items in device storage
    final batch = await jsonStore.startBatch();
    await Future.forEach(catalog, (item) async {
      await jsonStore.setItem(
        '$deviceID-${item.id}',
        item.toJson(),
        batch: batch,
      );
    });
    // finally store the batch in a json object
    jsonStore.commitBatch(batch);
  }

}

/// A class to represent an item in the action catalog
class Item {
  int id;
  String name;
  Color color;
  String description;
  ActionType actionType;

  Item({this.id, this.name, this.color, this.description, this.actionType}) {
    // To make the items look nicer, each item is given one of the
    // Material Design primary colors.
    if (id != null && color == null) {
      color = Colors.primaries[id % Colors.primaries.length];
    }
  }

  /// Parse the object to a json format which is a map
  /// of string to a dynamic type. The dynamic type must
  /// be a primative data type
  /// Returns: the parsed json data structure
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id' : id,
      'name' : name,
      'color' : color.value,
      'description' : description,
      'action type' : actionType.toString(),
    };
    return json;
  }

  /// Initializes this object from a json file
  /// Parameters: the json data structure which holds the
  /// item information
  Item.fromJson(Map<String, dynamic> json) {
    ActionType type;
    this.id = json['id'];
    this.name = json['name'];
    this.color = Color(json['color']);
    this.description = json['description'];
    this.actionType = type.fromString(json['action type']);
  }

  @override
  int get hashCode => id;

  /// operator overloading for checking if two objects are equal
  @override
  bool operator ==(Object other) => other is Item && other.id == id;
}
