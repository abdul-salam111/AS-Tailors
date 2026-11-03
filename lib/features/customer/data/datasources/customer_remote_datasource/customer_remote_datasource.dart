import '../../../../../core/shared/shared_exports.dart';
import '../../models/customer_model.dart';

abstract interface class ICustomerRemoteDatasource {
  Future<CustomerModel> createCustomer({
    required String shopId,
    required String fullName,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? notes,
  });

  /// [search] matches against the customer's name and phone number (raw
  /// and normalized), per SRS §23.4. Empty string returns every active
  /// customer in the shop.
  Future<List<CustomerModel>> getCustomers({
    required String shopId,
    required int page,
    required int limit,
    String search = '',
  });

  Future<CustomerModel> getCustomerById(String id);

  Future<CustomerModel> updateCustomer({
    required String id,
    required String fullName,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? notes,
  });

  Future<CustomerModel> archiveCustomer(String id);
}

class CustomerRemoteDatasourceImpl extends BaseSupabaseDatasource
    implements ICustomerRemoteDatasource {
  const CustomerRemoteDatasourceImpl({required super.client});

  static const _table = 'customers';

  @override
  Future<CustomerModel> createCustomer({
    required String shopId,
    required String fullName,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? notes,
  }) => single(
    query: () => client
        .from(_table)
        .insert({
          'shop_id': shopId,
          'full_name': fullName,
          'phone': phone,
          'whatsapp': whatsapp,
          'email': email,
          'address': address,
          'notes': notes,
        })
        .select()
        .single(),
    parser: CustomerModel.fromJson,
  );

  @override
  Future<List<CustomerModel>> getCustomers({
    required String shopId,
    required int page,
    required int limit,
    String search = '',
  }) => list(
    query: () {
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      final term = search.trim();

      var query = client.from(_table).select().eq('shop_id', shopId).eq('is_active', true);
      if (term.isNotEmpty) {
        final digitsOnly = term.replaceAll(RegExp(r'\D'), '');
        final phoneTerm = digitsOnly.isNotEmpty ? digitsOnly : term;
        query = query.or(
          'full_name.ilike.%$term%,phone.ilike.%$term%,normalized_phone.ilike.%$phoneTerm%',
        );
      }

      return query.order('created_at', ascending: false).range(from, to);
    },
    parser: CustomerModel.fromJson,
  );

  @override
  Future<CustomerModel> getCustomerById(String id) => single(
    query: () => client.from(_table).select().eq('id', id).single(),
    parser: CustomerModel.fromJson,
  );

  @override
  Future<CustomerModel> updateCustomer({
    required String id,
    required String fullName,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? notes,
  }) => single(
    query: () => client
        .from(_table)
        .update({
          'full_name': fullName,
          'phone': phone,
          'whatsapp': whatsapp,
          'email': email,
          'address': address,
          'notes': notes,
        })
        .eq('id', id)
        .select()
        .single(),
    parser: CustomerModel.fromJson,
  );

  @override
  Future<CustomerModel> archiveCustomer(String id) => single(
    query: () => client.from(_table).update({'is_active': false}).eq('id', id).select().single(),
    parser: CustomerModel.fromJson,
  );
}
