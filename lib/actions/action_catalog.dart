/*
  Created By: Nathan Millwater
  Description: The action catalog widget tree. Users can modify,
               remove, or add their own actions to the catalog
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../camera_cubit.dart';
import '../models/cart_model.dart';
import '../models/catalog_model.dart';
import 'edit_action.dart';
import 'package:json_store/json_store.dart';

/// Create a stateful widget to hold the catalog
class MyCatalog extends StatefulWidget {

  @override
  MyCatalogState createState() => MyCatalogState();
}

/// The state of the catalog widget
class MyCatalogState extends State<MyCatalog> {

  final jsonStore = JsonStore();

  /// Standard build method of the widget
  @override
  Widget build(BuildContext context) {
    // monitor the catalog for changes
    var catalog = context.watch<CatalogModel>();
    return Scaffold(
      // The scroll view includes the appbar and a spacer at the bottom
      body: CustomScrollView(
        slivers: [
          MyAppBar(),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                    (context, index) => MyListItem(index, this),
              childCount: catalog.getLength()
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 70))
        ],
      ),
      // navigator bar to switch between pages
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize),
              label: "Action Catalog"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions),
              label: "Current Actions"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          )
        ],
        currentIndex: 0,
        onTap: (index) {
          changePage(index, context);
        },
      ),
      // button to add actions to the catalog
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onAddActionButtonPressed(catalog);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  /// Displays the dialog box for adding a new action to the catalog
  /// Parameters: The catalog model to save the new action to
  /// Returns: A future object indicating an asynchronous function
  Future<void> onAddActionButtonPressed(CatalogModel catalog) async {
    Item item = await showDialog(context: context, builder: (BuildContext context) {
      // custom edit action widget
      return EditAction();
    });
    // create the id for the item
    if (item != null) {
      item.id = catalog.uniqueID();
      catalog.addToCatalog(item);
      updateUI();
      // save to device storage
      catalog.saveCatalogModel();
    }
  }

  /// Tell flutter to update the widget tree when needed
  void updateUI() {
    setState(() {});
  }

  /// Decide which navigation page to show next depending on the index
  /// chosen in the navigation bar
  /// Parameters: The index of the page chosen and the current build
  /// context which gives access to the camera cubit
  void changePage(int index, BuildContext context) {
    if (index == 1)
      context.read<CameraCubit>().showActionList();
    else if (index == 2)
      context.read<CameraCubit>().showHome();
  }
}

/// The add button widget which allows the user to add the action
/// to the selected actions page.
class AddButton extends StatelessWidget {
  final Item item;
  // max number of actions that can be selected at one time
  static const NUMBER_OF_ACTION_BUTTONS = 9;

  const AddButton({@required this.item});

  @override
  Widget build(BuildContext context) {
    // The context.select() method will let you listen to changes to
    // a *part* of a model. You define a function that "selects" (i.e. returns)
    // the part you're interested in, and the provider package will not rebuild
    // this widget unless that particular part of the model changes.
    //
    // This can lead to significant performance improvements.
    var isInCart = context.select<CartModel, bool>(
      // Here, we are only interested whether [item] is inside the cart.
          (cart) => cart.items.contains(item),
    );
    var items = context.watch<CartModel>().items.length;

    return TextButton(
      onPressed: isInCart || items >= NUMBER_OF_ACTION_BUTTONS
          ? null
          : () {
        // If the item is not in cart, we let the user add it.
        // We are using context.read() here because the callback
        // is executed whenever the user taps the button. In other
        // words, it is executed outside the build method.
        var cart = context.read<CartModel>();
        cart.add(item);
      },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).primaryColor;
          }
          return null; // Defer to the widget's default.
        }),
      ),
      child: isInCart
          ? const Icon(Icons.check, semanticLabel: 'ADDED')
          : const Text('ADD'),
    );
  }
}

/// Simple appbar widget
class MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Action Catalog'),
      floating: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          // navigate to the home page
          onPressed: () => context.read<CameraCubit>().showHome(),
        ),
      ],
    );
  }
}

/// The list item widget on the catalog page
class MyListItem extends StatelessWidget {
  final int index;
  final MyCatalogState state;

  const MyListItem(this.index, this.state);

  // standard build method
  @override
  Widget build(BuildContext context) {
    var item = context.select<CatalogModel, Item>(
      // Here, we are only interested in the item at [index]. We don't care
      // about any other change.
          (catalog) => catalog.getByPosition(index),
    );
    var textTheme = Theme.of(context).textTheme.headline6;
    var catalog = context.watch<CatalogModel>();
    var cart = context.watch<CartModel>();

    // Users can remove items from the catalog
    return Dismissible(
      // unique key
      key: UniqueKey(),
      onDismissed: (direction) {
        // remove item if it is in the cart
        if (cart.items.contains(item))
          cart.remove(item);
        catalog.removeFromCatalog(item);
        // let flutter know the ui has changed
        state.updateUI();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${item.name} Removed')));
        // save the model to device storage
        catalog.saveCatalogModel();
      },
      background: Container(color: Colors.red),

      // we wrap the entire list tile in a button so the user can
      // edit it
      child: TextButton(
        onLongPress: () {editActionPressed(context, item, catalog);},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: LimitedBox(
            maxHeight: 48,
            child: Row(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(item.name, style: textTheme),
                ),
                Text(item.actionType == ActionType.frequency ?
                item.actionType.toShortString() : item.actionType.toShortString() + '   ',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
                const SizedBox(width: 24),

                AddButton(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show the edit action dialog box to change the action's attributes
  /// Parameters: The build context to display the dialog onto, the item
  /// being modified, and the catalog model to save to
  /// Returns: A future object indicating an asynchronous function
  Future<void> editActionPressed(BuildContext context, Item item, CatalogModel model) async {
    await showDialog(context: context, builder: (BuildContext context) {
      return EditAction(action: item);
    });
    state.updateUI();
    model.saveCatalogModel();
  }

  /// Simple method to display a snackbar
  /// Parameters: The build context to display the snackbar on and
  /// the message to show in the snackbar
  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}