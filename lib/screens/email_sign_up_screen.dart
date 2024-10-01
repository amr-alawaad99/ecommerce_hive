import 'package:ecommere_hive_javaprint/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:ecommere_hive_javaprint/cubit/authentication_cubit/authentication_state.dart';
import 'package:ecommere_hive_javaprint/screens/layout_screen.dart';
import 'package:ecommere_hive_javaprint/widgets/custom_button.dart';
import 'package:ecommere_hive_javaprint/widgets/custom_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/constants.dart';

class EmailSignUpScreen extends StatelessWidget {
  EmailSignUpScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if(state is SignUpUserSuccess){
            stringBox?.put("uid", FirebaseAuth.instance.currentUser!.uid);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome, ${state.user.name!}.")));
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LayoutScreen(),));
          }
          if(state is SignUpError){
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
                        hintText: "Enter Your Name",
                        labelText: "Name",
                        controller: nameController,
                      ),
                      const SizedBox(height: 10,),
                      CustomInputField(
                        hintText: "Enter Your Email",
                        labelText: "Email Address",
                        controller: emailController,
                      ),
                      const SizedBox(height: 10,),
                      CustomInputField(
                        hintText: "Enter Your Phone Number",
                        labelText: "Phone Number",
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
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
                      if(state is SignUpLoading)
                        const CircularProgressIndicator()
                      else
                        CustomButton(
                        innerText: "Sign Up",
                        onPressed: () {
                          context.read<AuthenticationCubit>().signUpUser(
                            name: nameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            phone: phoneNumberController.text,
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
