import 'package:ecommerce_hive/models/product_model.dart';
import 'package:hive/hive.dart';

Box<String>? stringBox;
Box<Map>? homeProducts;
Box<Map>? offlineProducts;
bool internetConnectionOn = false;