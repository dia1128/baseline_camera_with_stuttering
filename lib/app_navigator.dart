/*
  Created By: Nathan Millwater
  Description: Holds the logic for app navigation between the auth and
               the camera app homepage
 */

import 'package:camera_app/auth/auth_cubit.dart';
import 'package:camera_app/auth/auth_navigator.dart';
import 'package:camera_app/camera_cubit.dart';
import 'package:camera_app/loading_view.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/camera_navigator.dart';
import 'package:camera_app/stuttering/stuttering_home.dart';
import 'package:camera_app/session_state.dart';
import 'package:camera_app/session_cubit.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


/// App Navigator widget that handles navigation between login screens
/// and camera home screen
class AppNavigator extends StatelessWidget {

  /// standard build method that creates the widget
  @override
  Widget build(BuildContext context) {
    // provide access to session cubit and state with blocbuilder
    return BlocBuilder<SessionCubit, SessionState>(builder: (context, state) {
      return Navigator(
        pages: [
          // show loading screen
          // if (state is UnknownSessionState)
          //   MaterialPage(child: LoadingView()),
          //
          // // show the auth navigator
          // if (state is Unauthenticated)
          //   MaterialPage(
          //     child: BlocProvider(
          //       create: (context) => AuthCubit(sessionCubit: context.read<SessionCubit>()),
          //       child: AuthNavigator(),
          //     ),
          //   ),

          // show the session
          // if (state is Authenticated)
            MaterialPage(

                child: BlocProvider(
                  create: (context) => CameraCubit(),
                    child: CameraNavigator()

                )

            ),
        ],
        // remove the page from the route
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
