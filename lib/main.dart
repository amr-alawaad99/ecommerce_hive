import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:ecommerce_hive/screens/layout_screen.dart';
import 'package:ecommerce_hive/screens/login_screen.dart';
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
  stringBox = await Hive.openBox<String>('stringBox');
  //Home Page
  homeProducts = await Hive.openBox<Map>('homeProducts');
  offlineProducts = await Hive.openBox<Map>('offlineProducts');
  // My Products Page
  myProducts = await Hive.openBox<Map>('myProducts');
  offlineEdited = await Hive.openBox<Map>('offlineEdited');
  offlineDeleted = await Hive.openBox<String>("offlineDeleted");

  homeCart = await Hive.openBox<Map>('homeCart');
  removedFromCart = await Hive.openBox<String>('removedFromCart');
  offlineCart = await Hive.openBox<Map>('offlineCart');


  bool isSignedIn = false;
  if (stringBox?.get("uid") != null) {
    isSignedIn = true;
  }
  print(isSignedIn);



  runApp(MyApp(isSignedIn: isSignedIn));
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;

  MyApp({required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          if(isSignedIn) {
            return AuthenticationCubit()..fetchUserData();
          } else {
            return AuthenticationCubit();
          }
        },),
        BlocProvider(create: (context) => ProductCubit()..doOnConnectionChange()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Commerce App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isSignedIn? const LayoutScreen() : const LoginScreen(),
      ),
    );
  }
}
