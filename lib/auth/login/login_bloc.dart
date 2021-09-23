/*
  Created By: Nathan Millwater
  Description: Holds the logic for handling login events
 */

import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_credentials.dart';
import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';
import 'login_state.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:camera_app/auth/auth_credentials.dart';

/// Holds the logic for handling the event and changing the state
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  // constructor
  LoginBloc({this.authRepo, this.authCubit}) : super(LoginState());

  /// This function maps a LoginEvent to a LoginState
  /// Parameters: A login event that needs to be handled
  /// Returns: An updated LoginState according to the login event
  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // Username updated
    if (event is LoginUsernameChanged) {
      yield state.copyWith(username: event.username);

      // Password updated
    } else if (event is LoginPasswordChanged) {
      yield state.copyWith(password: event.password);

      // Form submitted
    } else if (event is LoginSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        final userId = await authRepo.login(
          username: state.username,
          password: state.password,
        );
        // copy over new form status if login succeeds
        yield state.copyWith(formStatus: SubmissionSuccess());

        // start the camera home view with the user's credentials
        authCubit.launchSession(AuthCredentials(
          username: state.username,
          userId: userId,
        ));
      } catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }

      // Facebook login event
    } else if (event is LoginFacebook) {
      print("facebook event");
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        // Use AWS social media signin options
        await Amplify.Auth.signInWithWebUI(provider: AuthProvider.facebook);

        // copy over new form status if login succeeds
        yield state.copyWith(formStatus: SubmissionSuccess());

        // retrieve user's username and id
        String username = await getUsername();
        String userId = await getUserIdFromAttributes();
        // start the camera home view with the user's credentials
        authCubit.launchSession(AuthCredentials(
          username: username,
          userId: userId,
        ));
      } on AmplifyException catch (e) {
        // Reset form status
        yield state.copyWith(formStatus: InitialFormStatus());
        print(e.message);
      }

      // not currently used
    } else if (event is LoginGoogle) {
      // google login
      print("google event");

      yield state.copyWith(formStatus: FormSubmitting());

      try {
        // Use AWS social media signin options
        await Amplify.Auth.signInWithWebUI(provider: AuthProvider.google);

        // copy over new form status if login succeeds
        yield state.copyWith(formStatus: SubmissionSuccess());

        // retrieve user's username and id
        String username = await getUsername();
        String userId = await getUserIdFromAttributes();
        // start the camera home view with the user's credentials
        authCubit.launchSession(AuthCredentials(
          username: username,
          userId: userId,
        ));
      } on AmplifyException catch (e) {
        // Reset form status
        yield state.copyWith(formStatus: InitialFormStatus());
        print(e.message);
      }
    }
  }

  /// Gets the current username
  /// Returns: the username of the current authenticated user
  Future<String> getUsername() async {
    try {
      final attributes = await Amplify.Auth.getCurrentUser();
      return attributes.username;
    } catch (e) {
      throw e;
    }
  }

  /// Searches the user attributes for the user ID
  /// Returns: the userID String from AWS Auth
  Future<String> getUserIdFromAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final userId = attributes
          .firstWhere((element) => element.userAttributeKey == 'sub')
          .value;
      return userId;
    } catch (e) {
      throw e;
    }
  }
}
