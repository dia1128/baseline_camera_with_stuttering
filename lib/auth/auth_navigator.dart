/*
  Created By: Nathan Millwater
  Description: Holds the logic for app navigation between the different
               pages: login, signup, and confirm
 */

import 'package:camera_app/auth/sign_up/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_cubit.dart';
import 'confirm/confirmation_view.dart';
import 'login/login_view.dart';


/// Navigation class that is responsible for switching between different
/// authentication screens
class AuthNavigator extends StatelessWidget {

  // Initial build method of navigator widget
  @override
  Widget build(BuildContext context) {
    // Provide access to authcubit and authstate with blocbuilder
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Navigator(
        pages: [
          // Show login
          if (state == AuthState.login) MaterialPage(child: LoginView()),

          // Allow push animation
          if (state == AuthState.signUp ||
              state == AuthState.confirmSignUp) ...[
            // Show Sign up
            MaterialPage(child: SignUpView()),

            // Show confirm sign up
            if (state == AuthState.confirmSignUp)
              MaterialPage(child: ConfirmationView())
          ]
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
