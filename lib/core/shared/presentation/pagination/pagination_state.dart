import 'package:equatable/equatable.dart';
import '../../domain/failures/failure.dart';

enum PaginationStatus { initial, loadingFirstPage, loadingNextPage, success, failure }

class PaginationState<T> extends Equatable {
  final List<T> items;
  final PaginationStatus status;
  final Failure? failure;
  final bool hasReachedMax;
  final int page;

  const PaginationState({
    this.items = const [],
    this.status = PaginationStatus.initial,
    this.failure,
    this.hasReachedMax = false,
    this.page = 0,
  });

  bool get isEmpty => hasReachedMax && items.isEmpty && status == PaginationStatus.success;

  PaginationState<T> copyWith({
    List<T>? items,
    PaginationStatus? status,
    Failure? failure,
    bool? hasReachedMax,
    int? page,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      failure: failure,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [items, status, failure, hasReachedMax, page];
}
