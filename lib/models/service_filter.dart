import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';

class ServicesFilterModel {
  String city;
  String category;
  int minPrice;
  int maxPrice;
  String search;
  bool promoted;

  ServicesFilterModel({
    this.city,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.search,
    this.promoted,
  });

  bool get isNull =>
      city == null &&
      category == null &&
      minPrice == null &&
      maxPrice == null &&
      search == null &&
          promoted == null;

  Map<String, dynamic> toRequest() {
    if (!isNull) {
      Map<String, dynamic> data = {};

      if (this.city != null)
        data["region[]"] = this
            .city
            .toLowerCase()
            .replaceAll(RegExp("[\$&+,:;=?@#|'<>.*()%!/]"), '')
            .replaceAll(RegExp(' +'), ' ')
            .replaceAll(' ', '-');

      if (this.category != null)
        data['category'] = this
            .category
            .toLowerCase()
            .replaceAll(RegExp("[\$&+,:;=?@#|'<>.*()%!/]"), '')
            .replaceAll(RegExp(' +'), ' ')
            .replaceAll(' ', '-');

      if (this.minPrice != null) data['min'] = minPrice;

      if (this.maxPrice != null) data['max'] = this.maxPrice;

      if (this.search != null) data['search'] = this.search;

      if (this.promoted != null && this.promoted) data['promoted'] = 'Promoted';

      return data;
    }
    return null;
  }
}
