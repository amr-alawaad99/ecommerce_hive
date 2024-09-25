import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce_hive/cubit/product_cubit/product_state.dart';
import 'package:ecommerce_hive/shared/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_model.dart';

class ProductCubit extends Cubit<ProductState> {

  ProductCubit() : super(ProductInitial());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;


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
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Save product locally if offline
      await offlineProducts?.add(product.toMap());
      emit(ProductAddedOffline());
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
      emit(ProductAddedOnline());
    }
  }

  void doOnConnectionChange() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result.first == ConnectivityResult.mobile || result.first == ConnectivityResult.wifi) {
        internetConnectionOn = true;
        print("Connected to the internet");

        if (offlineProducts!.isNotEmpty) {
          // Loop through all offline products and upload them to Firestore
          for (Map productData in offlineProducts!.values) {
            int i = 0;
            // Cast the productData to Map<String, dynamic>
            Product product = Product.fromMap(Map<String, dynamic>.from(productData));

            // Add the product to Firestore
            await firestore.collection('products').add(product.toMap()).then((value) {
              value.update({"id" : value.id});
              return value;
            },);

            await offlineProducts!.deleteAt(i);
            print("Product ${product.name} synced and deleted from offline storage");
            i++;
          }
        }
        emit(InternetConnectionOn());
      } else if (result.first == ConnectivityResult.none) {
        internetConnectionOn = false;
        emit(InternetConnectionLost());
        print("No internet connection");
        // Handle offline status, if necessary
      }
    });
  }


}