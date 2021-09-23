/*
  Created By: Nathan Millwater
  Description: Holds the current state of the confirmation form. Includes
               the current confirmation code with the form submission status
 */

import '../form_submission_status.dart';


abstract class ConfirmationEvent {}

/// Event when user changes the text in the confirmation code field
class ConfirmationCodeChanged extends ConfirmationEvent {
  final String code;

  ConfirmationCodeChanged({this.code});
}

/// Event when confirm button is pressed
class ConfirmationSubmitted extends ConfirmationEvent {}


/// Holds the current state of the confirmation form
class ConfirmationState {
  final String code;
  // getter
  bool get isValidCode => code.length == 6;

  FormSubmissionStatus formStatus;

  ConfirmationState({
    this.code = '',
    this.formStatus = const InitialFormStatus(),
  });

  /// Create a new ConfirmationState object and copy over the
  /// old values and any new values that changed
  /// Parameters: The confirmation code from the form field and
  /// the current status of the form
  /// Returns: A new confirmation state with the updated information
  ConfirmationState copyWith({
    String code,
    FormSubmissionStatus formStatus,
  }) {
    return ConfirmationState(
      code: code ?? this.code,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
