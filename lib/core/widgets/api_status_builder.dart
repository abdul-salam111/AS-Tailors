import 'package:flutter/material.dart';
import '../constants/app_enums.dart';
import '../shared/domain/failures/failure.dart';
import '../utils/failure_mapper.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';
import 'loading_indicator.dart';

/// Collapses the loading/empty/error/success branching every feature was
/// hand-rolling inside a `BlocBuilder` into one declarative widget.
///
/// ```dart
/// BlocBuilder<ProductBloc, ProductState>(
///   builder: (context, state) => ApiStatusBuilder<ProductEntity>(
///     status: state.apiStatus,
///     data: state.product,
///     failure: state.failure,
///     onRetry: () => context.read<ProductBloc>().add(FetchProductEvent('id')),
///     builder: (context, product) => Text(product.name),
///   ),
/// )
/// ```
class ApiStatusBuilder<T> extends StatelessWidget {
  final ApiStatus status;
  final T? data;
  final Failure? failure;
  final Widget Function(BuildContext context, T data) builder;

  /// Return true to treat non-null [data] as empty (e.g. an empty list).
  final bool Function(T data)? isEmpty;

  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final VoidCallback? onRetry;

  const ApiStatusBuilder({
    super.key,
    required this.status,
    required this.data,
    required this.builder,
    this.failure,
    this.isEmpty,
    this.loadingWidget,
    this.emptyWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ApiStatus.INITIAL:
      case ApiStatus.LOADING:
        return loadingWidget ?? const LoadingIndicator();

      case ApiStatus.FAILURE:
        return ErrorStateWidget(
          message: failure != null
              ? AppFailureMapper.map(failure!).message
              : 'Something went wrong',
          onRetry: onRetry,
        );

      case ApiStatus.SUCCESS:
        final value = data;
        if (value == null || (isEmpty?.call(value) ?? false)) {
          return emptyWidget ?? const EmptyStateWidget();
        }
        return builder(context, value);
    }
  }
}
