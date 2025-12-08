import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../services/order_services.dart';


// class OrderProviders extends StateNotifier<OrderState> {
//   OrderProviders() : super(OrderState());

//   final OrderServices _orderServices = OrderServices();

//   Future<void> createOrder(CreateOrderParams params) async {
//     final order = await _orderServices.createOrder(params);
//     state = state.copyWith(orderNo: order);
//   }


//   Future<void> createSPI(String orderId) async {
//     final spi = await _orderServices.createSPI(orderId);
//     state = state.copyWith(clientSecret: spi.clientSecret);
//   }
// } 