import '../models/product.dart';

abstract class ProductEvent {
  const ProductEvent();
}

/// Fetch the product list from the API
class FetchProducts extends ProductEvent {
  const FetchProducts();
}

class CreateProduct extends ProductEvent {
  final String title;
  final String description;
  final double price;
  final String category;

  const CreateProduct({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
  });
}

class UpdateProduct extends ProductEvent {
  final Product product;
  const UpdateProduct(this.product);
}

class DeleteProduct extends ProductEvent {
  final int id;
  const DeleteProduct(this.id);
}