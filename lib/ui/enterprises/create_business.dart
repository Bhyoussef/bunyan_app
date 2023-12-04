import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../models/enterprise.dart';
import '../../models/position.dart';
import '../../models/product.dart';
import '../../models/region.dart';
import '../../tools/res.dart';
import '../../tools/webservices/addresses.dart';
import '../../tools/webservices/entreprise/entreprise_api.dart';
import '../common/location_picker.dart';
import '../main/main_screen.dart';
import '../notifications/notifications_screen.dart';

class CreateBusiness extends StatefulWidget {
  final String title;

  final String category_id;

  const CreateBusiness({Key key, this.title, this.category_id}) : super(key: key);

  @override
  State<CreateBusiness> createState() => _CreateBusinessState();
}

class _CreateBusinessState extends State<CreateBusiness> {
  RegionModel _region;
  int _currentIndex = 0;
  bool _isFetching = false;
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController name_arabic = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController about = TextEditingController();
  TextEditingController about_arabic = TextEditingController();
  TextEditingController region = TextEditingController();
  TextEditingController region_id = TextEditingController();
  TextEditingController address = TextEditingController();
  bool _isLoadingLocation = false;
  Completer<GoogleMapController> _mapController = Completer();
  LocationData mycurrentLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _cameraPosition;
  PositionModel _position = null;
  bool _isRequesting = false;
  PositionModel _selectedPosition;
  ProductModel _product;
  List<RegionModel> regions = [];

  bool _showLocationError = false;
  File _image;

