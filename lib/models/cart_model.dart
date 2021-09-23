/*
  Created By: Nathan Millwater
  Description: Represents the currently selected items. Holds information related
               to the model. Users choose items from the catalog to put into
               their cart.
 */

import 'package:flutter/foundation.dart';

import 'catalog_model.dart';

class CartModel extends ChangeNotifier {
  /// The private field backing [catalog].
  CatalogModel _catalog;

  /// Internal, private state of the cart. Stores the ids of each item.
  final List<Item> items = [];

  /// The current catalog. Used to construct items from numeric ids.
  CatalogModel get catalog => _catalog;

  /// set the catalog model variable to a new model
  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    notifyListeners();
  }

  /// List of items in the cart.
  List<Item> get getItems => items;

  /// Adds [item] to cart. This is the only way to modify the cart from outside.
  /// Parameters: The item being added to the cart
  void add(Item item) {
    items.add(item);
    // This line tells [Model] that it should rebuild the widgets that
    // depend on it.
    notifyListeners();
  }

  /// Removes [item] from the cart.
  /// Parameters: The item being removed from the cart
  void remove(Item item) {
    items.remove(item);
    // Don't forget to tell dependent widgets to rebuild _every time_
    // you change the model.
    notifyListeners();
  }
}