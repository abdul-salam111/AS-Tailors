import '../../../../core/shared/domain/usecases/pagination_params.dart';

/// [PaginationParams] plus a free-text [search] term matched against the
/// customer's name and phone number (SRS §23.4: "search by name, normalized
/// phone number or WhatsApp number"). Empty string means no filter.
class GetCustomersParams extends PaginationParams {
  final String search;

  const GetCustomersParams({required super.page, super.limit = 20, this.search = ''});

  @override
  List<Object?> get props => [page, limit, search];
}