  final ImagePicker _picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    _isLoadingLocation = true;
    // _selectedPosition = PositionModel(lat: _product.lat, lng: _product.lng);
/*    _product.region = Res.regions
        .where((element) => _product.region.name == element.name)
        .first;
    _region = _product.region;*/
    getCurrentLocation();
    getregion();
    super.initState();
  }

  getregion() {
    AddressesWebService().getRegions().then((rgs) {
      setState(() {
        regions = rgs;
        print('regions is youssef  ${regions.length}');
      });
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        //image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
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

  void _submitForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      print(phone.text);

      // Create an instance of the EnterpriseModel with the form data
      final entreprise = EnterpriseModel(
        name: name.value.text,
        nameAr: name_arabic.value.text,
        email: email.value.text,
        phone: int.parse(phone.value.text),
        description: about.value.text,
        descriptionAr: about_arabic.value.text,
        address: address.value.text, regionName: region.text
      );
      final formData = dio.FormData.fromMap({
        'name': entreprise.name,
        'name_ar': entreprise.nameAr,
        'email': entreprise.email,
        'phone': entreprise.phone,
        'description': entreprise.description,
        'descriptionAr': entreprise.descriptionAr,
        'region': entreprise.regionName,
        'address': entreprise.address,
        'image': await dio.MultipartFile.fromFile(_image.path),
        'category_id':widget.category_id.toString(),
        'region_id':region_id.value
      });

      // Call the REST API function to add the enterprise data to the database

      BusnissApi api = BusnissApi();
      Response response = await api.createPlace(formData);
      print(response);

/*      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enterprise added successfully!')),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add enterprise. Please try again.')),
        );
      }*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              size: 40.sp,
            ),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationsScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.language_outlined,
              size: 40.sp,
            ),
            onSelected: (String result) {
              changeLanguage(context, result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'ar',
                child: Text('العربية',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              PopupMenuItem<String>(
                value: 'en',
                child: Text('English',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 30.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        /*title: _searchWidget(),*/

        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 3.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 65,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: BottomNavigationBar(
                selectedLabelStyle:
                    GoogleFonts.cairo(fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.cairo(),
                currentIndex: _currentIndex,
                backgroundColor: Colors.black,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                onTap: (index) {
                  print(index);
                  setState(() {
                    _currentIndex = index;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainScreen(
                                  menu_index: _currentIndex,
                                )));
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home_outlined,
                    ),
                    activeIcon: Icon(Icons.home),
                    label: Languages.of(context).menuHome,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.favorite_outline,
                    ),
                    activeIcon: Icon(Icons.favorite),
                    label: Languages.of(context).menuFavorite,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      FontAwesome.comments,
                      color: Colors.transparent,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.chat_outlined,
                    ),
                    activeIcon: Icon(Icons.chat),
                    label: Languages.of(context).productDetailsCallChat,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person_outline,
                    ),
                    activeIcon: Icon(Icons.person),
                    label: Languages.of(context).menuProfile,
                  ),
                ]),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black,
              child: Icon(FontAwesome.plus),
              onPressed: () => setState(() {}),
            )
          : Container(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Create A New Business For',
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF750606),
                        fontSize: 25.0.sp,
                        height: 1.2),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF750606),
                    size: 30.sp,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF750606),
                        fontSize: 18.0.sp,
                        height: 1.2),
                  )
                ],
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => getImage(),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              _image != null ? FileImage(_image) : null,
                          child: _image == null
                              ? Icon(Icons.add_a_photo, size: 50.0)
                              : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          labelText: 'Enter your full name',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: name_arabic,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          labelText: 'Enter your full name in arabic',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name in Arabic';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name_arabic.text = value;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          labelText: 'Enter your email',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email.text = value;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: phone,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          labelText: 'Enter your Mobile number',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Mobile number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          phone.text = value;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          //border: InputBorder.none,
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          //labelText: 'Select your regions',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        hint: Text(
                          Languages.of(context).regions,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            region.text = value;
                            region_id=int.parse(region.text) as TextEditingController;


                            //_key.currentState.reset();
                            // getCities(value);
                          });
                        },
                        onSaved: (value) {
                          //region.text = value;


                        },
                        items: regions.map((RegionModel val) {
                          return DropdownMenuItem(
                            value: val.id,
                            child: Text(
                              Languages.of(context).labelSelectLanguage ==
                                      "English"
                                  ? (val.name).replaceAll('-', '')
                                  : (val.nameAr).replaceAll('-', '') ??
                                      (val.name).replaceAll('-', ''),
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.w300),
                            ),
                          );
                        }).toList(),
                        icon: Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: address,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          labelText: 'Enter your address',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          address.text = value;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: about,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          labelText: 'Tell us about your business',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please tell us about your business';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          about.text = value;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: about_arabic,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.cairo(
                            fontSize: 26.sp,
                          ),
                          labelText: 'Tell us about your business in arabic',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 15.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please tell us about your business in Arabic';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          about_arabic.text = value;
                        },
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: !_isLoadingLocation
                            ? AbsorbPointer(
                                child: GoogleMap(
                                  onMapCreated:
                                      (GoogleMapController controller) {
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
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
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
                      SizedBox(height: 16),
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 50.h,
                        color: Colors.black,
                        onPressed: save,
                        child: Text('Add',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Some Advices Need To Be Followed While Making Profile',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF750606),
                            fontSize: 30.0.sp,
                            height: 1.2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Write your full name of your business in english and arabic properly.\n\nWrite your company valid phone number and email people will contact you through.\n\nUpload your brand logo with good quality image.\n\nBunyan owners, moderators and administration reserve the right to remove any advert at any time without prior warning or subsequent justification.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void save() async {
    try {

      final entreprise = EnterpriseModel(
          name: name.value.text,
          nameAr: name_arabic.value.text,
          email: email.value.text,
          phone: int.parse(phone.value.text),
          description: about.value.text,
          descriptionAr: about_arabic.value.text,
          address: address.value.text, regionName: region.text

      );
      final formData = dio.FormData.fromMap({
        'name': entreprise.name,
        'name_ar': entreprise.nameAr,
        'email': entreprise.email,
        'phone': entreprise.phone,
        'description': entreprise.description,
        'descriptionAr': entreprise.descriptionAr,
        'region': entreprise.regionName,
        'address': entreprise.address,
        'image': await dio.MultipartFile.fromFile(_image.path),
        'category_id':widget.category_id.toString(),
        'region_id':10
      });
      BusnissApi api = BusnissApi();
      Response response = await api.createPlace(formData);

      print(response);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Enterprise added successfully!')),
      );
    } on DioError catch (e) {

      final message =   e.response.data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(message)));

    }
  }
}
