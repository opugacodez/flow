import 'package:flow/models/cat.dart';
import 'package:flow/models/filter.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class CatalogProvider with ChangeNotifier {
  final CatService _catService = CatService();

  final _filterController = BehaviorSubject<CatFilter>.seeded(CatFilter());

  Stream<List<Cat>> get filteredCatsStream =>
      Rx.combineLatest2<List<Cat>, CatFilter, List<Cat>>(
        _catService.getAvailableCats(),
        _filterController.stream,
        _applyUiFilters,
      );

  CatFilter get currentFilter => _filterController.value;

  List<Cat> _applyUiFilters(List<Cat> cats, CatFilter filter) {
    if (filter.isDefault()) {
      return cats;
    }

    return cats.where((cat) {
      if (cat.status == 'Adoção em andamento') {
        return true;
      }

      final filterMatch =
          (filter.gender.isEmpty || cat.gender == filter.gender) &&
              (filter.size.isEmpty || cat.size == filter.size) &&
              (filter.color.isEmpty || cat.color == filter.color) &&
              (filter.location.isEmpty || cat.location == filter.location) &&
              (cat.age >= filter.minAge && cat.age <= filter.maxAge);

      return filterMatch;
    }).toList();
  }

  void updateFilter(CatFilter newFilter) {
    _filterController.add(newFilter);
  }

  void clearFilters() {
    _filterController.add(CatFilter());
  }

  @override
  void dispose() {
    _filterController.close();
    super.dispose();
  }
}