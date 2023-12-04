import 'dart:async';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/position.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/models/service.dart';
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

class ServicePage extends StatefulWidget {
  ServicePage({Key key, this.service}) : super(key: key);
  final ServiceModel service;

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  CategoryModel _category;
  RegionModel _region;
  CityModel _city;
  List<dynamic> _photos = [];
  ServiceModel _service;
  final _formKey = GlobalKey<FormState>();

  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _titleController = TextEditingController();
  final _titleArabicController = TextEditingController();
  final _descArabicController = TextEditingController();
  final _promoted_for=TextEditingController();
  final _descController = TextEditingController();
  PositionModel _position;
  PositionModel _selectedPosition;
  bool _showPhotoError = false;
  bool _showLocationError = false;
  bool _isRequesting = false;
  List<int> _photosToRemove = [];

  bool _isBanner = false;
  bool _isSpecial = false;
  bool _isNormal = false;
  bool _isLoadingLocation = false;
  LocationData mycurrentLocation;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _cameraPosition;
  Completer<GoogleMapController> _mapController = Completer();
  List<Pakage> pakage = [];
  List<Pakage> _busniss = [];
  List<Pakage> _premiumpakage = [];
  List<Pakage> _premiumbanner = [];
  String _selectedPlanType;
  Pakage _selectedPlan;
  bool _isChecked = false;
  bool _showpakage;
  bool _isFetching = false;
  String htmlContent = '';

