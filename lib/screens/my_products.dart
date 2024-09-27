import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_hive/screens/edit_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../cubit/product_cubit/product_cubit.dart';
import '../cubit/product_cubit/product_state.dart';
import '../models/product_model.dart';
import '../shared/constants.dart';

class MyProducts extends StatelessWidget {
  const MyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("My Products"),
            actions: [
              ValueListenableBuilder(
                valueListenable: myProducts!.listenable(), // Listen to changes in homeCart
                builder: (context, Box<Map> box, _) {
                  return Text("products: ${myProducts!.length}, edited: ${offlineEdited!.length}, deleted: ${offlineDeleted!.length}  ");
                },
              ),
            ],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where("userId", isEqualTo: stringBox!.get("uid")!)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (internetConnectionOn) {
                print("Online Mode");
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
                    var product =
                        Product.fromMap({'id': doc.id, ...productData});

                    // Save or update product in Hive
                    Hive.box<Map>('myProducts').put(doc.id, product.toMap());
                  }

                  // Check for deleted products in Hive
                  final hiveProductIds =
                      myProducts!.keys.cast<String>().toSet();
                  // Fetch Firestore product IDs to check against Hive
                  final firestoreProductIds =
                      snapshot.data!.docs.map((doc) => doc.id).toSet();

                  // Remove products from Hive that are no longer in Firestore
                  for (var id in hiveProductIds) {
                    if (!firestoreProductIds.contains(id)) {
                      myProducts!
                          .delete(id); // Remove deleted products from Hive
                    }
                  }

                  // Build the grid from Firestore products
                  final productsList = snapshot.data!.docs.map((doc) {
                    var productData = doc.data() as Map<String, dynamic>;
                    return Product.fromMap({'id': doc.id, ...productData});
                  }).toList();

                  return buildProductGrid(productsList);
                } else {
                  return const Center(child: Text('No products available'));
                }
              } else {
                print("Offline Mode");
                List<Product> home = myProducts!.values.map((productMap) {
                  return Product.fromMap(Map<String, dynamic>.from(productMap));
                }).toList();
                // Sort the list based on the "dateTime" key - reversed
                home.sort((a, b) => b.dateTime.compareTo(a.dateTime));
                return buildProductGrid(home);
              }
            },
          ),
        );
      },
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
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProduct(product: product),
                ));
          },
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
