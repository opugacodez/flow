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
        _catService.getCats(),
        _filterController.stream,
        _applyFilters,
      );

  CatFilter get currentFilter => _filterController.value;

  List<Cat> _applyFilters(List<Cat> cats, CatFilter filter) {
    return cats.where((cat) {
      final statusMatch = cat.status == 'Disponível';

      final filterMatch =
          (filter.gender.isEmpty || cat.gender == filter.gender) &&
          (filter.size.isEmpty || cat.size == filter.size) &&
          (filter.color.isEmpty || cat.color == filter.color) &&
          (filter.location.isEmpty || cat.location == filter.location) &&
          (cat.age >= filter.minAge && cat.age <= filter.maxAge);

      return statusMatch && filterMatch;
    }).toList();
  }

  void updateFilter(CatFilter newFilter) {
    _filterController.add(newFilter);
  }

  @override
  void dispose() {
    _filterController.close();
    super.dispose();
  }
}
