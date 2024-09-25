import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:ecommerce_hive/models/product_model.dart';
import 'package:ecommerce_hive/screens/home_screen/home_screen.dart';
import 'package:ecommerce_hive/screens/login_screen/login_screen.dart';
import 'package:ecommerce_hive/shared/bloc_observer.dart';
import 'package:ecommerce_hive/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cubit/product_cubit/product_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = MyBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  homeProducts = await Hive.openBox<Map>('homeProducts');
  offlineProducts = await Hive.openBox<Map>('offlineProducts');
  stringBox = await Hive.openBox<String>('stringBox');


  bool isSignedIn = false;
  if (stringBox?.get("uid") != null) {
    isSignedIn = true;
  }
  print(isSignedIn);



  runApp(MyApp(isSignedIn: isSignedIn));
  // void initState() {
  //   super.initState();
  //   productCubit.loadProducts();
  //   Connectivity().onConnectivityChanged.listen((result) {
  //     if (result != ConnectivityResult.none) {
  //       productCubit.syncLocalProducts();
  //     }
  //   });
  // }
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;

  MyApp({required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationCubit(),),
        BlocProvider(create: (context) => ProductCubit()..doOnConnectionChange()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Commerce App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isSignedIn? HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