  @override
  void initState() {
    _filterplans();
    fetchData();
    _selectedPlanType = 'Premium';
    _isLoadingLocation = true;
    getCurrentLocation();
    if (widget.service == null) {
      _service = ServiceModel(photos: []);
    }else {
      _service = widget.service;
      _getUpdateData();
      _titleController.text = _service.title;
      _titleArabicController.text = _service.titleAr;
      _service.region = Res.regions.where((element) =>
      _service.region.name == element.name).first;
      _region = _service.region;
      _priceController.text = _service.price.toString();
      _selectedPosition = PositionModel(lat: _service.lat, lng: _service.lng);
      _addressController.text = _service.address;
      _descController.text = _service.description;
      _descArabicController.text = _service.descriptionAr;
      _promoted_for.text=_service.promoted_for;

    }
    super.initState();
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
  Future<void> fetchData() async {
    final html = await ProductsWebService().getPaymentGatewayUrl();
    setState(() {
      htmlContent = html;
      print(htmlContent);
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

  @override
  Widget build(BuildContext context) {
    return _isRequesting
        ? _loadingWidget()
        :Form(
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
                              _service.promoted_for=_promoted_for.text;
                              print(_service.promoted_for);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                                    width: .15.sh,
                                    height: .15.sh,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0XFF4d4d4d),
                                          width: .8),
                                      borderRadius: BorderRadius.circular(20.0),
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
                                borderRadius: BorderRadius.circular(20.0),
                                child: photo == null
                                    ? Container(
                                  width: .15.sh - 10.0,
                                  height: .15.sh - 10.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                        const Color(0XFF4d4d4d),
                                        width: .8),
                                    borderRadius:
                                    BorderRadius.circular(20.0),
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
                                          left: 10.0, top: 10.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            20.0),
                                        child:
                                        photo is MediaItem
                                            ? Image.memory(
                                          photo.thumb,
                                          fit: BoxFit.cover,
                                          width: .15.sh - 10.0,
                                          height: .15.sh - 10.0,
                                        )
                                            : CachedNetworkImage(
                                          imageUrl: 'https://bunyan.qa/images/posts/${photo['image']}',
                                          fit: BoxFit.cover,
                                          width: .15.sh - 10.0,
                                          height: .15.sh - 10.0,
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
                                      _photosToRemove.add(photo['id']);
                                    setState(() {
                                      try {
                                        if (photo is MediaItem)
                                          _service.photos.removeWhere((p) =>
                                          (photo as MediaItem).file.path == p);
                                      } catch(e) {}
                                      _photos.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                    ),
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(Icons.close, size: 20.0,
                                      color: Colors.white,),
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
              Center(
                child: Text(
                  Languages.of(context).adPhotoValidation,
                  style: TextStyle(color: Colors.red, fontSize: 12.0),
                ),
              ),
            if (_showPhotoError)
              SizedBox(
                height: 35.h,
              ),
            TextFormField(
              keyboardType: TextInputType.text,
              onSaved: (txt) {
                _service.title = txt;
              },
              controller: _titleController,
              validator:
                  RequiredValidator(errorText: Languages.of(context).required),
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
              keyboardType: TextInputType.text,
              onSaved: (txt) {
                _service.titleAr = txt;
              },
              controller: _titleArabicController,
              validator:
                  RequiredValidator(errorText: Languages.of(context).required),
              decoration: InputDecoration(
                labelText: Languages.of(context).title_ar,
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
              items: Res.servicesCategories.map((e) => DropdownMenuItem(
                        child: Text(Languages.of(context).labelSelectLanguage ==
                                "English"
                            ? e.name
                            : e.arabicName),
                        value: e.id,
                      ))
                  .toList(),
              value: _service.categoryId,
              isExpanded: true,
              onChanged: (val) {
                setState(() {
                  _service.categoryId = val;
                });
              },
              onSaved: (val) {
                _service.categoryId = val;
              },
              validator: (e) =>
                  e == null ? Languages.of(context).required : null,
              decoration: InputDecoration(
                labelText: Languages.of(context).adSubcategory,
                enabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(borderSide: BorderSide(width: .4)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(width: .4)),
                focusedErrorBorder:
                    OutlineInputBorder(borderSide: BorderSide(width: .4)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            SizedBox(
              height: 35.h,
            ),
            DropdownButtonFormField(
              validator: (e) =>
                  e == null ? Languages.of(context).emptyValidator : null,
              items: Res.regions
                  .map((e) => DropdownMenuItem(
                        child: Text(Languages.of(context).labelSelectLanguage ==
                                "English"
                            ? e.name
                            : e.nameAr),
                        value: e,
                      ))
                  .toList(),
              value: _service.region,
              isExpanded: true,
              onChanged: (val) {
                setState(() {
                  _service.region = val;
                });
              },
              onSaved: (val) {
                _service.region = val;
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
            TextFormField(
              keyboardType: TextInputType.number,
              controller: _priceController,
              onSaved: (val) {
                _service.price = double.tryParse(val) ?? .0;
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator:
                  RequiredValidator(errorText: Languages.of(context).required),
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
                  ? GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                      initialCameraPosition: _cameraPosition,
                      markers: Set<Marker>.of(markers.values),
                      zoomControlsEnabled: false,
                      // hide location button
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
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
              keyboardType: TextInputType.text,
              controller: _addressController,
              onSaved: (val) {
                _service.address = val;
              },
              validator: MultiValidator([
                RequiredValidator(errorText: Languages.of(context).required),
                MinLengthValidator(5, errorText: Languages.of(context).required)
              ]),
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
              onSaved: (val) {
                _service.description = val;
              },
              controller: _descController,
              validator: MultiValidator([
                RequiredValidator(errorText: Languages.of(context).required),
                MinLengthValidator(5, errorText: Languages.of(context).required)
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
              onSaved: (val) {
                _service.descriptionAr = val;
              },
              controller: _descArabicController,
              validator: MultiValidator([
                RequiredValidator(errorText: Languages.of(context).required),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: MaterialButton(
                onPressed: _isRequesting ? null : _postService,
                child: Text(
                  Languages.of(context).adAction,
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

  void _postService() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _showPhotoError = _photos.isEmpty;
      _showLocationError = _selectedPosition == null;
    });
    if (_formKey.currentState.validate() &&
        _photos.isNotEmpty &&
        _selectedPosition != null) {
      _formKey.currentState.save();
      _service.position = _selectedPosition;
      setState(() {
        _isRequesting = true;
      });

      try {
        if (widget.service == null)
          await ProductsWebService().addService(_service);
        else
          await ProductsWebService().updateService(_service, _photosToRemove);
        _showDialog(
            text: Languages.of(context).addads,
            onTap: () {
              if (widget.service == null)
                Res.PAGE_SELECTOR_STREAM.add(0);
              else
                Navigator.pop(context, true);
            });
      } on DioError catch (e) {
        debugPrint('error issss:   ${e.response.data}');
        print(e.requestOptions.uri);
        _showDialog();
      } finally {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  void _showDialog({String text, Function onTap}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Text(
                  text ?? Languages.of(context).servererror,
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
          Languages
              .of(context)
              .loader,
          style: GoogleFonts.cairo(
              color: Colors.grey, fontSize: 30.sp, fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  Future<void> _getMedium() async {
    final medium = await MediaPicker.getMedia(context);
    if (medium != null) {
      setState(() {
        _photos.add(medium);
      });
      final path = await medium.file.path;
      _service.photos.add(path);
    }
  }


  Future<void> _getUpdateData() async {
    _photos = (await ProductsWebService().getUpdateService(widget.service.id))['images'];
    setState((){});
  }
}
