import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide State;
import '../../domain/failures/failure.dart';
import 'pagination_state.dart';

/// Generic infinite-scroll pagination cubit.
///
/// ## How to use
/// Provide a [fetchPage] closure that calls your usecase for a given page
/// number and returns `Either<Failure, List<T>>`. The cubit tracks the
/// current page, accumulates items, and figures out `hasReachedMax` by
/// comparing the returned page length against [pageSize].
///
/// ```dart
/// final cubit = PaginationCubit<ProductEntity>(
///   fetchPage: (page) => getProductsUsecase(
///     PaginationParams(page: page, limit: 20),
///   ),
/// );
/// ```
///
/// Pair it with [PaginatedListView] to get the scroll-triggered
/// `fetchNextPage()` calls and standard loading/empty/error UI for free.
class PaginationCubit<T> extends Cubit<PaginationState<T>> {
  final Future<Either<Failure, List<T>>> Function(int page) fetchPage;
  final int pageSize;

  PaginationCubit({required this.fetchPage, this.pageSize = 20})
      : super(const PaginationState());

  Future<void> fetchFirstPage() async {
    emit(
      state.copyWith(status: PaginationStatus.loadingFirstPage, page: 0, failure: null),
    );
    final result = await fetchPage(1);
    result.fold(
      (failure) => emit(state.copyWith(status: PaginationStatus.failure, failure: failure)),
      (items) => emit(
        PaginationState<T>(
          items: items,
          status: PaginationStatus.success,
          page: 1,
          hasReachedMax: items.length < pageSize,
        ),
      ),
    );
  }

  Future<void> fetchNextPage() async {
    if (state.hasReachedMax || state.status == PaginationStatus.loadingNextPage) return;

    emit(state.copyWith(status: PaginationStatus.loadingNextPage, failure: null));
    final nextPage = state.page + 1;
    final result = await fetchPage(nextPage);
    result.fold(
      (failure) => emit(state.copyWith(status: PaginationStatus.failure, failure: failure)),
      (items) => emit(
        state.copyWith(
          items: [...state.items, ...items],
          status: PaginationStatus.success,
          page: nextPage,
          hasReachedMax: items.length < pageSize,
        ),
      ),
    );
  }

  Future<void> refresh() => fetchFirstPage();
}
