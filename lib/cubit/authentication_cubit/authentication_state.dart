import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationState{}

class AuthenticationInitState extends AuthenticationState{}

// Loading state (when sign-in is in progress)
class GoogleSignInLoading extends AuthenticationInitState {}

// Success state (when sign-in is successful)
class GoogleSignInSuccess extends AuthenticationInitState {
  final User user;

  GoogleSignInSuccess(this.user);
}

// Failure state (when sign-in fails)
class GoogleSignInFailure extends AuthenticationInitState {
  final String error;

  GoogleSignInFailure(this.error);
}

class GoogleSignOut extends AuthenticationInitState {}
