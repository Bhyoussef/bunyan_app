import 'dart:async';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/Furnish.dart';
import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/position.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/real_estate_type.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/common/location_picker.dart';
import 'package:bunyan/ui/picker/media_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/pakage.dart';
import '../../models/pakage.dart';
import '../../models/pakage.dart';
import '../../models/pakage.dart';

class RealEstatePage extends StatefulWidget {
  RealEstatePage({Key key, this.product}) : super(key: key);
  final ProductModel product;

  @override
  _RealEstatePageState createState() => _RealEstatePageState();
}

class _RealEstatePageState extends State<RealEstatePage> {
  RealEstateTypeModel _type;
  CategoryModel _category;
  RegionModel _region;
  CityModel _city;
  bool _furnished;
  bool _swimmingPool;

  ProductModel _product;

  List<dynamic> _photos = [];
  List<int> _photosToRemove = [];
  final _furnishs = [
    Furnish(name: "Fully Furnished", id: true, name_ar: 'جميع المفروشات'),
    Furnish(name: "Semi Furnished", id: false, name_ar: 'مفروش جزئيا'),
    Furnish(name: "Unfurnished", id: true, name_ar: 'غير مفروش'),
  ];
  final _formKey = GlobalKey<FormState>();
  bool _showPhotoError = false;
  bool _showLocationError = false;
  bool _showTypeError = false;
  final _roomsController = TextEditingController();
  final _priceController = TextEditingController();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _titlearabicController = TextEditingController();
  final _descControllerArabic = TextEditingController();
  final _descController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _sizeController = TextEditingController();
  final _promoted_for=TextEditingController();
  PositionModel _position = null;
  PositionModel _selectedPosition;
  bool _isRequesting = false;
  bool _isFetching = false;
  bool _isBanner = false;
  bool _isSpecial = false;
  bool _isNormal = false;
  bool showbutton = true;
  bool _isLoadingLocation = false;
  LocationData mycurrentLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _cameraPosition;
  Completer<GoogleMapController> _mapController = Completer();
  List<Pakage> pakage = [];
  List<Pakage> _premiumpakage = [];
  List<Pakage> _premiumbanner = [];
  List<Pakage> _busniss = [];
  String _selectedPlanType;
  Pakage _selectedPlan;
  bool _isChecked = false;
  bool _showpakage;

  final List<Map<String, dynamic>> _mainList = [
    {
      "title": "Normale Listing",
      "image": "assets/realstate.png",
      "sublist": [
        {"title": "Ads For 07 days", "price": "QAR 100"},
        {"title": "Ads For 15 days", "price": "QAR 100"},
        {"title": "Ads For 01 Months ", "price": ""}
      ],
    },
    {
      "title": "Banner Listing",
      "image": "assets/banner_real.png",
      "sublist": [
        {"title": "1 Banner 1 Mounths", "price": "QAR  100"},
      ],
    },
    {
      "title": "Premium Listing",
      "image": "assets/premium_real.jpeg",
      "sublist": [
        {"title": "1 Premium 1 Mounth", "price": "QAR 500"},
      ],
    },
    {
      "title": "Business Listing",
      "image": "assets/business_real.png",
      "sublist": [],
    },
  ];
/*  final List<Map<String, dynamic>> _mainList = [
    {
      "title": "Normale Listing",
      "image": "assets/real_state.jpeg",
      "sublist": [
        {"title": "Subitem 1", "price": "10.99"},
        {"title": "Subitem 2", "price": "12.99"},
        {"title": "Subitem 3", "price": "15.99"}
      ],
    },
    {
      "title": "Banner Listing",
      "image": "assets/premium_real.jpeg",
      "sublist": [
        {"title": "Subitem 4", "price": "9.99"},
        {"title": "Subitem 5", "price": "14.99"},
        {"title": "Subitem 6", "price": "18.99"}
      ],
    },
    {
      "title": "Premium Listing",
      "image": "assets/premium_real.jpeg",
      "sublist": [
        {"title": "Subitem 7", "price": "7.99"},
        {"title": "Subitem 8", "price": "11.99"},
        {"title": "Subitem 9", "price": "13.99"}
      ],
    },
    {
      "title": "Business Listing",
      "image": "assets/business_real.png",
      "sublist": [
        {"title": "Subitem 10", "price": "20.99"},
        {"title": "Subitem 11", "price": "8.99"},
        {"title": "Subitem 12", "price": "6.99"}
      ],
    },
  ];*/
/*  final List<Map<String, dynamic>> _mainList = [
    {
      "title": "Normale Listing",
      "sublist": [
        {"title": "", "image": "assets/real_estate.png"},
      ],
    },
    {
      "title": "Banner Listing",
      "sublist": [
        {"image": "assets/banner_real.png"},
      ],
    },
    {
      "title": "Premium Listing",
      "sublist": [
        {"image": "assets/premium_real_estate.png"},
      ],
    },
    {
      "title": "Business Listing",
      "sublist": [
        {"image": "assets/business_real.png"},
      ],
    },
  ];*/

