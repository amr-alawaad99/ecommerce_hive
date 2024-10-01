import 'package:ecommere_hive_javaprint/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationState{}

class AuthenticationInitState extends AuthenticationState{}

// Loading state (when sign-in is in progress)
class GoogleSignInLoading extends AuthenticationInitState {}

// Success state (when sign-in is successful)
class GoogleSignInSuccess extends AuthenticationInitState {
  final UserModel user;

  GoogleSignInSuccess(this.user);
}

// Failure state (when sign-in fails)
class GoogleSignInFailure extends AuthenticationInitState {
  final String error;

  GoogleSignInFailure(this.error);
}

class GoogleSignOut extends AuthenticationInitState {}

class SignUpLoading extends AuthenticationInitState {}
class SignUpUserSuccess extends AuthenticationInitState {
  final UserModel user;

  SignUpUserSuccess(this.user);
}
class SignUpError extends AuthenticationState{
  final String message;

  SignUpError(this.message);
}

class SignInLoading extends AuthenticationInitState {}
class SignInSuccess extends AuthenticationInitState {
  final User user;

  SignInSuccess(this.user);
}
class SignInError extends AuthenticationState{
  final String message;

  SignInError(this.message);
}

class UserLoading extends AuthenticationState{}
class UserLoaded extends AuthenticationInitState {
  final UserModel user;

  UserLoaded(this.user);
}
class UserError extends AuthenticationState{
  final String message;

  UserError(this.message);
}

