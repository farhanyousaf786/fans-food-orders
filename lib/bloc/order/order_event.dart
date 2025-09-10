part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {
  List<Object?> get props => [];
}

class UpdateUI extends OrderEvent {}

class FetchOrders extends OrderEvent {
  final List<String> shopIds;

  FetchOrders(this.shopIds);

  @override
  List<Object?> get props => [shopIds];
}



class UpdateOrderLocation extends OrderEvent {
  final String orderId;
  final GeoPoint location;

  UpdateOrderLocation(this.orderId, this.location);

  @override
  List<Object?> get props => [orderId, location];
}

class UpdateTipEvent extends OrderEvent {
  final double tipAmount;

  UpdateTipEvent(this.tipAmount);

  @override
  List<Object?> get props => [tipAmount];
}
