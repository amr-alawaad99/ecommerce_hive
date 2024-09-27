import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:ecommerce_hive/cubit/authentication_cubit/authentication_state.dart';
import 'package:ecommerce_hive/cubit/product_cubit/product_cubit.dart';
import 'package:ecommerce_hive/cubit/product_cubit/product_state.dart';
import 'package:ecommerce_hive/models/user_model.dart';
import 'package:ecommerce_hive/screens/login_screen.dart';
import 'package:ecommerce_hive/shared/constants.dart';
import 'package:ecommerce_hive/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              return ValueListenableBuilder(
                valueListenable: homeProducts!.listenable(),
                builder: (context, Box<Map> box, _) {
                  return Text("offline: ${offlineProducts!.length}, home: ${homeProducts!.length}  ");
                  },
              );
              },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
            listener: (context, state) {
              if (state is GoogleSignOut) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              UserModel? user = context.read<AuthenticationCubit>().userData;
              return Scaffold(
                body: user == null?
                const LinearProgressIndicator() :
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if(FirebaseAuth.instance.currentUser?.photoURL != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                              FirebaseAuth.instance.currentUser!.photoURL!),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(user.name!),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(user.email!),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(user.phone!),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomButton(
                          innerText: "Sign Out",
                          onPressed: () async {
                            await context.read<AuthenticationCubit>().signOut();
                          },
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('products').orderBy("dateTime", descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(internetConnectionOn){
                log("Online Mode");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {

                  // Load products from Firestore and save them to Hive
                  for (var doc in snapshot.data!.docs) {
                    var productData = doc.data() as Map<String, dynamic>;
                    var product = Product.fromMap({'id': doc.id, ...productData});

                    // Save or update product in Hive
                    Hive.box<Map>('homeProducts').put(doc.id, product.toMap());
                  }

                  // Check for deleted products in Hive
                  final hiveProductIds = homeProducts!.keys.cast<String>().toSet();
                  // Fetch Firestore product IDs to check against Hive
                  final firestoreProductIds = snapshot.data!.docs.map((doc) => doc.id).toSet();

                  // Remove products from Hive that are no longer in Firestore
                  for (var id in hiveProductIds) {
                    if (!firestoreProductIds.contains(id)) {
                      homeProducts!.delete(id); // Remove deleted products from Hive
                    }
                  }

                  // Build the grid from Firestore products
                  final productsList = snapshot.data!.docs.map((doc) {
                    var productData = doc.data() as Map<String, dynamic>;
                    return Product.fromMap({'id': doc.id, ...productData});}).toList();

                  return buildProductGrid(productsList);
                }
                else {
                  return const Center(child: Text('No products available'));
                }
              }
              else {
                log("Offline Mode");
                List<Product> home = homeProducts!.values.map((productMap) {
                  return Product.fromMap(Map<String, dynamic>.from(productMap));
                }).toList();

                // Sort the list based on the "dateTime" key - reversed
                home.sort((a, b) => b.dateTime.compareTo(a.dateTime));

                return buildProductGrid(home);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper function to build product grid view
  Widget buildProductGrid(List<Product> products) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two products per row
        childAspectRatio: 0.75, // Aspect ratio for product cards
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          ),
          child: Card(
            elevation: 4,
            child: Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('\$${product.price}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
