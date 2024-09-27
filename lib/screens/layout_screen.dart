import 'package:ecommerce_hive/cubit/product_cubit/product_cubit.dart';
import 'package:ecommerce_hive/screens/cart_screen.dart';
import 'package:ecommerce_hive/screens/home_screen.dart';
import 'package:ecommerce_hive/screens/my_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final List<Widget> screens = [
  const HomeScreen(),
  const CartScreen(),
  const MyProducts(),
];

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[context.watch<ProductCubit>().selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: context.watch<ProductCubit>().selectedIndex,
        onDestinationSelected: (value) {
          context.read<ProductCubit>().changeIndex(value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          NavigationDestination(
            icon: Icon(Icons.my_library_add_outlined),
            label: "My Products",
          ),
        ],
      ),
    );
  }
}
