/*
  Created By: Nathan Millwater
  Description: Holds all of the widgets that makeup the signup screen
 */

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:camera_app/auth/sign_up/sign_up_bloc.dart';
import 'package:camera_app/auth/sign_up/sign_up_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';

/// Holds the signup view widget tree
class SignUpView extends StatefulWidget {

  @override
  SignUpViewState createState() => SignUpViewState();
}

/// The state class which holds the widget tree
class SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  bool showImage = true;

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
      // sign up view appbar
      appBar: chooseAppBar("Sign Up", context),
      backgroundColor: Colors.cyan[200],
      // bloc provider to provide access to auth cubit and repository
      body: BlocProvider(
        create: (context) => SignUpBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            signUpForm(),
            showLoginButton(context),
          ],
        ),
      ),
    );
  }

  /// Holds the widget tree for the different form fields
  /// Returns: The form widget
  Widget signUpForm() {
    // A Listener to show error if one occurs
    return BlocListener<SignUpBloc, SignUpState>(
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
                usernameField(),
                emailField(),
                passwordField(),
                // spacing
                SizedBox(height: 5,),
                signUpButton(),
              ],
            ),
          ),
        ));
  }

  /// Holds widget tree for the username field
  /// Returns: A text field widget
  Widget usernameField() {
    // provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Username',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) =>
        state.isValidUsername ? null : 'Username is too short',
        // Everytime user changes username, create an event
        onChanged: (value) => context.read<SignUpBloc>().add(
          SignUpUsernameChanged(username: value),
        ),
        // If text field is tapped, remove open cloud image
        onTap: () {setState(() {showImage = false;});},
        // Show image again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showImage = true;});
        },
      );
    });
  }

  /// Holds the widget tree for the email field
  /// Returns: the email field widget
  Widget emailField() {
    // Provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Email',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) => state.isValidUsername ? null : 'Invalid email',
        // Everytime user changes email, create an event
        onChanged: (value) => context.read<SignUpBloc>().add(
          SignUpEmailChanged(email: value),
        ),
        // If text field is tapped, remove open cloud image
        onTap: () {setState(() {showImage = false;});},
        // Show image again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showImage = true;});
        },
      );
    });
  }

  /// Holds the widget tree for the password field
  /// Returns: the password field widget
  Widget passwordField() {
    // Provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.security),
          hintText: 'Password',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) =>
        state.isValidPassword ? null : 'Password is too short',
        // Everytime user changes password, create an event
        onChanged: (value) => context.read<SignUpBloc>().add(
          SignUpPasswordChanged(password: value),
        ),
        // If text field is tapped, remove open cloud image
        onTap: () {setState(() {showImage = false;});},
        // Show image again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          setState(() {showImage = true;});
        },
      );
    });
  }

  /// Holds the widget tree for the signup button and bloc
  /// Returns: The signup button widget
  Widget signUpButton() {
    // Provide access to signup bloc and signup state
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      // Show wait indicator if form is still submitting
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
        onPressed: () {
          // make sure username and password are valid before submitting
          if (_formKey.currentState.validate()) {
            // Create the login submitted event
            context.read<SignUpBloc>().add(SignUpSubmitted());
          }
        },
        child: SizedBox(
          height: 45,
          width: 100,
          child: Center(child: Text('Sign Up',style: TextStyle(fontSize: 25),)))
      );
    });
  }

  /// Holds the sign up button widget that switches to the login page
  /// Returns: The login button widget
  Widget showLoginButton(BuildContext context) {
    return SafeArea(
      child: TextButton(
        child: Text('Already have an account? Sign in.'),
        // tell auth navigator to show login page
        onPressed: () => context.read<AuthCubit>().showLogin(),
      ),
    );
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
