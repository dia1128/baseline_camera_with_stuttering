/*
  Created By: Nathan Millwater
  Description: Holds the logic for changing session states. Emits
               states to change layout of widgets
 */

import 'package:camera_app/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/auth_credentials.dart';
import 'auth/auth_repository.dart';
import 'session_state.dart';

/// Holds the logic for handling and changing session states
class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;

  // Constructor
  SessionCubit({
    @required this.authRepo,
  }) : super(UnknownSessionState()) {
    // TODO reenable for auth access
    //attemptAutoLogin();
  }

  /// Try and fetch fetch the current session and login
  void attemptAutoLogin() async {
    try {
      final credentials = await authRepo.attemptAutoLogin();
      if (credentials == null) {
        throw Exception('User not logged in');
      }

      // Create user object to store credentials
      User user = User(id: credentials.userId, username: credentials.username);
      emit(Authenticated(user: user));
    } on Exception {
      // Emit unauthenticated state if login failed
      emit(Unauthenticated());
    }
  }

  /// Changes the navigator to show login screen
  void showAuth() => emit(Unauthenticated());

  /// Uses credentials to show the camera home screen by emitting authenticated state
  /// Parameters: credentials object that hold the user's information
  void showSession(AuthCredentials credentials) async {
    try {
      User user = User(id: credentials.userId, username: credentials.username);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  /// Attempt to sign out of the current account. If sign out failed,
  /// don't change states
  void signOut() async {
    bool result = await authRepo.signOut();

    // if sign out failed emit unauthenticated
    if (result) {
      emit(Unauthenticated());
      print("Unauthenticated");
    }
  }

}
