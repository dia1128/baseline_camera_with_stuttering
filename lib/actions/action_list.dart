/*
  Created By: Nathan Millwater
  Description: The selected actions widget tree.
 */

import 'package:camera_app/actions/action_catalog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../camera_cubit.dart';
import '../models/cart_model.dart';

/// This class holds the widget tree for displaying the current
/// selected actions.
class MyCart extends StatelessWidget {

  /// standard build method
  @override
  Widget build(BuildContext context) {
    int maxItems = AddButton.NUMBER_OF_ACTION_BUTTONS;
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Actions'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 25),
            Text("The max number of actions selected is: "+maxItems.toString(),
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: CartList(),
              ),
            ),
            const Divider(height: 4, color: Colors.black),
          ],
        ),
      ),
      // navigation bar for changing between pages
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
        currentIndex: 1,
        onTap: (index) {
          changePage(index, context);
        },
      ),
    );
  }
}

/// Decide which navigation page to show next depending on the index
/// chosen in the navigation bar
/// Parameters: The index of the page chosen and the current build
/// context which gives access to the camera cubit
void changePage(int index, BuildContext context) {
  if (index == 0)
    context.read<CameraCubit>().showActionCatalog();
  else if (index == 2)
    context.read<CameraCubit>().showHome();
}

/// The list widget that displays the currently selected actions
class CartList extends StatelessWidget {

  /// standard build method
  @override
  Widget build(BuildContext context) {
    var itemNameStyle = Theme.of(context).textTheme.headline6;
    // This gets the current state of CartModel and also tells Flutter
    // to rebuild this widget when CartModel notifies listeners (in other words,
    // when it changes).
    var cart = context.watch<CartModel>();
    var items = cart.items.length;

    // only if there are actions selected
    if (items != 0)
    return ListView.builder(
      itemCount: items,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.done),
        subtitle: SizedBox(height: 10,
            child: Container(color: cart.items[index].color)),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            cart.remove(cart.items[index]);
          },
        ),
        title: Text(
          cart.items[index].name,
          style: itemNameStyle,
        ),
      ),
    );
    else
      return Text("No Actions Currently Selected", style: TextStyle(fontSize: 18),);
  }
}