import 'dart:async';

import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/real_estate_type.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/models/user.dart';
import 'package:flutter/material.dart';

class Res {
  static const host = 'https://bunyan.qa/';
  static final baseUrl = '${host}api/';
  static final titleStream = StreamController.broadcast();
  static final bottomNavBarAnimStream = StreamController<bool>.broadcast();
  static final selectedPageStream = StreamController<int>.broadcast();
  static PersonModel USER;
  static List<CategoryModel> catgories;
  static List<RegionModel> regions;
  static List<RealEstateTypeModel> realEstateTypes;
  static List<CategoryModel> servicesCategories;
  static final PAGE_SIZE = 5;
  static BuildContext mainContext;
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static final PAGE_SELECTOR_STREAM = StreamController<int>.broadcast();


  static String token = '';

  static bool shownDialog = false;
}