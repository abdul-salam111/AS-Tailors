import 'package:equatable/equatable.dart';

abstract class CreateShopEvent extends Equatable {
  const CreateShopEvent();

  @override
  List<Object> get props => [];
}

/// Fired once on screen load — checks whether the single shop already
/// exists and, if so, auto-joins the caller as staff instead of showing
/// the create-shop form.
class CreateShopInitialized extends CreateShopEvent {}

class ShopNameChangedEvent extends CreateShopEvent {
  final String name;
  const ShopNameChangedEvent(this.name);

  @override
  List<Object> get props => [name];
}

class CreateShopSubmitted extends CreateShopEvent {}
