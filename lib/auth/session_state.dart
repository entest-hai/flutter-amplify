import 'package:flutter/material.dart';
import 'package:flutter_amplify/auth/models/user_model.dart';

abstract class SessionState {}

class UnknownSessionState extends SessionState {}

class Unauthenticated extends SessionState {}

class Authenticated extends SessionState {
  final User user;

  Authenticated({@required this.user});
}