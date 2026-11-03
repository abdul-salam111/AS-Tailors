class CreateShopParams {
  final String name;
  final String? phone;
  final String currency;
  final String timezone;

  const CreateShopParams({
    required this.name,
    this.phone,
    this.currency = 'PKR',
    this.timezone = 'Asia/Karachi',
  });
}
