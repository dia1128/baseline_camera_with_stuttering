/*
  Created By: Nathan Millwater
  Description: Holds the current state of the sign up form. Includes
               the current username, email, and password with the form
               submission status
 */

import '../form_submission_status.dart';



abstract class SignUpEvent {}

/// Event when user changes the text in the username field
class SignUpUsernameChanged extends SignUpEvent {
  final String username;

  SignUpUsernameChanged({this.username});
}

/// Event when user changes the text in the email field
class SignUpEmailChanged extends SignUpEvent {
  final String email;

  SignUpEmailChanged({this.email});
}

/// Event when user changes the text in the password field
class SignUpPasswordChanged extends SignUpEvent {
  final String password;

  SignUpPasswordChanged({this.password});
}

/// Event when the sign up button is pressed
class SignUpSubmitted extends SignUpEvent {}



/// Holds the current state of the sign up form
class SignUpState {
  final String username;
  // getter
  bool get isValidUsername => username.length > 3;

  final String email;
  // getter
  bool get isValidEmail => email.contains('@');

  final String password;
  // getter
  bool get isValidPassword => password.length > 8;

  FormSubmissionStatus formStatus;

  SignUpState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  /// Create a new SignUpState object and copy over the
  /// old values and any new values that changed
  /// Parameters: The username, email and password from
  /// sign up form field and the current status of the form
  /// Returns: A new sign up state with the updated information
  SignUpState copyWith({
    String username,
    String email,
    String password,
    FormSubmissionStatus formStatus,
  }) {
    return SignUpState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}


