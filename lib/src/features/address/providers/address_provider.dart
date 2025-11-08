import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger/logger.dart';
import '../models/address_models.dart';
import '../services/address_services.dart';

const _kSentinel = Object();

class AddressListState {
  final List<AddressItem> addresses;
  final bool isLoading;
  final String? error;

  const AddressListState({
    this.addresses = const [],
    this.isLoading = false,
    this.error,
  });

  AddressListState copyWith({
    List<AddressItem>? addresses,
    bool? isLoading,
    Object? error = _kSentinel,
  }) {
    return AddressListState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _kSentinel) ? this.error : error as String?,
    );
  }
}

class AddressListNotifier extends StateNotifier<AddressListState> {
  AddressListNotifier() : super(const AddressListState());

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final addresses = await AddressServices.getUserAddressList();
      state = state.copyWith(
        addresses: addresses,
        isLoading: false,
        error: null,
      );
      Logger.info('AddressListNotifier', '地址列表加载成功，共 ${addresses.length} 条');
    } catch (e, stack) {
      Logger.error('AddressListNotifier', '地址列表加载失败: $e', stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => loadAddresses();

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class StateListState {
  final List<StateItem> states;
  final bool isLoading;
  final String? error;

  const StateListState({
    this.states = const [],
    this.isLoading = false,
    this.error,
  });

  StateListState copyWith({
    List<StateItem>? states,
    bool? isLoading,
    Object? error = _kSentinel,
  }) {
    return StateListState(
      states: states ?? this.states,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _kSentinel) ? this.error : error as String?,
    );
  }
}

class StateListNotifier extends StateNotifier<StateListState> {
  StateListNotifier() : super(const StateListState());

  Future<void> loadStates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final states = await AddressServices.getStateList();
      state = state.copyWith(
        states: states,
        isLoading: false,
        error: null,
      );
      Logger.info('StateListNotifier', '州列表加载成功，共 ${states.length} 条');
    } catch (e, stack) {
      Logger.error('StateListNotifier', '州列表加载失败: $e', stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final addressListProvider =
    StateNotifierProvider<AddressListNotifier, AddressListState>(
  (ref) => AddressListNotifier(),
);

final stateListProvider = StateNotifierProvider<StateListNotifier, StateListState>(
  (ref) => StateListNotifier(),
);

