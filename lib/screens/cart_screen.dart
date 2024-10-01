import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommere_hive_javaprint/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../cubit/product_cubit/product_cubit.dart';
import '../cubit/product_cubit/product_state.dart';
import '../models/product_model.dart';
import '../shared/constants.dart';
import '../widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Cart"),
            actions: [
              ValueListenableBuilder(
                valueListenable: homeCart!.listenable(), // Listen to changes in homeCart
                builder: (context, Box<Map> box, _) {
                  return Text("offline items: ${offlineCart!.length}, cart: ${homeCart!.length}, removed: ${removedFromCart!.length} ");
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 110),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(stringBox!.get("uid")!)
                  .collection("cart")
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
                      var product = Product.fromMap({'id': doc.id, ...productData});

                      // Save or update product in Hive
                      homeCart!.put(doc.id, product.toMap());
                    }

                    // Check for deleted products in Hive
                    final hiveProductIds = homeCart!.keys.cast<String>().toSet();
                    // Fetch Firestore product IDs to check against Hive
                    final firestoreProductIds =
                        snapshot.data!.docs.map((doc) => doc.id).toSet();

                    // Remove products from Hive that are no longer in Firestore
                    for (var id in hiveProductIds) {
                      if (!firestoreProductIds.contains(id)) {
                        homeCart!.delete(id); // Remove deleted products from Hive
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
                  List<Product> homeUploaded = homeCart!.values.map((productMap) {
                    return Product.fromMap(Map<String, dynamic>.from(productMap));
                  }).toList();
                  List<Product> homeNotUploaded = offlineCart!.values.map((productMap) {
                    return Product.fromMap(Map<String, dynamic>.from(productMap));
                  }).toList();

                  List<Product> home = homeUploaded + homeNotUploaded;
                  // Sort the list based on the "dateTime" key - reversed
                  home.sort((a, b) => b.dateTime.compareTo(a.dateTime));
                  return buildProductGrid(home);
                }
              },
            ),
          ),
          bottomSheet: Container(
            height: 100,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text("Subtotal",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: homeCart!.listenable(), // Listen to changes in homeCart
                        builder: (context, Box<Map> box, _) {
                          return Text("EGP ${homeCart!.values.map((item) => item['price'] as double).fold(0.0, (subtotal, price) => subtotal + price).toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomButton(innerText: "CHECKOUT", onPressed: () {
                    double totalPrice = double.parse(homeCart!.values.map((item) => item['price'] as double).fold(0.0, (subtotal, price) => subtotal + price).toStringAsFixed(2));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(products: homeCart!.values.map((productMap) {
                      return Product.fromMap(Map<String, dynamic>.from(productMap));
                    }).toList(), totalPrice: totalPrice),));
                    },
                    color: Colors.grey,),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper function to build product grid view
  Widget buildProductGrid(List<Product> products) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Two products per row
        childAspectRatio: 2/1, // Aspect ratio for product cards
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
              InkWell(
                onTap: () {
                  if(offlineCart!.length > 0){
                    print(offlineCart!.toMap());
                    print(products[index].id);
                    offlineCart!.delete(products[index].id);
                  }
                  homeCart!.delete(products[index].id);
                  context.read<ProductCubit>().onRemoveFromCart(product.id);
                },
                child: Ink(
                  color: Colors.redAccent,
                  width: 50,
                  child: const Center(child: Icon(Icons.delete_forever, size: 35,)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
