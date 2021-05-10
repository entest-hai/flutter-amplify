abstract class SignUpEvent {}

class SignUpUsernameChanged extends SignUpEvent {
  final String username;
  SignUpUsernameChanged({this.username});
}

class SignUpPasswordChanged extends SignUpEvent {
  final password;
  SignUpPasswordChanged({this.password});
}

class SignUpEmailChanged extends SignUpEvent {
  final String email;
  SignUpEmailChanged({this.email});
}

class SignUpSubmitted extends SignUpEvent {}
