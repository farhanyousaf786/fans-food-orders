import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';

import '../../models/order.dart';
import '../../order_repository.dart';


part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();

  OrderBloc() : super(OrderInitial()) {
    on<UpdateUI>((event, emit) {
      emit(OrderInitial());
      emit(UIUpdated());
    });

    on<FetchOrders>((event, emit) async {
      emit(OrdersFetching());
      await emit.forEach<List<OrderModel>>(
        orderRepository.streamOrders(event.shopIds),
        onData: (orders) => OrdersFetched(orders),
        onError: (error, stackTrace) {
          debugPrint(error.toString());
          debugPrint(stackTrace.toString());
          return OrderFetchingError(error.toString());
        },
      );
    });





  }

  @override
  Future<void> close() {
    return super.close();
  }
}
