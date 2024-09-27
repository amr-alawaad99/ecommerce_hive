import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import '../../shared/constants.dart';
import 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState>{


  AuthenticationCubit() : super(AuthenticationInitState());

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    emit(GoogleSignInLoading());
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(GoogleSignInFailure('Sign-in was cancelled by the user'));
        return;
      }

      // Get Google sign-in credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      // Check if user is already in Firestore
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser!.uid)
          .get();

      if (!userDoc.exists) {
        // If user doesn't exist in Firestore, create a new UserModel and save to Firestore
        UserModel user = UserModel(
          uId: firebaseUser.uid,
          name: googleUser.displayName ?? 'Unknown',
          email: firebaseUser.email!,
          phone: firebaseUser.phoneNumber ?? 'No Phone Number', // Phone number may be null from Google
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uId)
            .set(user.toMap());

        emit(GoogleSignInSuccess(user));
      } else {
        // If user already exists, retrieve user data and proceed
        UserModel existingUser = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        emit(GoogleSignInSuccess(existingUser));
      }

      fetchUserData(); // Fetch user data if needed
    } catch (e) {
      emit(GoogleSignInFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    stringBox!.clear();
    emit(GoogleSignOut());
  }


  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required String phone,
  })
  async {
    try {
      emit(SignUpLoading());


      // Create user in Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a UserModel object
      UserModel user = UserModel(
        uId: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uId)
          .set(user.toMap());

      emit(SignUpUserSuccess(user));
      fetchUserData();
    } on FirebaseAuthException catch (e) {
      emit(SignUpError(e.message.toString()));
    } catch (e) {
      emit(SignUpError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      emit(SignInLoading());
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(SignInSuccess(userCredential.user!));
      fetchUserData();
    } on FirebaseAuthException catch (e) {
      emit(SignInError(e.message.toString()));
    } catch (e) {
      emit(SignInError(e.toString()));
    }
  }


  UserModel? _userData;
  UserModel? get userData => _userData;
  Future<void> fetchUserData() async {
    try {
      emit(UserLoading());
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (userDoc.exists) {
        _userData = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        userModel = _userData;
        emit(UserLoaded(userData!));
      } else {
        print("lol");
        emit(UserError('User not found'));
      }
    } catch (e) {
      print(e.toString());
      emit(UserError(e.toString()));
    }
  }
}