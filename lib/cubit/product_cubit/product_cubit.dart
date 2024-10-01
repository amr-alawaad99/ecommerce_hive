import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommere_hive_javaprint/cubit/product_cubit/product_state.dart';
import 'package:ecommere_hive_javaprint/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/product_model.dart';

class ProductCubit extends Cubit<ProductState> {

  ProductCubit() : super(ProductInitial());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  int selectedIndex = 0;
  void changeIndex(int index){
    selectedIndex = index;
    emit(ChangeSelectedIndex());
  }

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

  Future<void> onAddingProduct(Product product) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Save product locally if offline
      await offlineProducts?.add(product.toMap());
      emit(ProductAddedOffline());
    } else {
      _addProduct(product);
      emit(ProductAddedOnline());
    }
  }

  Future<void> _addProduct(Product product) async {
    await firestore.collection('products').add(product.toMap()).then(
          (value) {
        value.update({"id" : value.id});
      },
    );
  }

  Future<void> onUpdateProduct(Product product) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Save product locally if offline
      await offlineEdited?.add(product.toMap());
      emit(ProductUpdatedOffline());
    } else {
      _updateProduct(product);
      emit(ProductUpdatedOnline());
    }
  }

  Future<void> _updateProduct(Product product) async {
    try {
      await FirebaseFirestore.instance.collection("products").doc(product.id)
          .update(product.toMap());
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> onDeleteProduct(String id) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Save product locally if offline
      await offlineDeleted?.add(id);
      emit(ProductUpdatedOffline());
    } else {
      _deleteProduct(id);
      emit(ProductUpdatedOnline());
    }
  }

  Future<void> _deleteProduct (String id) async {
    try {
      await FirebaseFirestore.instance.collection("products").doc(id).delete();
    } on Exception catch (e) {
      print(e);
    }

  }
  
  Future<void> onAddToCart(Product product) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Save product locally if offline
      await offlineCart?.put(product.id ,product.toMap());
      emit(ProductUpdatedOffline());
    } else {
      _addToCart(product);
      emit(ProductUpdatedOnline());
    }
  }
  
  Future<void> _addToCart (Product product) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart").doc(product.id).set(product.toMap());
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> onRemoveFromCart(String id) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Save product locally if offline
      await removedFromCart?.add(id);
      emit(ProductUpdatedOffline());
    } else {
      await _removeFromCart(id);
      emit(ProductUpdatedOnline());
    }
  }

  Future<void> _removeFromCart (String id) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart").doc(id).delete();
    } on Exception catch (e) {
      print(e);
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
            _addProduct(product);

            await offlineProducts!.deleteAt(i);
            i++;
          }
        }
        if(offlineEdited!.isNotEmpty){
          // Loop through all offline products and update them in Firestore
          for (Map productData in offlineEdited!.values) {
            int i = 0;
            // Cast the productData to Map<String, dynamic>
            Product product = Product.fromMap(Map<String, dynamic>.from(productData));

            // Update the product in Firestore
            _updateProduct(product);

            await offlineEdited!.deleteAt(i);
            i++;
          }
        }
        if(offlineDeleted!.isNotEmpty){
          // Loop through all offline product Ids and delete them from Firestore
          for (String productId in offlineDeleted!.values) {
            int i = 0;
            // Add the product to Firestore
            _deleteProduct(productId);

            await offlineDeleted!.deleteAt(i);
            i++;
          }
        }
        if(removedFromCart!.isNotEmpty){
          // Loop through all offline product Ids and delete them from Firestore
          for (String productId in removedFromCart!.values) {
            int i = 0;
            // Add the product to Firestore
            _removeFromCart(productId);

            await removedFromCart!.deleteAt(i);
            i++;
          }
        }
        if (offlineCart!.isNotEmpty) {
          // Loop through all offline products and upload them to Firestore
          for (Map productData in offlineCart!.values) {
            int i = 0;
            // Cast the productData to Map<String, dynamic>
            Product product = Product.fromMap(Map<String, dynamic>.from(productData));

            // Add the product to Firestore
            _addToCart(product);

            await offlineCart!.deleteAt(i);
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

  /// BlueTooth and Printing
  Future scanDevices() async {

    emit(ScanningBluetoothDevices());
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 20));

  }

  Stream<List<ScanResult>> get scanResult => FlutterBluePlus.scanResults;


  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    print("WWWWWWWWWWWWVVVVVVVVVV ${device.isConnected}");
  }
}