  @override
  void initState() {
    _filterplans();
    _selectedPlanType = 'Premium';
    _isLoadingLocation = true;
    if (widget.product != null) {
      _getUpdateData();
      _product = widget.product;
      _titleController.text = _product.title;
      _titlearabicController.text = _product.titleAr;
      _product.region = Res.regions
          .where((element) => _product.region.name == element.name)
          .first;
      _region = _product.region;
      _roomsController.text = _product.rooms.toString();
      _bathroomsController.text = _product.bathrooms.toString();
      _sizeController.text = _product.landSize.toString();
      _priceController.text = _product.price.toString();
      _selectedPosition = PositionModel(lat: _product.lat, lng: _product.lng);
      _addressController.text = _product.adress;
      _descController.text = _product.description;
      _descControllerArabic.text = _product.descriptionAr;
      //_promoted_for.text=_product.promoted_for;
    } else
      _product = ProductModel(photos: []);
    getCurrentLocation();
    super.initState();
  }

  getCurrentLocation() async {
    final location = Location();
    mycurrentLocation = await location.getLocation();

    initMarker(mycurrentLocation.latitude, mycurrentLocation.longitude);
    setState(() {
      _position = PositionModel(
          lat: mycurrentLocation.latitude, lng: mycurrentLocation.longitude);
      print('_position ${_position.toJson()}');
      _isLoadingLocation = false;
    });
  }

  _filterplans() {
    ProductsWebService().getpakage(0).then((entrs) {
      setState(() {
        pakage = entrs;
        _isFetching = false;

        _premiumpakage =
            pakage.where((element) => element.type == 'Premium').toList();
        _premiumbanner =
            pakage.where((element) => element.type == 'Banner').toList();
        _busniss =
            pakage.where((element) => element.type == 'Business').toList();
        _busniss =
            pakage.where((plan) => plan.type == _selectedPlanType).toList();
        print(_premiumpakage);
        print(_premiumbanner);
        print(_busniss);
      });
    });
  }

