/*
  Created By: Nathan Millwater
  Description: Holds the logic for changing navigation pages. Emits
               states to show different pages
 */

import 'package:flutter_bloc/flutter_bloc.dart';

/// Simple enumeration to show different auth states
enum CameraState {
  home,
  actionList,
  actionCatalog,
  stuttering}

/// Holds the logic for changing and handling auth states
class CameraCubit extends Cubit<CameraState> {

  CameraCubit() : super(CameraState.home);

  void showHome() => emit(CameraState.home);
  void showActionList() => emit(CameraState.actionList);
  void showActionCatalog() => emit(CameraState.actionCatalog);
  void showStutteringCatalog() => emit(CameraState.stuttering);

}
