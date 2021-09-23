/*
  Created By: Nathan Millwater
  Description: A class to represent a set of credentials with a username,
               email, and password
 */

import 'package:flutter/cupertino.dart';

/// Represents user credentials
class AuthCredentials {
  final String username;
  final String email;
  final String password;
  String userId;

  AuthCredentials({
    @required this.username,
    this.email,
    this.password,
    this.userId,
  });

}