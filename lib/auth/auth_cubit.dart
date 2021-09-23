/*
  Created By: Nathan Millwater
  Description: Holds the logic for changing auth states. Emits
               states to show different pages
 */

import 'package:flutter_bloc/flutter_bloc.dart';

import '../session_cubit.dart';
import 'auth_credentials.dart';

/// Simple enumeration to show different auth states
enum AuthState { login, signUp, confirmSignUp }

/// Holds the logic for changing and handling auth states
class AuthCubit extends Cubit<AuthState> {

  final SessionCubit sessionCubit;
  AuthCubit({this.sessionCubit}) : super(AuthState.login);
  AuthCredentials credentials;

  // emits login and signup to change to those pages
  void showLogin() => emit(AuthState.login);
  void showSignUp() => emit(AuthState.signUp);

  /// Stores credentials and emits the state once confirmation is complete
  /// Parameters: The user's username, email, and password
  void showConfirmSignUp({
    String username,
    String email,
    String password,
  }) {
    credentials = AuthCredentials(
      username: username,
      email: email,
      password: password,
    );
    emit(AuthState.confirmSignUp);
  }

  /// Launch the session by calling the showSession method
  /// on the session cubit
  /// Parameters: A credentials object that holds user information
  void launchSession(AuthCredentials credentials) =>
      sessionCubit.showSession(credentials);
}
