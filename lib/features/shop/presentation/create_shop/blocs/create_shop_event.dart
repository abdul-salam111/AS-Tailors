import 'package:equatable/equatable.dart';

abstract class CreateShopEvent extends Equatable {
  const CreateShopEvent();

  @override
  List<Object> get props => [];
}

class ShopNameChangedEvent extends CreateShopEvent {
  final String name;
  const ShopNameChangedEvent(this.name);

  @override
  List<Object> get props => [name];
}

class CreateShopSubmitted extends CreateShopEvent {}
