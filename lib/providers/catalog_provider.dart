import 'package:flow/models/cat.dart';
import 'package:flow/models/filter.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flutter/cupertino.dart';

class CatalogProvider with ChangeNotifier {
  final CatService _catService = CatService();
  List<Cat> _cats = [];
  List<Cat> _filteredCats = [];
  CatFilter _currentFilter = CatFilter();

  List<Cat> get cats => _filteredCats;
  CatFilter get currentFilter => _currentFilter;

  Future<void> loadCats() async {
    _cats = await _catService.getCats();
    _applyFilters();
  }

  void _applyFilters() {
    _filteredCats = _cats.where((cat) {
      return (_currentFilter.gender.isEmpty || cat.gender == _currentFilter.gender) &&
          (_currentFilter.size.isEmpty || cat.size == _currentFilter.size) &&
          (_currentFilter.color.isEmpty || cat.color == _currentFilter.color) &&
          (_currentFilter.location.isEmpty || cat.location == _currentFilter.location) &&
          (cat.age >= _currentFilter.minAge && cat.age <= _currentFilter.maxAge);
    }).toList();
    notifyListeners();
  }

  void updateFilter(CatFilter newFilter) {
    _currentFilter = newFilter;
    _applyFilters();
  }

  void toggleFavorite(String catId) {
    final index = _cats.indexWhere((c) => c.id == catId);
    _cats[index].isFavorited = !_cats[index].isFavorited;
    _applyFilters();
    notifyListeners();
  }

}