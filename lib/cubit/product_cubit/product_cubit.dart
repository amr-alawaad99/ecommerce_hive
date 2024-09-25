import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce_hive/cubit/product_cubit/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../models/product_model.dart';

class ProductCubit extends Cubit<ProductState> {
  final FirebaseFirestore firestore;
  final Box<Map> productsBox;

  ProductCubit({required this.firestore, required this.productsBox})
      : super(ProductInitial());

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      var productsSnapshot = await firestore.collection('products').get();
      var productList = productsSnapshot.docs.map((doc) {
        var productData = doc.data();
        return Product.fromMap({
          'id': doc.id,
          ...productData,
        });
      }).toList();
      emit(ProductLoaded(productList));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> addProduct(Product product) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Save product locally if offline
      await productsBox.add(product.toMap());
    } else {
      // Add product to Firestore if online and generate an ID
      DocumentReference docRef = await firestore.collection('products').add(product.toMap());
      Product updatedProduct = Product(
        id: docRef.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      await firestore.collection('products').doc(updatedProduct.id).set(updatedProduct.toMap());
    }
  }
}