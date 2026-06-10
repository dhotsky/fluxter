import 'package:flutter/material.dart';
import 'package:fluxter/app/theme/app_color.dart';

import 'package:fluxter/app/widgets/app_empty.dart';

/// Reusable GridView component supporting:
/// - Pull to Refresh
/// - Load More (Pagination)
/// - Empty State
/// - Initial Loading State
class AppGridView extends StatefulWidget {
  final int numberOfItems;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Grid Configuration
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  /// Callback when pulled to refresh
  final Future<void> Function()? onRefresh;

  /// Callback when scrolled to the bottom
  final Future<void> Function()? onLoadMore;

  /// Whether the initial data is still loading
  final bool isLoading;

  /// Whether more data is currently being fetched
  final bool isLoadMoreLoading;

  /// Whether there's no more data to load (disables load more)
  final bool hasReachedMax;

  /// Custom empty widget (defaults to AppEmpty)
  final Widget? emptyWidget;

  /// Padding for the grid
  final EdgeInsetsGeometry padding;

  const AppGridView({
    super.key,
    required this.numberOfItems,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12.0,
    this.crossAxisSpacing = 12.0,
    this.childAspectRatio = 1.0,
    this.onRefresh,
    this.onLoadMore,
    this.isLoading = false,
    this.isLoadMoreLoading = false,
    this.hasReachedMax = true,
    this.emptyWidget,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<AppGridView> createState() => _AppGridViewState();
}

class _AppGridViewState extends State<AppGridView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null) return;
    if (widget.isLoading || widget.isLoadMoreLoading || widget.hasReachedMax) {
      return;
    }

    // Trigger load more when user scrolls to 90% of the list
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll * 0.9)) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.numberOfItems == 0) {
      return Center(child: CircularProgressIndicator(color: AppColor.primary));
    }

    if (widget.numberOfItems == 0) {
      return _buildEmptyState();
    }

    final gridView = CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: widget.padding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              mainAxisSpacing: widget.mainAxisSpacing,
              crossAxisSpacing: widget.crossAxisSpacing,
              childAspectRatio: widget.childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return widget.itemBuilder(context, index);
            }, childCount: widget.numberOfItems),
          ),
        ),
        if (widget.isLoadMoreLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: AppColor.primary),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(onRefresh: widget.onRefresh!, child: gridView);
    }

    return gridView;
  }

  Widget _buildEmptyState() {
    final emptyView = widget.emptyWidget ?? const AppEmpty();

    // Wrap with Stack and ListView so it can still be pulled to refresh
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Container(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: emptyView,
              ),
            ],
          ),
        ),
      );
    }

    return emptyView;
  }
}
