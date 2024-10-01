import '../../models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ChangeSelectedIndex extends ProductState {}

class InternetConnectionLost extends ProductState {}
class InternetConnectionOn extends ProductState {}

class ProductAddedOffline extends ProductState {}
class ProductAddedOnline extends ProductState {}

class ScanningBluetoothDevices extends ProductState {}
class StoppedScanningBluetoothDevices extends ProductState {}

class ProductUpdatedOffline extends ProductState {}
class ProductUpdatedOnline extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}