import 'dart:developer';
import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_state.dart';
import 'package:ecommerce_hive/screens/email_sign_in_screen.dart';
import 'package:ecommerce_hive/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/constants.dart';
import 'email_sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) async {
        if(state is GoogleSignInSuccess){
          stringBox?.put("uid", FirebaseAuth.instance.currentUser!.uid);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen(),), (route) => false,);
        } if(state is GoogleSignInFailure){
          log(state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EmailSignInScreen(),));
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Ink(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: const Color(0xFF747775),
                          )
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline, size: 20, color: Colors.red,),
                          SizedBox(width: 10),
                          Text('Sign in with Email and Password',),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  if(state is GoogleSignInLoading)
                    const Center(child: CircularProgressIndicator(),)
                  else
                    InkWell(
                    onTap: () {
                      context.read<AuthenticationCubit>().signInWithGoogle();
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Ink(
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Color(0xFF747775),
                          )
                      ),
                      padding: EdgeInsets.all(10),
                      child: const Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          Icon(
                            Icons.g_mobiledata, size: 20, color: Colors.red,),
                          SizedBox(width: 10),
                          Text('Sign in with Google',),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EmailSignUpScreen(),));
                        },
                        child: const Text("Register Now!"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
