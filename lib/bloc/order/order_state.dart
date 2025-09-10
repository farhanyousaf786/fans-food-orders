part of 'order_bloc.dart';

@immutable
abstract class OrderState {}

class OrderInitial extends OrderState {}

class UIUpdated extends OrderState {
  UIUpdated();
}




class OrdersFetching extends OrderState {}

class OrdersFetched extends OrderState {
  final List<OrderModel> orders;

  OrdersFetched(this.orders);
}

class OrderFetchingError extends OrderState {
  final String message;

  OrderFetchingError(this.message);
}



class OrderLocationUpdateError extends OrderState {
  final String message;

  OrderLocationUpdateError(this.message);

  List<Object?> get props => [message];
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);

  List<Object?> get props => [message];
}

class OrderLocationUpdated extends OrderState {
  List<Object?> get props => [];
}

