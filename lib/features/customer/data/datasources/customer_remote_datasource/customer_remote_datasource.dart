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

  /// Count of active customers in [shopId], optionally restricted to ones
  /// created on/after [since] (e.g. "new this week" on the dashboard).
  Future<int> getCustomerCount({required String shopId, DateTime? since});

  /// Atomic "new customer" wizard submit — see `create_customer_with_
  /// order()` (`0010_create_customer_with_order.sql`). Returns the raw
  /// `{"customer": {...}, "measurement_profile": {...}, "order": {...}}`
  /// jsonb result; the repository parses each nested object into its own
  /// feature's Model.
  Future<Map<String, dynamic>> createCustomerWithOrder({
    required String shopId,
    required String fullName,
    String? whatsapp,
    String? address,
    String? customerNotes,
    required String templateId,
    String? measurementName,
    required String unit,
    String? measurementNotes,
    required List<Map<String, dynamic>> measurementValues,
    required int quantity,
    required double unitPrice,
    DateTime? dueDate,
    String? orderNotes,
    String? itemNotes,
  });
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

  @override
  Future<int> getCustomerCount({required String shopId, DateTime? since}) => guard(() {
    var query = client.from(_table).count().eq('shop_id', shopId).eq('is_active', true);
    if (since != null) {
      query = query.gte('created_at', since.toIso8601String());
    }
    return query;
  });

  @override
  Future<Map<String, dynamic>> createCustomerWithOrder({
    required String shopId,
    required String fullName,
    String? whatsapp,
    String? address,
    String? customerNotes,
    required String templateId,
    String? measurementName,
    required String unit,
    String? measurementNotes,
    required List<Map<String, dynamic>> measurementValues,
    required int quantity,
    required double unitPrice,
    DateTime? dueDate,
    String? orderNotes,
    String? itemNotes,
  }) => rpc(
    function: 'create_customer_with_order',
    params: {
      'p_shop_id': shopId,
      'p_full_name': fullName,
      'p_whatsapp': whatsapp,
      'p_address': address,
      'p_customer_notes': customerNotes,
      'p_template_id': templateId,
      'p_measurement_name': measurementName,
      'p_unit': unit,
      'p_measurement_notes': measurementNotes,
      'p_measurement_values': measurementValues,
      'p_quantity': quantity,
      'p_unit_price': unitPrice,
      'p_due_date': dueDate == null ? null : _dateOnly(dueDate),
      'p_order_notes': orderNotes,
      'p_item_notes': itemNotes,
    },
    parser: (data) => data as Map<String, dynamic>,
  );

  /// Postgres `date` wants `YYYY-MM-DD`, not a full ISO-8601 timestamp —
  /// same helper as `OrderRemoteDatasourceImpl._dateOnly`.
  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
