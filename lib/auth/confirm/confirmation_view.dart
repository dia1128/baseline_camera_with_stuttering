/*
  Created By: Nathan Millwater
  Description: Holds all of the widgets that makeup the confirmation screen
 */

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';
import 'confirmation_bloc.dart';
import 'confirmation_state.dart';

/// Holds the confirmation view widget tree
class ConfirmationView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  /// Chooses an appbar based on the platform
  /// Parameters: A title string for the text on the appbar
  /// Returns: An appbar widget
  Widget chooseAppBar(String title, BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
      );
    }
    else {
      // android platform
      return AppBar(
        title: Text(title),
      );
    }
  }

  /// Initial build method of the stateless widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // confirmation view appbar
      appBar: chooseAppBar("Confirm Signup", context),
      backgroundColor: Colors.cyan[200],
      // bloc provider to provide access to auth cubit and repository
      body: BlocProvider(
        create: (context) => ConfirmationBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: confirmationForm(),
      ),
    );
  }

  /// Holds the widget tree for the different form fields
  /// Returns: The form widget
  Widget confirmationForm() {
    // A Listener to show error if one occurs
    return BlocListener<ConfirmationBloc, ConfirmationState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            if (formStatus.exception is UnknownException) {
              showSnackBar(context, "Something went wrong, ensure you are connected"
                  " to the internet");
            } else {
              showSnackBar(context, formStatus.exception.toString());
            }
          }
          // set back to initial state once error occurs
          state.formStatus = InitialFormStatus();
        },
        // form widget holds all text fields
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                codeField(),
                // spacing
                SizedBox(height: 5,),
                confirmButton(),
                Text("Note: You must confirm your email address for "
                    "your account to be activated", textAlign: TextAlign.center,),
              ],
            ),
          ),
        ));
  }

  /// Holds widget tree for the confirmation code field
  /// Returns: A text field widget
  Widget codeField() {
    // provide access to confirmation bloc and confirmation state
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(
        builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Confirmation Code',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) =>
            state.isValidCode ? null : 'Invalid confirmation code',
        // Every time the user changes the code, create an event
        onChanged: (value) => context.read<ConfirmationBloc>().add(
              ConfirmationCodeChanged(code: value),
            ),
      );
    });
  }

  /// Holds the widget tree for the confirm button and bloc
  /// Returns: The confirm button widget
  Widget confirmButton() {
    // provide access to confirmation bloc and confirmation state
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(builder: (context, state) {
          // Show wait indicator if form is still submitting
          return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () {
                // make sure code is valid before submitting
                if (_formKey.currentState.validate()) {
                  // create the confirmation submitted event
                  context.read<ConfirmationBloc>().add(ConfirmationSubmitted());
                }
              },
              child: SizedBox(
                height: 45,
                width: 100,
                child: Center(child: Text('Confirm',style: TextStyle(fontSize: 25),))
              ),
            );
    });
  }

  /// Takes in a BuildContext and message and displays a snackbar
  /// at the bottom of the screen
  /// Parameters: the context of the current build and a String
  /// message to display in the snackbar
  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
