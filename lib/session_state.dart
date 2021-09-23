/*
  Created By: Nathan Millwater
  Description: Classes to represent different states the session can have
 */

import 'package:camera_app/models/user.dart';
import 'package:flutter/material.dart';


abstract class SessionState {}

/// Unknown state when app is configuring
class UnknownSessionState extends SessionState {}

/// Represents the unauthenticated state. Changes the navigator to show
/// the login view
class Unauthenticated extends SessionState {}

/// Represents the state when the user has logged in. Changes the navigator
/// to show the camera app home screen
class Authenticated extends SessionState {
  // Authenticated requires a user to be defined
  final User user;

  Authenticated({@required this.user});
}