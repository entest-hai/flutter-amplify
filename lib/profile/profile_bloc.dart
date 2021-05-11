import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_amplify/auth/models/user_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _picker = ImagePicker();

  ProfileBloc({@required User user, @required bool isCurrentUser}) : super(ProfileState(user: user, isCurrentUser: isCurrentUser));

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is ChangeAvatarRequest) {
      // show action sheet 
      yield state.copyWith(
        imageSourceActionSheetIsVisible: true
      );

    } else if (event is OpenImagePicker) {
      // open image picker 
      yield state.copyWith(imageSourceActionSheetIsVisible: false);
      final pickedImage = await _picker.getImage(source: event.imageSource);
      if (pickedImage == null) return; 
      yield state.copyWith(avatarPath: pickedImage.path);
      
    } else if (event is ProvideImagePath) {
      yield state.copyWith(avatarPath: event.avatarPath); 
    } else if (event is ProfileDescriptionChanged) {
      yield state.copyWith(userDescription: event.description);
    } else if (event is SaveProfileChanges) {
      // handle save changes 
    }
  }
}