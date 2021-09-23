/*
  Created By: Nathan Millwater
  Description: Holds the logic for navigating between different screens
               within the camera session
 */


import 'package:camera_app/actions/action_catalog.dart';
import 'package:camera_app/camera_example_home.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/stuttering/stuttering_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_store/json_store.dart';
import 'package:provider/provider.dart';

import 'actions/action_list.dart';
import 'camera_cubit.dart';
import 'models/cart_model.dart';
import 'models/catalog_model.dart';



/// Camera Navigator widget that handles navigation between the camera home
/// screen, selected actions, and action catalog
class CameraNavigator extends StatelessWidget {

  // This is the location of the home screen and catalog model objects
  final home = CameraExampleHome(username: "do not use");
  final cameraHome = HomeNavigation();
  final catalogModel = CatalogModel();
  // get access to the json storage object
  final jsonStore = JsonStore();

  // constructor, setup model by loading the catalog
  CameraNavigator() {
    loadCatalogFromStorage();
  }

  /// Attempts to load the action catalog saved on the device
  /// If this fails, initialize a new catalog model with default
  /// action names and colors
  void loadCatalogFromStorage() async {
    // jsonStore.clearDataBase();
    // Get the device ID
    await CatalogModel.getDeviceID();
    final deviceID = CatalogModel.deviceID;
    // load the json file
    List<Map<String, dynamic>> json = await jsonStore.getListLike('$deviceID%');
    // if null or empty, load the default values
    if (json == null || json.isEmpty) {
      print('default model');
      catalogModel.initializeDefaultModel();
    // read from the json file
    } else {
      print('read from storage');
      final items = json.map((item) => Item.fromJson(item)).toList();
      catalogModel.catalog = items;
    }
  }

  /// standard build method that creates the widget tree
  @override
  Widget build(BuildContext context) {
    // use a bloc provider to provide access to the camera cubit and state object
    return BlocBuilder<CameraCubit, CameraState> (builder: (context, state) {
      return MultiProvider(
          providers: [
            // In this app, CatalogModel never changes, so a simple Provider
            // is sufficient.
            Provider(create: (context) => catalogModel),
            // CartModel is implemented as a ChangeNotifier, which calls for the use
            // of ChangeNotifierProvider. Moreover, CartModel depends
            // on CatalogModel, so a ProxyProvider is needed.
            ChangeNotifierProxyProvider<CatalogModel, CartModel>(
              create: (context) => CartModel(),
              update: (context, catalog, cart) {
                if (cart == null) throw ArgumentError.notNull('cart');
                cart.catalog = catalog;
                return cart;
              },
            ),
          ],
          // list the pages to navigate between
          child: Navigator(
            pages: [
              if (state == CameraState.actionList)
                MaterialPage(child: MyCart()),
              if (state == CameraState.actionCatalog)
                MaterialPage(child: MyCatalog()),
              if (state == CameraState.home)
                MaterialPage(child: home),
              if (state == CameraState.stuttering)
                MaterialPage(child: cameraHome)




            ],
            onPopPage: (route, result) => route.didPop(result),
          )
      );
    });
  }
}
