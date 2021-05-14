import 'package:flutter_amplify/auth/session_state.dart';
import 'package:flutter_amplify/auth/auth_repository.dart';
import 'package:flutter_amplify/auth/data_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_amplify/auth/models/user_model.dart';
import 'package:flutter_amplify/auth/auth_credentials.dart';
import 'package:amplify_api/amplify_api.dart';


class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;
  final DataRepository dataPepo;

  User get currentUser => (state as Authenticated).user;
  User get selectedUser => (state as Authenticated).selectedUser;
  bool get isCurrentUserSelected =>
      selectedUser == null || currentUser.id == selectedUser.id;


  SessionCubit({this.authRepo, this.dataPepo}) : super(UnknownSessionState()) {
    attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    print("Attemp auto login");

    try {
      final userId = await authRepo.attemptAutoLogin();
      print("Attemp auto login $userId");
      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Get user from DB given userId
      User user = await dataPepo.getUserById(userId);
      if (user == null) {
        user = await dataPepo.createUser(
          userId: userId,
          username: 'User-${UUID()}',
        );
      }
      emit(Authenticated(user: user));
    } on Exception {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());
  void showSession(AuthCredentials credentials) async {
    try {
      User user = await dataPepo.getUserById(credentials.userId);
      if (user == null) {
        user = await dataPepo.createUser(
          userId: credentials.userId,
          username: credentials.username,
          email: credentials.email,
        );
      }

      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }

    // final user = dataRepo.getUser(credentials.userId);
    emit(Authenticated(
        user: User(
            id: credentials.userId,
            username: credentials.username,
            email: credentials.email,
            avatarkey: '',
            description: '')));
  }

  void signOut() {
    authRepo.signOut();
    emit(Unauthenticated());
  }
}
