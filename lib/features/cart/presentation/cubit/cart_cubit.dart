// lib/features/cart/presentation/cubit/cart_cubit.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart'; // <<< اصلاح شد: از ":" به جای "." استفاده شد
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final SharedPreferences _sharedPreferences;
  // <<< اصلاح شد: نام متغیرها به درستی تعریف و استفاده شد
  static const _itemsKey = 'cart_items_map';
  static const _selectedStoresKey = 'cart_selected_stores';

  CartCubit({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        super(const CartState(items: {}, selectedStoreIds: []));

  void loadCartProducts() {
    final cartItemsString = _sharedPreferences.getString(_itemsKey);
    final selectedStores =
        _sharedPreferences.getStringList(_selectedStoresKey) ?? [];

    Map<String, int> cartItems = {};
    if (cartItemsString != null) {
      try {
        final Map<String, dynamic> decodedMap = json.decode(cartItemsString);
        cartItems =
            decodedMap.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        cartItems = {};
      }
    }
    emit(CartState(items: cartItems, selectedStoreIds: selectedStores));
  }

  Future<void> _saveState() async {
    final String encodedMap = json.encode(state.items);
    await _sharedPreferences.setString(_itemsKey, encodedMap);
    await _sharedPreferences.setStringList(
        _selectedStoresKey, state.selectedStoreIds);
  }

  void addProduct(String productId, String storeId) {
    final newItems = Map<String, int>.from(state.items);
    final newSelectedStores = List<String>.from(state.selectedStoreIds);

    newItems.update(productId, (value) => value + 1, ifAbsent: () => 1);

    if (!newSelectedStores.contains(storeId)) {
      newSelectedStores.add(storeId);
    }

    emit(CartState(items: newItems, selectedStoreIds: newSelectedStores));
    _saveState();
  }

  void removeProduct(String productId) {
    final newItems = Map<String, int>.from(state.items);
    if (newItems.containsKey(productId)) {
      if (newItems[productId]! > 1) {
        newItems.update(productId, (value) => value - 1);
      } else {
        newItems.remove(productId);
      }
      emit(CartState(items: newItems, selectedStoreIds: state.selectedStoreIds));
      _saveState();
    }
  }

  void clearProductFromCart(String productId) {
    final newItems = Map<String, int>.from(state.items);
    if (newItems.containsKey(productId)) {
      newItems.remove(productId);
      emit(CartState(items: newItems, selectedStoreIds: state.selectedStoreIds));
      _saveState();
    }
  }

  void toggleStoreSelection(String storeId) {
    final newSelectedStores = List<String>.from(state.selectedStoreIds);
    if (newSelectedStores.contains(storeId)) {
      newSelectedStores.remove(storeId);
    } else {
      newSelectedStores.add(storeId);
    }
    emit(CartState(items: state.items, selectedStoreIds: newSelectedStores));
    _saveState();
  }
}