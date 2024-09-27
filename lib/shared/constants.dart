import 'package:ecommerce_hive/models/user_model.dart';
import 'package:hive/hive.dart';

Box<String>? stringBox;
Box<Map>? homeProducts;
Box<Map>? offlineProducts;
Box<Map>? myProducts;
Box<Map>? offlineEdited;
Box<String>? offlineDeleted;
Box<Map>? offlineCart;
Box<Map>? homeCart;
Box<String>? removedFromCart;
bool internetConnectionOn = false;
UserModel? userModel;