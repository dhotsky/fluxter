import 'package:flutter/material.dart';

import 'package:fluxter/app/widgets/app_empty.dart';

/// Reusable ListView component supporting:
/// - Pull to Refresh
/// - Load More (Pagination)
/// - Empty State
/// - Initial Loading State
class AppListView extends StatefulWidget {
  final int numberOfItems;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Height of the separator (ignored if [separatorBuilder] is provided)
  final double separatorHeight;

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

  /// Padding for the list
  final EdgeInsetsGeometry padding;

  /// Optional header widget placed at the top of the list
  final Widget? header;

  const AppListView({
    super.key,
    required this.numberOfItems,
    required this.itemBuilder,
    this.separatorBuilder,
    this.separatorHeight = 12.0,
    this.onRefresh,
    this.onLoadMore,
    this.isLoading = false,
    this.isLoadMoreLoading = false,
    this.hasReachedMax = true,
    this.emptyWidget,
    this.padding = EdgeInsets.zero,
    this.header,
  });

  @override
  State<AppListView> createState() => _AppListViewState();
}

class _AppListViewState extends State<AppListView> {
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
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.numberOfItems == 0) {
      return _buildEmptyState();
    }

    final hasHeader = widget.header != null;
    final totalItems =
        widget.numberOfItems +
        (hasHeader ? 1 : 0) +
        (widget.isLoadMoreLoading ? 1 : 0);

    final listView = ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: totalItems,
      separatorBuilder:
          widget.separatorBuilder ??
          (context, index) => SizedBox(height: widget.separatorHeight),
      itemBuilder: (context, index) {
        int adjustedIndex = index;

        if (hasHeader) {
          if (index == 0) {
            return widget.header!;
          }
          adjustedIndex = index - 1;
        }

        if (adjustedIndex >= widget.numberOfItems) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return widget.itemBuilder(context, adjustedIndex);
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(onRefresh: widget.onRefresh!, child: listView);
    }

    return listView;
  }

  Widget _buildEmptyState() {
    final emptyView = widget.emptyWidget ?? const AppEmpty();

    if (widget.header != null) {
      final childView = CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: widget.padding,
            sliver: SliverToBoxAdapter(child: widget.header),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(padding: widget.padding, child: emptyView),
          ),
        ],
      );

      if (widget.onRefresh != null) {
        return RefreshIndicator(onRefresh: widget.onRefresh!, child: childView);
      }
      return childView;
    }

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
