import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProducts());
  }

  Future<void> _confirmDelete(BuildContext context, int productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProductBloc>().add(DeleteProduct(productId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        scrolledUnderElevation: 1,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ShopBoard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
            ),
            BlocBuilder<ProductBloc, ProductState>(
              builder: (_, state) {
                final count = state is ProductLoaded
                    ? state.products.length
                    : state is ProductActionInProgress
                        ? state.products.length
                        : 0;
                return Text(
                  '$count products',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                );
              },
            ),
          ],
        ),
        actions: [
          BlocBuilder<ProductBloc, ProductState>(
            builder: (_, state) => IconButton(
              icon: state is ProductLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: cs.primary),
                    )
                  : const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: state is ProductLoading
                  ? null
                  : () =>
                      context.read<ProductBloc>().add(const FetchProducts()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        // BlocConsumer = BlocBuilder + BlocListener in one widget
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
          if (state is ProductLoaded) {
            // Dismiss any lingering snackbars on success
            ScaffoldMessenger.of(context).clearSnackBars();
          }
        },
        builder: (context, state) {
          // ── Full-screen loading ──────────────────────────────────────────────
          if (state is ProductLoading || state is ProductInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Resolve list from any state ──────────────────────────────────────
          List<Product> products = [];
          bool isBusy = false;

          if (state is ProductLoaded) {
            products = state.products;
          } else if (state is ProductActionInProgress) {
            products = state.products;
            isBusy = true;
          } else if (state is ProductError) {
            products = state.products;
          }

          // ── Full-screen error (no products yet) ──────────────────────────────
          if (products.isEmpty && state is ProductError) {
            return EmptyStateWidget(
              icon: Icons.wifi_off_rounded,
              message: state.message,
              actionLabel: 'Retry',
              onAction: () =>
                  context.read<ProductBloc>().add(const FetchProducts()),
            );
          }

          // ── Empty list ───────────────────────────────────────────────────────
          if (products.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.shopping_bag_outlined,
              message: 'No products yet.\nTap + to add your first product.',
            );
          }

          // ── Product list ─────────────────────────────────────────────────────
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async =>
                    context.read<ProductBloc>().add(const FetchProducts()),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return ProductCard(
                      product: p,
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditScreen(product: p),
                        ),
                      ),
                      onDelete: () => _confirmDelete(context, p.id),
                    );
                  },
                ),
              ),
              if (isBusy)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
      ),
    );
  }
}