  void initMarker(lat, lang) async {
    var markerIdVal = '1';
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lang),
      infoWindow: InfoWindow(title: 'test'),
    );
    print('lat ${marker.position.latitude}');
    setState(() {
      markers[markerId] = marker;
      _cameraPosition = CameraPosition(target: LatLng(lat, lang), zoom: 14.0);
      //print(markerId);
    });
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return _isRequesting
        ? _loadingWidget()
        : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        'Select Your Backage',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 35.sp,
                            color: Color(0xFF750606)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        '( Home page )',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            color: Color(0xFF750606)),
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  checkColor:Colors.white,
                  activeColor: Color(0xFF750606),
                  title: Text('Free',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.sp
                  ),),
                  value: _isChecked,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isChecked=newValue;
                      _showpakage=_isChecked;
                      print(_isChecked);
                    });
                  },
                ),

                _showpakage == true ? Container():Container(
                  height: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFF750606),
                              width: 1,
                            ),
                            /*gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF750606),
                                    Color(0xFF750606),
                                    Color(0xFF750606)
                                    //add more colors
                                  ]),*/
                            borderRadius: BorderRadius.circular(5),
                            // boxShadow: <BoxShadow>[
                            //   BoxShadow(
                            //       color: Color.fromRGBO(0, 0, 0, 0.10), //shadow for button
                            //       blurRadius: 5) //blur radius of shadow
                            // ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: _selectedPlanType,
                              items: [
                                DropdownMenuItem(
                                  child: Text(
                                    'Premium',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  value: 'Premium',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    'Banner',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  value: 'Banner',
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    'Business',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  value: 'Business',
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPlanType = value;
                                  _filterplans();
                                });
                              },
                              isExpanded:
                                  true, //make true to take width of parent widget
                              underline: Container(), //empty line
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                              dropdownColor: Colors.white,
                              iconEnabledColor: Color(0xFF750606),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _busniss.length,
                          itemBuilder: (context, index) {
                            final plan = _busniss[index];
                            return RadioListTile<Pakage>(

                              title: Text(plan.name,style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold
                              ),),
                              subtitle: Text('\QAR ${plan.price.toString()}',style: TextStyle(
                                  color: Color(0xFF750606)
                              ),),
                              value: plan,
                              groupValue: _selectedPlan,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPlan = value;
                                  print(_selectedPlan.price);
                                  _promoted_for.text=_selectedPlan.name;
                                  _product.promoted_for=_promoted_for.text;
                                  print(_product.promoted_for);
                                });
                              },

                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /*SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _mainList.length,
                    itemBuilder: (BuildContext context, int index) {
                      List<dynamic> sublist = _mainList[index]["sublist"];
                      List<Widget> subitemWidgets = sublist
                          .map((subitem) => Container(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(subitem["title"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                        color: Color(0xFF750606),
                                        fontSize: 30.sp)),
                                    SizedBox(height: 8.0),
                                    subitem["price"] != ''?Container(
                                      color: Colors.grey[800],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("${subitem["price"]}",
                                            style:
                                                TextStyle(color: Colors.white,
                                                fontSize: 20.sp,fontWeight: FontWeight.bold)),
                                      ),
                                    ):
                                    MaterialButton(onPressed: (){


                                    },
                                        color: Color(0xFF750606),

                                    child: Text('Pay',style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold

                                    ),),
                                    minWidth: 100.w,)
                                  ],
                                ),
                              ))
                          .toList();

                      return Container(
                       padding: EdgeInsets.all(6.0),
                        child: Container(
                          color: Colors.grey[200],
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Text(_premiumpakage[index].name,
                                   style:TextStyle( color: Color(0xFF750606),
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.bold)),
                              ],
                            ),
                            trailing: Icon(Icons.keyboard_arrow_down,
                              size: 35.sp,color: Color(0xFF750606)),
                            children: [
                              SizedBox(height: 8.0),
                              Container(
                                decoration: BoxDecoration(

                                ),
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ...subitemWidgets,
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),*/

                /*SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _mainList.length,
                    itemBuilder: (BuildContext context, int index) {
                      List<dynamic> sublist = _mainList[index]["sublist"];
                      List<Widget> subitemWidgets = sublist
                          .map((subitem) => Column(children: [
                                Image.asset(subitem["image"]),
                              ]))
                          .toList();

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          color: Colors.grey[200],
                          child: ExpansionTile(
                            title: Text(
                              _mainList[index]["title"],
                              style: TextStyle(
                                  color: Color(0xFF750606),
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF750606),
                              size: 60.sp,
                            ),
                            children: subitemWidgets,
                          ),
                        ),
                      );
                    },
                  ),
                ),*/
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    Languages.of(context).adPhoto,
                    style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 30.sp),
                  ),
                ),
                SizedBox(
                  height: .22.sh,
                  width: 1.sw,
                  child: ListView.builder(
                    itemCount: _photos.length + 1,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      dynamic photo;

                      if (index < _photos.length) photo = _photos[index];

                      return Center(
                        child: Wrap(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.w,
                              ),
                              child: index == _photos.length
                                  ? InkWell(
                                      onTap: _getMedium,
                                      child: Container(
                                        width: .15.sh - 10.0,
                                        height: .15.sh - 10.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0XFF4d4d4d),
                                              width: .8),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                            size: 50.sp,
                                            color: const Color(0XFF4d4d4d)
                                                .withOpacity(.7),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: photo == null
                                              ? Container(
                                                  width: .15.sh - 10.0,
                                                  height: .15.sh - 10.0,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color(
                                                            0XFF4d4d4d),
                                                        width: .8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                    ),
                                                  ),
                                                )
                                              : Stack(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 10.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                        child: photo
                                                                is MediaItem
                                                            ? Image.memory(
                                                                photo.thumb,
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: .15.sh -
                                                                    10.0,
                                                                height: .15.sh -
                                                                    10.0,
                                                              )
                                                            : CachedNetworkImage(
                                                                imageUrl:
                                                                    'https://bunyan.qa/images/posts/${photo['image']}',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: .15.sh -
                                                                    10.0,
                                                                height: .15.sh -
                                                                    10.0,
                                                              ),
                                                      ),
                                                    ),
                                                    /*if (!photo.isPhoto)
                                      Positioned(
                                        top: .0,
                                        left: .0,
                                        child: Container(
                                            padding: EdgeInsets
                                                .symmetric(
                                                vertical: 4.h,
                                                horizontal:
                                                20.w),
                                            decoration: BoxDecoration(
                                                color: const Color(
                                                    0XFF4d4d4d),
                                                borderRadius:
                                                BorderRadius.only(
                                                    bottomRight:
                                                    Radius.circular(
                                                        20.0))),
                                            child: Text(
                                              Languages.of(context)
                                                  .adVideo,
                                              style:
                                              GoogleFonts.cairo(
                                                  fontSize:
                                                  15.sp,
                                                  color: Colors
                                                      .white),
                                            )),
                                      )*/
                                                  ],
                                                ),
                                        ),
                                        ClipOval(
                                          child: InkWell(
                                            onTap: () {
                                              if (photo is Map)
                                                _photosToRemove
                                                    .add(photo['id']);
                                              setState(() {
                                                try {
                                                  if (photo is MediaItem)
                                                    _product.photos.removeWhere(
                                                        (p) =>
                                                            (photo as MediaItem)
                                                                .file
                                                                .path ==
                                                            p);
                                                } catch (e) {}
                                                _photos.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                              ),
                                              padding: EdgeInsets.all(3.0),
                                              child: Icon(
                                                Icons.close,
                                                size: 20.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_showPhotoError)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        Languages.of(context).adPhotoValidation,
                        style: TextStyle(color: Colors.red, fontSize: 12.0),
                      )),
                if (_showPhotoError)
                  SizedBox(
                    height: 35.h,
                  ),

                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  controller: _titleController,
                  onSaved: (txt) {
                    _product.title = txt;
                  },
                  validator: RequiredValidator(
                      errorText: Languages.of(context).required),
                  decoration: InputDecoration(
                    labelText: Languages.of(context).title,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  onSaved: (txt) {
                    _product.titleAr = txt;
                    _product.titleAr = txt;
                  },
                  controller: _titlearabicController,
                  validator: RequiredValidator(
                      errorText: Languages.of(context).required),
                  decoration: InputDecoration(
                    labelText: Languages.of(context).title_ar,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                // DropdownButtonFormField(
                //   items: Res.realEstateTypes
                //       .map((e) => DropdownMenuItem(
                //             child: Text(Languages.of(context).labelSelectLanguage ==
                //                     "English"
                //                 ? e.name
                //                 : e.arabicName),
                //             value: e,
                //           ))
                //       .toList(),
                //   value: _type,
                //   validator: (e) =>
                //       e == null ? Languages.of(context).required : null,
                //   isExpanded: true,
                //   onChanged: (val) {
                //     setState(() {
                //       _type = val;
                //     });
                //   },
                //   decoration: InputDecoration(
                //     labelText: Languages.of(context).adCatogory,
                //     enabledBorder: OutlineInputBorder(),
                //     border: OutlineInputBorder(borderSide: BorderSide(width: .4)),
                //     focusedBorder:
                //         OutlineInputBorder(borderSide: BorderSide(width: .4)),
                //     focusedErrorBorder:
                //         OutlineInputBorder(borderSide: BorderSide(width: .4)),
                //     errorBorder: OutlineInputBorder(
                //         borderSide: BorderSide(color: Colors.grey)),
                //   ),
                // ),
                SizedBox(
                  height: 35.h,
                ),
                DropdownButtonFormField(
                  items: Res.catgories
                      .map((e) => DropdownMenuItem(
                            child: Text(
                              Languages.of(context).labelSelectLanguage ==
                                      "English"
                                  ? e.name
                                  : e.arabicName,
                            ),
                            value: e.id,
                          ))
                      .toList(),
                  validator: (e) =>
                      e == null ? Languages.of(context).required : null,
                  value: _product.categoryId,
                  isExpanded: true,
                  onChanged: (val) {
                    setState(() {
                      _product.categoryId = val;
                    });
                  },
                  onSaved: (val) {
                    _product.categoryId = val;
                  },
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adSubcategory,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                DropdownButtonFormField(
                  validator: (e) =>
                      e == null ? Languages.of(context).required : null,
                  items: Res.regions
                      .map((e) => DropdownMenuItem(
                            child: Text(
                                Languages.of(context).labelSelectLanguage ==
                                        "English"
                                    ? e.name
                                    : e.nameAr),
                            value: e,
                          ))
                      .toList(),
                  value: _product.region,
                  isExpanded: true,
                  onChanged: (val) {
                    setState(() {
                      _product.region = val;
                    });
                  },
                  onSaved: (val) {
                    _product.region = val;
                  },
                  decoration: InputDecoration(
                    labelText: Languages.of(context).regions,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                DropdownButtonFormField(
                  validator: (e) =>
                      e == null ? Languages.of(context).required : null,
                  items: _furnishs
                      .map((e) => DropdownMenuItem(
                            child: Text(
                                Languages.of(context).labelSelectLanguage ==
                                        "English"
                                    ? e.name
                                    : e.name_ar),
                            value: e.name,
                          ))
                      .toList(),
                  value: _product.furnish,
                  isExpanded: true,
                  onChanged: (val) {
                    setState(() {
                      _product.furnish = val;
                    });
                  },
                  onSaved: (txt) {
                    _product.furnish = txt;
                  },
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adFurnishing,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                DropdownButtonFormField(
                  validator: (e) =>
                      e == null ? Languages.of(context).required : null,
                  items: [
                    DropdownMenuItem(
                      child: Text(Languages.of(context).adWithSwimming),
                      value: true,
                    ),
                    DropdownMenuItem(
                      child: Text(Languages.of(context).adWithoutSwimming),
                      value: false,
                    ),
                  ],
                  value: _swimmingPool,
                  onSaved: (val) {
                    _product.swimmingPool = val;
                  },
                  isExpanded: true,
                  onChanged: (val) {
                    setState(() {
                      _swimmingPool = val;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adSwimming,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onSaved: (txt) {
                    _product.rooms = int.parse(txt);
                  },
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: _roomsController,
                  validator: (e) =>
                      int.tryParse(e) != null && int.tryParse(e) > 0
                          ? null
                          : Languages.of(context).required,
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adRoomNumber,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: _bathroomsController,
                  validator: (e) => int.tryParse(e) != null
                      ? null
                      : Languages.of(context).required,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onSaved: (txt) {
                    _product.bathrooms = int.parse(txt);
                  },
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adBathRoomNumber,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  controller: _sizeController,
                  validator: (e) =>
                      double.tryParse(e) != null && double.tryParse(e) > 0
                          ? null
                          : Languages.of(context).required,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onSaved: (txt) {
                    _product.landSize = txt;
                  },
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adSpace,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  controller: _priceController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onSaved: (txt) {
                    _product.price = double.tryParse(txt) ?? .0;
                  },
                  validator: RequiredValidator(
                      errorText: Languages.of(context).required),
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adPrice,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: !_isLoadingLocation
                      ? AbsorbPointer(
                          child: GoogleMap(
                            onMapCreated: (GoogleMapController controller) {
                              _mapController.complete(controller);
                            },
                            initialCameraPosition: _cameraPosition,
                            markers: Set<Marker>.of(markers.values),
                            zoomControlsEnabled: false,
                            // hide location button
                            myLocationButtonEnabled: false,
                            mapType: MapType.normal,
                          ),
                        )
                      : Container(),
                ),
                SizedBox(
                  height: 35.h,
                ),
                Center(
                  child: MaterialButton(
                    minWidth: 130,
                    onPressed: _isRequesting
                        ? null
                        : () async {
                            final coordinates = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationPicker(),
                              ),
                            );
                            setState(() {
                              _position = coordinates;
                              _selectedPosition = coordinates;
                              initMarker(_position.lat, _position.lng);
                            });
                          },
                    child: Text(
                      Languages.of(context).adOnLocation,
                      style: GoogleFonts.cairo(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    color: const Color(0XFF4d4d4d),
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.white,
                  ),
                ),
                if (_showLocationError)
                  Center(
                    child: Text(
                      Languages.of(context).adOnLocationValidation,
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                  ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _addressController,
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: Languages.of(context).required),
                    MinLengthValidator(3,
                        errorText: Languages.of(context).required),
                  ]),
                  onSaved: (txt) {
                    _product.adress = txt;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adAddress,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  minLines: 2,
                  maxLines: 2,
                  controller: _descController,
                  onSaved: (txt) {
                    _product.description = txt;
                  },
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: Languages.of(context).required),
                    MinLengthValidator(5,
                        errorText: Languages.of(context).required),
                  ]),
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adDescription,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 35.h,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  minLines: 2,
                  maxLines: 2,
                  controller: _descControllerArabic,
                  onSaved: (txt) {
                    _product.descriptionAr = txt;
                  },
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: Languages.of(context).required),
                    MinLengthValidator(5,
                        errorText: Languages.of(context).required),
                  ]),
                  decoration: InputDecoration(
                    labelText: Languages.of(context).adDescriptionarabic,
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    focusedErrorBorder: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(),
                  ),
                ),

                SizedBox(
                  height: 30.h,
                ),
                ListTile(
                  title: Text(Languages.of(context).rent),
                  onTap: () => setState(() {
                    _product.forRent = true;
                  }),
                  leading: Radio(
                    value: true,
                    groupValue: _product.forRent,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        _product.forRent = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(Languages.of(context).sale),
                  onTap: () => setState(() {
                    _product.forRent = false;
                  }),
                  leading: Radio(
                    value: false,
                    groupValue: _product.forRent,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        _product.forRent = value;
                      });
                    },
                  ),
                ),

                if (_showTypeError)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      Languages.of(context).required,
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                  ),

                SizedBox(
                  height: 30.h,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: MaterialButton(
                    onPressed: _isRequesting ? null : _postRealState,
                    child: Text(
                      widget.product == null
                          ? Languages.of(context).adAction
                          : Languages.of(context).updateNow,
                      style: GoogleFonts.cairo(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                    color: Colors.black,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.white,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                  ),
                ),
                SizedBox(
                  height: .1.sh,
                )
              ],
            ));
  }

  Future<void> _postRealState() async {
    setState(() {
      _showPhotoError = _photos.isEmpty;
      _showLocationError = _selectedPosition == null;
      _showTypeError = _product.forRent == null;
    });
    if (_formKey.currentState.validate() &&
        _photos.isNotEmpty &&
        _selectedPosition != null &&
        _product.forRent != null) {
      _formKey.currentState.save();
      setState(() {
        _isRequesting = true;
      });

      _product.position = _selectedPosition;
      try {
        _product.photos.forEach((element) {
          print('photooo iss: ${element}');
        });
        if (widget.product == null)
          await ProductsWebService().addRealEstate(_product);
        else
          await ProductsWebService()
              .updateRealEstate(_product, _photosToRemove);

        _showDialog(
            text: Languages.of(context).demandereceive,
            onTap: () {
              if (widget.product == null)
                Res.PAGE_SELECTOR_STREAM.add(0);
              else
                Navigator.pop(context, true);
            });
      } on DioError catch (e) {
        _showDialog();
        print('errorrrrr isssss:    ${e.response.data}');
      } finally {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  Widget _loadingWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoActivityIndicator(
          radius: 20.sp,
        ),
        SizedBox(width: 20.w),
        Text(
          Languages.of(context).loader,
          style: GoogleFonts.cairo(
              color: Colors.grey, fontSize: 30.sp, fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  void _showDialog({String text, Function onTap}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Text(
                  text ?? Languages.of(context).chekconnection,
                  style: GoogleFonts.cairo(),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onTap != null) onTap();
                    },
                    child: Text(
                      Languages.of(context).agreeon,
                      style: GoogleFonts.cairo(color: Colors.teal),
                    ))
              ],
            ));
  }

  Future<void> _getMedium() async {
    final medium = await MediaPicker.getMedia(context);
    if (medium != null) {
      setState(() {
        _photos.add(medium);
      });
      final path = await medium.file.path;
      _product.photos.add(path);
    }
  }

  Future<void> _getUpdateData() async {
    _photos = (await ProductsWebService()
        .getUpdateRealEstate(widget.product.id))['images'];
    setState(() {});
  }
}
