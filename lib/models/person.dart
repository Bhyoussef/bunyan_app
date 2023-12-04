import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:equatable/equatable.dart';

class PersonModel extends Equatable {
  int id;
  String name;
  String email;
  int followers;
  bool isFollowing;
  String phone;
  String photo;
  String password;
  String oldPAsswd;
  EnterpriseModel enterprise;
  String companyName;

  PersonModel({this.id, this.name, this.email, this.followers, this.isFollowing, this.phone, this.photo, this.enterprise, this.companyName, this.password});

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: int.tryParse(json.get("id").toString()),
      name: json.get("name"),
      email: json.get("email"),
      followers: json.get("followers_number") ,
      isFollowing: json.get("is_following") ,
      phone: json.get('phone') != null ? json['phone'].toString() : '',
      photo: json.get('photo') ?? '',
      enterprise: json.get('entreprise') != null ? EnterpriseModel.fromJson(json['entreprise']) : null,
      companyName: json.get('company_name'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id.toString(),
      "name": this.name,
      "email": this.email,
      "followers": this.followers,
      "isFollowing": this.isFollowing,
      "phone": this.phone,
      'photo': this.photo,
      "entreprise": this.enterprise == null ? null : this.enterprise.toJson(),
      "company_name": this.companyName,
    };
  }

  String get userType => this.companyName != null ? 'Company' : 'Individual';

  bool get isCompany => this.userType == "Company";


  Map<String, dynamic> toRequest() {
    return {
      "name": this.name,
      "email": this.email,
      "phone": this.phone,
      "password": this.password,
      'password_confirmation': this.password,
      "company_name": this.companyName,
      'user_type': this.userType,
    };
  }

  Map<String, dynamic> toUpdateRequest() {
    return {
      "name": this.name,
      "email": this.email,
      "phone": this.phone,
      "company_name": this.companyName,
    };
  }


  Map<String, dynamic> toUpdatePasswordRequest() {
    return {
      "password": this.password,
      "old_password": this.oldPAsswd,
    };
  }

  @override
  List<Object> get props => [id];

}