/*
  Created By: Nathan Millwater
  Description: Holds the logic for handling sign up events
 */


import 'package:camera_app/auth/sign_up/sign_up_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';

/// Holds the logic for handling the event and changing the state
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  // constructor
  SignUpBloc({this.authRepo, this.authCubit}) : super(SignUpState());

  /// This function maps a SignUpEvent to a SignUpState
  /// Parameters: A sign up event that needs to be handled
  /// Returns: An updated SignUpState according to the sign up event
  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    // Username updated
    if (event is SignUpUsernameChanged) {
      yield state.copyWith(username: event.username);

      // Email updated
    } else if (event is SignUpEmailChanged) {
      yield state.copyWith(email: event.email);

      // Password updated
    } else if (event is SignUpPasswordChanged) {
      yield state.copyWith(password: event.password);

      // Form submitted
    } else if (event is SignUpSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        await authRepo.signUp(
          username: state.username,
          email: state.email,
          password: state.password,
        );
        // copy over new form status if signup succeeds
        yield state.copyWith(formStatus: SubmissionSuccess());

        // show the confirmation view with the user's credentials
        authCubit.showConfirmSignUp(
          username: state.username,
          email: state.email,
          password: state.password,
        );
      } catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    }
  }
}
