/*
  Created By: Nathan Millwater
  Description: Holds all of the widgets that makeup the login screen
 */

import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';
import 'login_bloc.dart';
import 'login_state.dart';

/// Holds the login view widget tree
class LoginView extends StatefulWidget {

  // create the login view state
  @override
  LoginViewState createState() => LoginViewState();
}

/// The state class which holds the widget tree
class LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool rememberSession = false;
  bool showIcon = false;

  // called when state initializes
  @override
  void initState() {
    super.initState();
    storeRememberSession();
    // set preferred orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Chooses an appbar based on the platform
  /// Parameters: A title string for the text on the appbar
  /// Returns: An appbar widget
  Widget chooseAppBar(String title) {
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

  /// Initial build method of the stateful widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // login view appbar
      appBar: chooseAppBar("Login"),
      backgroundColor: Colors.cyan[200],
      // bloc provider to provide access to auth cubit and repository
      body: BlocProvider(
        create: (context) => LoginBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            loginForm(),
            showSignUpButton(context),
            // display the camera icon
            Padding(
              padding: const EdgeInsets.only(bottom: 560),
              child: showIcon ? Icon(Icons.camera_alt, size: 200, color: Colors.grey[600],) : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Holds the widget tree for the different form fields
  /// Returns: The form widget
  Widget loginForm() {
    // A Listener to show error if one occurs
    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            if (formStatus.exception is UserNotFoundException
                || formStatus.exception is NotAuthorizedException) {
              showSnackBar(context, "Invalid Username or Password");
            } else if (formStatus.exception is UnknownException) {
              showSnackBar(context, "Something went wrong, ensure you are connected"
                  " to the internet");
            } else {
              showSnackBar(context, formStatus.exception.toString());
            }
            // set back to initial state once error occurs
            state.formStatus = InitialFormStatus();
          }
        },
        // form widget holds all text fields
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //_googleLogin(),
                //facebookLogin(),
                usernameField(),
                passwordField(),
                // spacing
                SizedBox(height: 5,),
                loginButton(),
                checkBox(),

              ],
            ),
          ),
        ));
  }


  /// Stores the user's decision to remember the session
  /// Returns: A checkbox widget
  Widget checkBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 85),
      child: CheckboxListTile(
          secondary: Text("Remember Me"),
          controlAffinity: ListTileControlAffinity.leading,
          value: rememberSession,
          onChanged: (bool changed) {
            // When box is tapped, change the state of the
            // boolean value
            setState(() {
              rememberSession = changed;
            });
            // save info on device
            storeRememberSession();
          }
      ),
    );
  }

  /// Store the value from the remember session checkbox
  /// in the device's files
  /// Returns: A future object that indicates an asynchronous function
  Future<void> storeRememberSession() async {
    // get the app's storage directory
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    // The file name specified in the AuthRepository class
    File file = File('$path/rememberSession.txt');
    file.writeAsString(rememberSession.toString());
  }

  /// Holds the widget tree for the google login button
  /// Returns: A google login button widget
  Widget _googleLogin() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextButton(
        onPressed: () => context.read<LoginBloc>().add(LoginGoogle()),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Image(
                    image: AssetImage("assets/google.png"),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Sign In with Google",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Holds the widget tree for the button that activates the login to Facebook
  /// Returns: A button widget
  Widget facebookLogin() {
    // provide access to login bloc and login state
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextButton(
        // When tapped, activate the LoginFacebook event
        onPressed: () => context.read<LoginBloc>().add(LoginFacebook()),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Facebook image
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Image(
                    image: AssetImage("assets/facebook.png"),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Sign In with Facebook",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Holds widget tree for the username field
  /// Returns: A text field widget
  Widget usernameField() {
    // provide access to login bloc and login state
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Username',
        ),
        // validator boolean tells the form field if the text is valid
        validator: (value) =>
        state.isValidUsername ? null : 'Username is too short',
        // Everytime user changes username, create an event
        onChanged: (value) => context.read<LoginBloc>().add(
          LoginUsernameChanged(username: value),
        ),
        // If text field is tapped, remove camera icon
        onTap: () {setState(() {showIcon = false;});},
        // Show icon again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          //setState(() {showIcon = true;});
        },
      );
    });
  }

  /// Holds the widget tree for the password field
  /// Returns: the password field widget
  Widget passwordField() {
    // provide access to login bloc and login state
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
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
        onChanged: (value) => context.read<LoginBloc>().add(
          LoginPasswordChanged(password: value),
        ),
        // If text field is tapped, remove camera icon
        onTap: () {setState(() {showIcon = false;});},
        // Show icon again once editing is complete
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          //setState(() {showIcon = true;});
        },
      );
    });
  }

  /// Holds the widget tree for the login button and bloc
  /// Returns: The login button widget
  Widget loginButton() {
    // provide access to login bloc and login state
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      // Show wait indicator if form is still submitting
      return state.formStatus is FormSubmitting
          ? CircularProgressIndicator()
          : ElevatedButton(
        onPressed: () {
          // make sure username and password are valid before submitting
          if (_formKey.currentState.validate()) {
            // Create the login submitted event
            context.read<LoginBloc>().add(LoginSubmitted());
          }
        },
        child: SizedBox(
          height: 45,
            width: 80,
            child: Center(child: Text('Login',style: TextStyle(fontSize: 25),))
        ),
      );
    });
  }

  /// Holds the sign up button widget that switches to the sign up page
  /// Returns: The sign up button widget
  Widget showSignUpButton(BuildContext context) {
    return SafeArea(
      child: TextButton(
        child: Text('Don\'t have an account? Sign up.'),
        // tell auth navigator to show signup page
        onPressed: () => context.read<AuthCubit>().showSignUp(),
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
