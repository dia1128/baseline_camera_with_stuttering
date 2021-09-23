/*
  Created By: Nathan Millwater
  Description: Holds logic for manipulating the AWS authentication repository
 */


import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:camera_app/auth/auth_credentials.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AuthRepository {

  /// Searches the user attributes for the user ID
  /// Returns: the userID String from AWS Auth
  Future<String> getUserIdFromAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      // The userID is found from searching the attributes with the "sub"
      // keyword
      final userId = attributes
          .firstWhere((element) => element.userAttributeKey == 'sub')
          .value;
      return userId;
    } catch (e) {
      throw e;
    }
  }

  /// Gets the current username
  /// Returns: the username of the current authenticated user
  Future<String> getUsername() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      //print(user.username);
      return user.username;
    } catch (e) {
      throw e;
    }
  }

  /// Attempts to read the file which specifies if the user has asked
  /// to remember their session
  /// Returns: Future string of the remember session value the user chose
  Future<String> readRememberSession() async {
    try {
      // the directory of the app's files
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      // The file name specified in the LoginView class
      File file = File('$path/rememberSession.txt');

      return file.readAsString();
    } catch (e) {
      print(e.toString());
      return "";
    }

  }

  /// Attempts to auto login the user
  /// Returns: A future Auth credentials object if successfully
  /// auto logged in. Otherwise sign the user out
  Future<AuthCredentials> attemptAutoLogin() async {
    // If user asked to remember the session
    if (await readRememberSession() == "true") {
      try {
        // Get current user and ID
        final session = await Amplify.Auth.fetchAuthSession();
        final username = await getUsername();
        final userId = await getUserIdFromAttributes();

        return session.isSignedIn ? (AuthCredentials(
            username: username, userId: userId)) : null;
      } catch (e) {
        throw e;
      }
    } else {
        // This is specifically for social sign out. Users can cancel the sign out
        // so we will loop until they eventually sign out
        bool result;
        do {
          result = await this.signOut();
        } while (!result);

      return null;
    }
  }

  /// Sends an API request to login the user
  /// Parameters: The user's username and password from form field
  /// Returns: A future string userId if successfully logged in
  Future<String> login({
    @required String username,
    @required String password,
  }) async {
    try {
      // send login command to AWS
      final result = await Amplify.Auth.signIn(
        username: username.trim(),
        password: password.trim(),
      );

      return result.isSignedIn ? (await getUserIdFromAttributes()) : null;
    } catch (e) {
      throw (e);
    }
  }

  /// Sends an API request to create a new user account
  /// Parameters: The user's username, email, and password from form field
  /// Returns: A future boolean true if sign up is successful
  Future<bool> signUp({
    @required String username,
    @required String email,
    @required String password,
  }) async {
    // Store the email in a SignUpOptions object
    final options = CognitoSignUpOptions(userAttributes: {'email': email.trim()});
    try {
      // send sign up command to AWS
      final result = await Amplify.Auth.signUp(
        username: username.trim(),
        password: password.trim(),
        options: options,
      );
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  /// All users must confirm their signup by entering a confirmation code
  /// sent to their email unless they use social media login. This function
  /// Parameters: The user's username, and confirmation code
  /// Returns: A future boolean true if confirmation was successful
  Future<bool> confirmSignUp({
    @required String username,
    @required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username.trim(),
        confirmationCode: confirmationCode.trim(),
      );
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  /// Attempts to sign the user out of the current session
  /// Returns: A future boolean true if the user sign out was
  /// successful. It can fail if signing out with a social media account
  Future<bool> signOut() async {
    try {
      await Amplify.Auth.signOut();
      // sign out succeeded
      return true;
    } on AuthException catch (e) {
      // sign out failed
      print(e.message);
      return false;
    }
  }
}
