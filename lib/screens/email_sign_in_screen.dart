import 'package:ecommere_hive_javaprint/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:ecommere_hive_javaprint/cubit/authentication_cubit/authentication_state.dart';
import 'package:ecommere_hive_javaprint/screens/home_screen.dart';
import 'package:ecommere_hive_javaprint/screens/layout_screen.dart';
import 'package:ecommere_hive_javaprint/widgets/custom_button.dart';
import 'package:ecommere_hive_javaprint/widgets/custom_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/constants.dart';

class EmailSignInScreen extends StatelessWidget {
  EmailSignInScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if(state is SignInSuccess){
            stringBox?.put("uid", FirebaseAuth.instance.currentUser!.uid);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Welcome back!")));
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LayoutScreen(),));
          }
          if(state is SignInError){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      CustomInputField(
                        hintText: "Enter Your Email",
                        labelText: "Email Address",
                        controller: emailController,
                      ),
                      const SizedBox(height: 10,),
                      CustomInputField(
                        hintText: "Enter Your Password",
                        labelText: "Password",
                        controller: passwordController,
                        suffixIcon: true,
                        obscureText: true,
                      ),
                      const SizedBox(height: 20,),
                      if(state is SignInLoading)
                        const CircularProgressIndicator()
                      else
                        CustomButton(
                        innerText: "Sign In",
                        onPressed: () {
                          context.read<AuthenticationCubit>().signIn(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
