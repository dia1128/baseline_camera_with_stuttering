/*
  Created By: Nathan Millwater
  Description: Classes for holding the status of form submissions
 */

abstract class FormSubmissionStatus {
  const FormSubmissionStatus();
}

/// class representing the initial status. Nothing has occured
class InitialFormStatus extends FormSubmissionStatus {
  const InitialFormStatus();
}

/// class representing a login request. Shows wait indicator on screen
class FormSubmitting extends FormSubmissionStatus {

}

/// class representing a successful login submission
class SubmissionSuccess extends FormSubmissionStatus {

}

/// class representing submission failed status
class SubmissionFailed extends FormSubmissionStatus {
  final Exception exception;

  SubmissionFailed(this.exception);
}