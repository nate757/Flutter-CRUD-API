import '../models/product.dart';

/// Base class for all Product states
abstract class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Fetching the full list
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// List loaded successfully
class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded(this.products);

  /// Helper: rebuild state with an updated list
  ProductLoaded copyWith(List<Product> products) => ProductLoaded(products);
}

/// A create / update / delete action is in-flight (list is still visible)
class ProductActionInProgress extends ProductState {
  final List<Product> products;
  const ProductActionInProgress(this.products);
}

/// Any error (fetch or action)
class ProductError extends ProductState {
  final String message;
  /// If products exist, keep them visible behind the error snackbar
  final List<Product> products;

  const ProductError({required this.message, this.products = const []});
}