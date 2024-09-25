import '../../models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class InternetConnectionLost extends ProductState {}
class InternetConnectionOn extends ProductState {}

class ProductAddedOffline extends ProductState {}
class ProductAddedOnline extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}