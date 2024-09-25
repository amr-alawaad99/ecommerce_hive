import 'dart:developer';
import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_state.dart';
import 'package:ecommerce_hive/screens/home_screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) async {
        if(state is GoogleSignInSuccess){
          stringBox?.put("uid", FirebaseAuth.instance.currentUser!.uid);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen(),), (route) => false,);
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
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
