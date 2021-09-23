/*
  Created By: Nathan Millwater
  Description: Holds the logic for handling confirmation events
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_cubit.dart';
import '../auth_repository.dart';
import '../form_submission_status.dart';
import 'confirmation_state.dart';


/// Holds the logic for handling the event and changing the state
class ConfirmationBloc extends Bloc<ConfirmationEvent, ConfirmationState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  // constructor
  ConfirmationBloc({
    this.authRepo,
    this.authCubit,
  }) : super(ConfirmationState());

  /// This function maps a ConfirmationEvent to a ConfirmationState
  /// Parameters: A confirmation event that needs to be handled
  /// Returns: An updated ConfirmationState according to the confirmation event
  @override
  Stream<ConfirmationState> mapEventToState(ConfirmationEvent event) async* {
    // Confirmation code updated
    if (event is ConfirmationCodeChanged) {
      yield state.copyWith(code: event.code);

      // Form submitted
    } else if (event is ConfirmationSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        await authRepo.confirmSignUp(
          username: authCubit.credentials.username,
          confirmationCode: state.code,
        );

        // copy over new form status if signup succeeds
        yield state.copyWith(formStatus: SubmissionSuccess());

        // get credentials from the sign up view
        final credentials = authCubit.credentials;
        // login with the credentials
        final userId = await authRepo.login(
          username: credentials.username,
          password: credentials.password,
        );
        credentials.userId = userId;

        authCubit.launchSession(credentials);
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    }
  }
}
