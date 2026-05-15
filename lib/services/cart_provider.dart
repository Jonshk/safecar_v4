import 'package:flutter/material.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (s, i) => s + i.qty);
  double get total => _items.fold(0.0, (s, i) => s + i.subtotal);
  bool get isEmpty => _items.isEmpty;

  void add(Part part) {
    final idx = _items.indexWhere((i) => i.part.id == part.id);
    if (idx >= 0) {
      _items[idx].qty++;
    } else {
      _items.add(CartItem(part: part));
    }
    notifyListeners();
  }

  void remove(int partId) {
    _items.removeWhere((i) => i.part.id == partId);
    notifyListeners();
  }

  void decrement(int partId) {
    final idx = _items.indexWhere((i) => i.part.id == partId);
    if (idx >= 0) {
      if (_items[idx].qty > 1) {
        _items[idx].qty--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool contains(int partId) => _items.any((i) => i.part.id == partId);
}
