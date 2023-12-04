import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';

class PropertiesFilterModel {
  String city;
  String category;
  int rooms;
  int baths;
  int minPrice;
  int maxPrice;
  String furnished;
  String search;
  bool promoted;
  bool forRent;



  PropertiesFilterModel(
      {this.city,
      this.category,
      this.rooms,
      this.baths,
      this.minPrice,
      this.maxPrice,
      this.furnished,
      this.search,
      this.promoted,
        this.forRent
      });

  bool get isNull =>
      city == null &&
      category == null &&
      rooms == null &&
      baths == null &&
      minPrice == null &&
      maxPrice == null &&
      furnished == null &&
          promoted == null &&
          forRent == null &&
      search == null;

  Map<String, dynamic> toRequest() {
    if (!isNull) {
      Map<String, dynamic> data = {};

      if (this.city != null)
        data["region[]"] = this.city.toLowerCase().replaceAll(RegExp("[\$&+,:;=?@#|'<>.*()%!/]"), '').replaceAll(RegExp(' +'), ' ').replaceAll(' ', '-');

      if (this.category != null)
        data['category'] = this.category.toLowerCase().replaceAll(RegExp("[\$&+,:;=?@#|'<>.*()%!/]"), '').replaceAll(RegExp(' +'), ' ').replaceAll(' ', '-');

      if (this.rooms != null)
        data['bedrooms'] = this.rooms;

      if (this.baths != null)
        data['bathrooms'] = this.baths;

      if (this.minPrice != null)
        data['min'] = minPrice;

      if (this.maxPrice != null)
        data['max'] = this.maxPrice;

      if (this.furnished != null)
        data['furnish'] = this.furnished;

      if (this.search != null)
        data['search'] = this.search;

      if (this.promoted != null && this.promoted)
        data['promoted'] = 'Promoted';

      if (this.forRent != null)
        data['type'] = this.forRent ? 'Rent' : 'Sale';



      return data;
    }
    return null;
  }
}
