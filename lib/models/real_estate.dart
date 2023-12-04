import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/tools/res.dart';

class RealEstate extends ProductListModel {
    dynamic adr;
    int id;
    int idCity;
    List<dynamic> photos;
    double price;
    String title;

    RealEstate({this.adr, this.id, this.idCity, this.photos, this.price, this.title});

    factory RealEstate.fromJson(Map<String, dynamic> json) {
        return RealEstate(
            adr: json['adresse'], 
            id: int.parse(json['id'].toString()),
            idCity: int.parse(json['id_c'].toString()),
            photos: json['image'].toString().startsWith('http') ? json['image'] : '${Res.baseUrl}images/${json['image']}',
            price: double.parse(json['prix'].toString()),
            title: json['titre'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['adresse'] = this.adr;
        data['id'] = this.id.toString();
        data['id_c'] = this.idCity.toString();
        data['image'] = this.photos;
        data['prix'] = this.price.toString();
        data['titre'] = this.title;
        return data;
    }
}