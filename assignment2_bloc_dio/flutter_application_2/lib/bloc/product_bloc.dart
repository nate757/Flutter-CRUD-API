import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService _apiService;

  /// IDs of products created locally this session.
  /// DummyJSON returns id=194 for every new product (fake API), so
  /// PUT/DELETE on those ids may behave unexpectedly. We manage them
  /// in-memory and skip the network call for mutations.
  final Set<int> _localIds = {};

  ProductBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(const ProductInitial()) {
    on<FetchProducts>(_onFetch);
    on<CreateProduct>(_onCreate);
    on<UpdateProduct>(_onUpdate);
    on<DeleteProduct>(_onDelete);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  List<Product> get _currentList {
    final s = state;
    if (s is ProductLoaded) return List<Product>.from(s.products);
    if (s is ProductActionInProgress) return List<Product>.from(s.products);
    if (s is ProductError) return List<Product>.from(s.products);
    return [];
  }

  // ── FetchProducts ────────────────────────────────────────────────────────────
  Future<void> _onFetch(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await _apiService.fetchProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(message: _clean(e)));
    }
  }

  // ── CreateProduct ────────────────────────────────────────────────────────────
  Future<void> _onCreate(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    final current = _currentList;
    emit(ProductActionInProgress(current));
    try {
      final created = await _apiService.createProduct(
        title: event.title,
        description: event.description,
        price: event.price,
        category: event.category,
      );

      // DummyJSON always echoes back the same fake id (194).
      // Give it a locally-unique id to avoid conflicts in the list.
      final uniqueId = DateTime.now().millisecondsSinceEpoch;
      final localProduct = created.copyWith(id: uniqueId);
      _localIds.add(uniqueId);

      final updated = [localProduct, ...current];
      emit(ProductLoaded(updated));
    } catch (e) {
      emit(ProductError(message: _clean(e), products: current));
    }
  }

  // ── UpdateProduct ────────────────────────────────────────────────────────────
  Future<void> _onUpdate(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    final current = _currentList;
    emit(ProductActionInProgress(current));
    try {
      Product updated;

      if (_localIds.contains(event.product.id)) {
        // Locally-created product — skip the API, update in-memory only
        updated = event.product;
      } else {
        updated = await _apiService.updateProduct(event.product);
      }

      final newList = current.map((p) {
        return p.id == updated.id ? updated : p;
      }).toList();

      emit(ProductLoaded(newList));
    } catch (e) {
      emit(ProductError(message: _clean(e), products: current));
    }
  }

  // ── DeleteProduct ────────────────────────────────────────────────────────────
  Future<void> _onDelete(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    final current = _currentList;
    emit(ProductActionInProgress(current));
    try {
      if (!_localIds.contains(event.id)) {
        await _apiService.deleteProduct(event.id);
      }
      _localIds.remove(event.id);
      final newList = current.where((p) => p.id != event.id).toList();
      emit(ProductLoaded(newList));
    } catch (e) {
      emit(ProductError(message: _clean(e), products: current));
    }
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}