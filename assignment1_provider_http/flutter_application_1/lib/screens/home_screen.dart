import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
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
    // Fetch posts after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  Future<void> _confirmDelete(BuildContext context, int postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<PostProvider>().deletePost(postId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Post deleted.' : 'Failed to delete.'),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 1,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PostBoard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            Consumer<PostProvider>(
              builder: (_, provider, __) => Text(
                '${provider.posts.length} posts',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
        actions: [
          // Refresh button
          Consumer<PostProvider>(
            builder: (_, provider, __) => IconButton(
              icon: provider.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: provider.isLoading
                  ? null
                  : () => context.read<PostProvider>().fetchPosts(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          // ── Loading ──────────────────────────────────────────────────────────
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

        
        if (provider.hasError && provider.posts.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.wifi_off_rounded,
              message: provider.errorMessage,
              actionLabel: 'Retry',
              onAction: () => provider.fetchPosts(),
            );
          }

          if (provider.posts.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.article_outlined,
              message: 'No posts yet.\nTap + to create your first post.',
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: provider.fetchPosts,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  itemCount: provider.posts.length,
                  itemBuilder: (context, index) {
                    final post = provider.posts[index];
                    return PostCard(
                      post: post,
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditScreen(post: post),
                        ),
                      ),
                      onDelete: () => _confirmDelete(context, post.id),
                    );
                  },
                ),
              ),     

              
              if (provider.isSubmitting)
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
        label: const Text('New Post'),
      ),
    );
  }
}