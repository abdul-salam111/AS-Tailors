import 'package:equatable/equatable.dart';

/// Standard params for a paginated usecase — pass this as a [Usecase]'s
/// `Params` type when the repository call takes a page number.
class PaginationParams extends Equatable {
  final int page;
  final int limit;

  const PaginationParams({required this.page, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}
