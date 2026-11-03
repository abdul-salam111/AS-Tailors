import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/presentation/pagination/pagination_cubit.dart';
import '../shared/presentation/pagination/pagination_state.dart';
import '../utils/failure_mapper.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';
import 'loading_indicator.dart';

/// Infinite-scroll list wired to a [PaginationCubit] — fetches the first
/// page on mount, fetches the next page when the user scrolls near the
/// bottom, and renders the standard loading / empty / error states so
/// individual features don't have to rebuild this every time.
class PaginatedListView<T> extends StatefulWidget {
  final PaginationCubit<T> cubit;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final Widget? emptyWidget;

  /// Distance in pixels from the bottom of the list at which the next
  /// page is requested.
  final double loadMoreThreshold;

  const PaginatedListView({
    super.key,
    required this.cubit,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.emptyWidget,
    this.loadMoreThreshold = 200,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.cubit.fetchFirstPage();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - widget.loadMoreThreshold) {
      widget.cubit.fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationCubit<T>, PaginationState<T>>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (state.status == PaginationStatus.loadingFirstPage) {
          return const LoadingIndicator();
        }

        if (state.status == PaginationStatus.failure && state.items.isEmpty) {
          return ErrorStateWidget(
            message: state.failure != null
                ? AppFailureMapper.map(state.failure!).message
                : 'Something went wrong',
            onRetry: widget.cubit.fetchFirstPage,
          );
        }

        if (state.items.isEmpty) {
          return widget.emptyWidget ?? const EmptyStateWidget();
        }

        return RefreshIndicator(
          onRefresh: widget.cubit.refresh,
          child: ListView.separated(
            controller: _scrollController,
            padding: widget.padding,
            itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
            separatorBuilder: (_, __) => widget.separator ?? const SizedBox.shrink(),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingIndicator(size: 24),
                );
              }
              return widget.itemBuilder(context, state.items[index]);
            },
          ),
        );
      },
    );
  }
}
