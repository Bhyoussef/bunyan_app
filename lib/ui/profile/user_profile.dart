import 'dart:io';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/advertises.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/auth/signup/signup_entreprise.dart';
import 'package:bunyan/ui/common/card_item.dart';
import 'package:bunyan/ui/common/list_card_item.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/onBoardingScreen.dart';
import 'package:bunyan/ui/product/product_screen.dart';
import 'package:bunyan/ui/profile/user_ads.dart';
import 'package:bunyan/ui/services/service_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import '../../column/Columnbuilder.dart';
import '../../models/pakage.dart';
import '../../models/product.dart';
import '../../tools/webservices/products.dart';
import '../common/card_item_ser.dart';
import '../main/main_screen.dart';
import '../profileInfo.dart';
import '../redirect_to_auth.dart';
import 'business_llist_screen.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen(
      {Key key, this.profile, this.enterprise, this.isMine = true})
      : super(key: key);

  final bool isMine;

  final PersonModel profile;
  final EnterpriseModel enterprise;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with RouteAware, RouteObserverMixin {
  List<ProductModel> _products = [];
  List<ProductListModel> _productsfiniched = [];
  List<ProductListModel> _productspromoted = [];
  List<ProductListModel> _productsinreview = [];
  List<ServiceModel> _servicesfiniched = [];
  List<ServiceModel> _servicespromoted = [];
  List<ServiceModel> _servicesinreview = [];
  List<ServiceModel> _services = [];
  List<ProductListModel> _items = [];
  List<ServiceModel> _itemsservice = [];
  PersonModel _profile;
  String _phone;
  String photoProfile;
  Locale currentLang;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _profile = PersonModel.fromJson(widget.profile.toJson());
    } else if (Provider.of<SelectedProfileProvider>(context, listen: false)
            .profile !=
        null) {
      _profile =
          Provider.of<SelectedProfileProvider>(context, listen: false).profile;
    } else {
      _profile = Res.USER;
    }
    if (_profile != null) {
      _phone = _profile.phone?.replaceAll(' ', '') ?? '';
      _phone.replaceAll('+', '');
      if (_phone.startsWith('00')) _phone = _phone.replaceFirst('00', '');

      /*UsersWebService().getUserProfile(_profile.id).then((response) {
        setState(() {
          final oldProfile = PersonModel.fromJson(_profile.toJson());
          _profile = response['user'];
          photoProfile = _profile.photo;


          if (oldProfile == Res.USER) {
            Res.USER = _profile;
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('user', jsonEncode(Res.USER.toJson()));
            });
          }
          _isLoading = false;
        });
      });*/
    }

    _getData();
  }

  logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    setState(() {
      Res.USER = null;
      Res.token = null;
    });
    await UsersWebService().logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OnBoardingScreen()));
  }

  @override
  void didPopNext() {
    Res.titleStream.add('الملف الشخصي');
    super.didPopNext();
  }

  @override
  void didPush() {
    super.didPush();
    Res.titleStream.add('الملف الشخصي');
  }

  File personalPhoto;

  _getFromGallery() async {
    PermissionStatus permission;
    if (Platform.isIOS)
      permission = await Permission.photos.status;
    else
      permission = await Permission.storage.status;

    if (permission.isDenied || permission.isRestricted) {
      if (Platform.isIOS)
        await Permission.photos.request();
      else {
        final p = await Permission.storage.request();
        if (p.isDenied) openAppSettings();
      }
      return;
    }
    if (await permission.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
      return;
    }
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      personalPhoto = File(pickedFile.path);
      _uploadPhotoProfile(personalPhoto);
      pickedFile = null;
    });
  }

  _getFromCamera() async {
    final permission = await Permission.camera.status;
    print('permission isss  $permission');

    if (permission.isDenied || permission.isRestricted) {
      final p = await Permission.camera.request();
      print('second permission     ${p}');
      if (Platform.isAndroid && p.isDenied) openAppSettings();
      return null;
    }

    if (await permission.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
      return;
    }
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      personalPhoto = File(pickedFile.path);
      pickedFile = null;
    });
    _uploadPhotoProfile(personalPhoto);
  }

  _uploadPhotoProfile(File photo) async {
    setState(() {});
    UsersWebService()
        .updatePhotoProfile(idsession: _profile.id, profilePhoto: photo)
        .then((data) {
      setState(() {
        photoProfile = data['photo_url'];
        print('photoProfile $photoProfile');
        if (data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              padding: EdgeInsets.all(0),
              content: Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text(
                        Languages.of(context).editPhotoProfileSuccess,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  )),
            ),
          );
          setState(() {
            initState();
          });
        }
      });
    }).onError((error, stackTrace) {
      setState(() {});
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
        ),
        builder: (BuildContext bc) {
          Size size = MediaQuery.of(context).size;
          return SafeArea(
            child: Container(
              height: 140,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _getFromGallery();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: size.width * 0.4,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            Languages.of(context).modalBottomSheetPhotoLibrary,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _getFromCamera();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: size.width * 0.4,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            Languages.of(context).modalBottomSheetCamera,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buttonIcon() {
    return Icon(
      Icons.chevron_right,
      color: Colors.grey,
      size: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<SelectedProfileProvider>(context, listen: false)
            .setProfile(null);
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Show Snackbar',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationsScreen()));
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.language_outlined),
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
            leading: InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                  height: 45,
                  width: 45,
                  /* decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1.5,
                          blurRadius: 1.5,
                        ),
                      ],
                    ),*/
                  child: Icon(
                    Icons.menu_outlined,
                    color: Colors.black,
                    size: 25,
                  )),
            ),
            title: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MainScreen()));
              },
              child: Image.asset(
                'assets/logo.min.png',
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            centerTitle: true,
          ),
          body: Res.USER != null
              ? Container(
                  color: Color(0XFFeeeeee),
                  child: NestedScrollView(
                      headerSliverBuilder: (context, scrolled) {
                        return [
                          SliverAppBar(
                            backgroundColor: Colors.white,
                            expandedHeight: .45.sh,
                            //collapsedHeight: kToolbarHeight,
                            automaticallyImplyLeading: false,
                            flexibleSpace:
                                LayoutBuilder(builder: (context, constraints) {
                              double scale = 1.0;
                              if (constraints.biggest.height <= 300)
                                scale = (constraints.biggest.height - 60) /
                                    (300 - 60.0);
                              print(scale);
                              final opacity = scale * 1.3;
                              return Stack(
                                children: [
                                  FlexibleSpaceBar(
                                    collapseMode: CollapseMode.parallax,
                                    background: Padding(
                                      padding: EdgeInsets.only(
                                          right: 4, left: 4, bottom: .1.sh),
                                      child: ClipRRect(
                                          child: Hero(
                                        tag: _profile.photo,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              'https://bunyan.qa/images/users/${_profile.photo}',
                                          progressIndicatorBuilder:
                                              (_, __, ___) => _shimmer(
                                                  width: 1.sw, height: 1.sw),
                                          errorWidget: (_, __, ___) => Image(
                                            image: AssetImage(
                                                'assets/Image 280.jpg'),
                                            fit: BoxFit.cover,
                                          ),
                                          width: 1.sw,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 0.h),
                                      child: AnimatedOpacity(
                                        opacity: opacity < .0
                                            ? .0
                                            : opacity > 1.0
                                                ? 1.0
                                                : opacity,
                                        duration: Duration(seconds: 0),
                                        child: Transform.scale(
                                          scale: scale < .0 ? .0 : scale,
                                          origin: Offset(.0, .2.sh),
                                          child: Card(
                                            elevation: 3.0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                    //height: .21.sh,
                                                    width: .85.sw,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    padding: EdgeInsets.only(
                                                        top: 25.h,
                                                        left: 30.w,
                                                        right: 30.w,
                                                        bottom: 15.h),
                                                    child: ListView(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      children: [
                                                        SizedBox(height: 60),
                                                        Text(
                                                          _profile.name,
                                                          style:
                                                              GoogleFonts.cairo(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize:
                                                                      35.sp),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        if (widget.isMine)
                                                          Divider(
                                                            color: Colors.black,
                                                            thickness: .5,
                                                          ),
                                                        if (widget.isMine)
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          SignupScreenEntreprise(
                                                                            isCompany:
                                                                                Res.USER.isCompany,
                                                                          )));
                                                            },
                                                            style: ButtonStyle(
                                                                padding: MaterialStateProperty.all<
                                                                        EdgeInsets>(
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10.0))),
                                                            child: Text(
                                                              Languages.of(
                                                                      context)
                                                                  .editprofile,
                                                              style: GoogleFonts.cairo(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                          )
                                                      ],
                                                    )),
                                                Positioned(
                                                    top: -70,
                                                    left: MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5 -
                                                        .075.sw -
                                                        60,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (widget.isMine)
                                                          _showPicker(context);
                                                      },
                                                      child: ProfileInfo(
                                                          'https://bunyan.qa/images/users/${_profile.photo}',
                                                          widget.isMine),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ];
                      },
                      body: Scaffold(
                        body: SingleChildScrollView(
                          child: Column(
                            children: [
                              _productsCard(),
                              if (widget.isMine) ...[
                                SizedBox(
                                  height: 25,
                                ),
                                /*Align(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AboutScreen(aboutsus:'about',)));
                                    },
                                    child: Card(
                                      elevation: 3.0,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0)),
                                      child: Container(
                                          width: .85.sw,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(20.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.h, horizontal: 30.w),
                                          child: Text(
                                            Languages.of(context).about,
                                            style: GoogleFonts.cairo(
                                                fontSize: 27.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ),
                                ),*/
                                Align(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Are you sure you want to log out?'),
                                            actions: <Widget>[
                                              // Cancel button
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                              ),
                                              // Confirm button
                                              TextButton(
                                                child: Text('Confirm'),
                                                onPressed: () {
                                                  logOut();
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Card(
                                      elevation: 3.0,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Container(
                                          width: .85.sw,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.h, horizontal: 30.w),
                                          child: Text(
                                            Languages.of(context).logout,
                                            style: GoogleFonts.cairo(
                                                fontSize: 27.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                              if (!_isFetching &&
                                  _items.isEmpty &&
                                  _itemsservice.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: .03.sh),
                                  child: Text(
                                    Languages.of(context).noAds,
                                    style: GoogleFonts.cairo(
                                        fontSize: 27.sp,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: !widget.isMine
                                      ? _items.isEmpty
                                          ? _serviceGridView()
                                          : _propertiesGridView()
                                      : SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              //_listView(),
                                              //_listViewService()
                                            ],
                                          ),
                                        )),
                            ],
                          ),
                        ),
                      )),
                )
              : RedirectToAuth(
                  destination: 'home',
                )),
    );
  }

  Widget _shimmerItem(index) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color(0xFFf3f3f3),
                  highlightColor: const Color(0xFFE8E8E8),
                  child: Container(
                    height: index.isOdd ? 380.h : 280.h,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  top: .0,
                  left: .0,
                  child: Shimmer.fromColors(
                    baseColor: Color(0xffbfbdbd),
                    highlightColor: const Color(0xFFE8E8E8),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.8),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0))),
                      width: .25.sw,
                      height: 30.h,
                      padding:
                          EdgeInsets.symmetric(vertical: 5.w, horizontal: 25.w),
                    ),
                  ),
                ),
                Positioned.fill(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: Container(
                    width: 1.sw,
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: 20.w, bottom: 20.h, left: 15.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Shimmer.fromColors(
                                  baseColor: Color(0xffbfbdbd),
                                  highlightColor: const Color(0xFFE8E8E8),
                                  child: Container(
                                    width: .1.sw,
                                    height: 20.h,
                                    color: Colors.grey.withOpacity(.8),
                                  ),
                                )),
                          ),
                          Icon(
                            Icons.location_pin,
                            color: Colors.white,
                            size: 22.w,
                          ),
                          Shimmer.fromColors(
                            baseColor: Color(0xffbfbdbd),
                            highlightColor: const Color(0xFFE8E8E8),
                            child: Container(
                              width: .08.sw,
                              height: 10.h,
                              color: Colors.grey.withOpacity(.8),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({double width, double height}) {
    return Shimmer.fromColors(
        child: Container(
          width: width,
          height: height,
          color: Colors.grey,
        ),
        baseColor: Colors.grey.withOpacity(.5),
        highlightColor: Colors.white);
  }

  Future<void> _getData() async {
    setState(() {
      _isFetching = true;
      _items.clear();
    });
    final id = _profile.id;
    print('progile id isssssss:     $id');
    final response = await AdvertisesWebService()
        .getUserAds(userId: widget.isMine ? null : id);
    setState(() {
      _isFetching = false;
      _items
        ..clear()
        ..addAll(response['properties']);

      _productsfiniched =
          _items.where((element) => element.status == true).toList();
      _productsinreview =
          _items.where((element) => element.status == false).toList();
      _productspromoted =
          _items.where((element) => element.promoted == true).toList();
      print('youssef ${_productsinreview}');
      _isFetching = false;
      _itemsservice
        ..clear()
        ..addAll(response['services']);
      _servicesfiniched =
          _itemsservice.where((element) => element.status == true).toList();
      _servicesinreview =
          _itemsservice.where((element) => element.status == false).toList();
      _servicesinreview =
          _itemsservice.where((element) => element.status == true).toList();
      if (!widget.isMine) {
        print(_itemsservice);
      }
    });
  }

  _productsCard() {
    int pending = 0;
    int total = _items.length + _itemsservice.length;

    if (widget.isMine) {
      pending += _items.where((element) => !element.status).length +
          _itemsservice.where((element) => !element.status).length;
    }
    return SizedBox(
      width: .85.sw,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          children: [
            _productsCardItem(
                count: total,
                title: Languages.of(context).totalAds,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => User_Ads(
                              product: _items,
                              isMine: widget.isMine,
                              profile: Res.USER,
                              service: _itemsservice)));
                }),
            if (widget.isMine) ...[
              Divider(height: 1.0),
              _productsCardItem(
                  count: pending,
                  title: Languages.of(context).inReviewAds,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => User_Ads(
                                  product: _productsinreview,
                                  isMine: widget.isMine,
                                  profile: Res.USER,
                                  service: _servicesinreview,
                                )));
                  }),
              Divider(
                height: 1.0,
              ),
              _productsCardItem(
                  count: total - pending,
                  title: Languages.of(context).completedAds,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => User_Ads(
                                  product: _productsfiniched,
                                  isMine: widget.isMine,
                                  profile: Res.USER,
                                  service: _servicesfiniched,
                                )));
                  }),
              _productsCardItem(
                  title: 'Ad Posted',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => User_Ads(
                                  product: _productspromoted,
                                  service: _servicespromoted,
                                )));
                  }),
              _productsCardItem(
                  title: 'Ad Balance ',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Busniss_List_Screen()));
                  }),
              _productsCardItem(
                  title: 'Real Estate',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => User_Ads(
                                  product: _items,
                                )));
                  }),
              _productsCardItem(
                  title: 'Service',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                User_Ads(service: _itemsservice)));
                  }),
              /*   _productsCardItem(
                  title: 'Business',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Business_Bakage()));
                  }),*/
              /*  _productsCardItem(
                  title: 'Privacy and Policy',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutScreen(aboutsus: 'privacy',)));
                  }),*/
              _productsCardItem(
                  title: 'My Pakage',
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Pakagepage(

                        )));
                  }),
            ]
          ],
        ),
      ),
    );
  }

  _productsCardItem({String title, int count, VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SvgPicture.asset(
              'assets/ads.svg',
              width: 30.0,
            ),
            Expanded(
                child: Center(
                    child: Text(
              title,
              style: GoogleFonts.cairo(fontSize: 16.0),
            ))),
            ...[
              if (_isFetching)
                SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 2.5,
                    ))
              else
                count == null
                    ? Text('')
                    : Text(
                        count.toString() ?? '',
                        style: GoogleFonts.cairo(),
                      ),
              SizedBox(
                width: 20.w,
              ),
              if (widget.isMine) Icon(Icons.arrow_forward_ios_rounded)
            ]
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _isFetching ? 4 : _productsinreview.length,
      itemBuilder: (context, index) {
        final product = _isFetching ? null : _productsinreview[index];

        return product == null
            ? Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: _shimmer(width: double.infinity, height: 300.0)),
              )
            : ListCardItem(
                product: product,
                onChanged: _getData,
              );
      },
    );
  }

  Widget _listViewService() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _isFetching ? 4 : _itemsservice.length,
      itemBuilder: (context, index) {
        final service = _isFetching ? null : _itemsservice[index];

        return service == null
            ? Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: _shimmer(width: double.infinity, height: 300.0)),
              )
            : ListCardItem(
                product: service,
                onChanged: _getData,
              );
      },
    );
  }

  Widget _propertiesGridView() {
    return StaggeredGridView.countBuilder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: .0,
      crossAxisCount: 2,
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
      itemCount: _isFetching ? 4 : _items.length,
      itemBuilder: (context, index) {
        return _isFetching
            ? _shimmerItem(index)
            : _items.length > 0
                ? InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductScreen(
                                    product: _items[index],
                                  )));
                      Res.titleStream.add(Languages.of(context).realEstate);
                    },
                    child: CardItem(product: _items[index]),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      Languages.of(context).redirectToAuthMessage,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  );
      },
    );
  }

  Widget _serviceGridView() {
    return StaggeredGridView.countBuilder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: .0,
      crossAxisCount: 2,
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
      itemCount: _isFetching ? 4 : _itemsservice.length,
      itemBuilder: (context, index) {
        return _isFetching
            ? _shimmerItem(index)
            : _itemsservice.length > 0
                ? InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ServiceScreen(
                                    service: _itemsservice[index],
                                  )));
                      Res.titleStream.add(Languages.of(context).realEstate);
                    },
                    child: CardItemService(service: _itemsservice[index]),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      Languages.of(context).redirectToAuthMessage,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  );
      },
    );
  }
}

class SelectedProfileProvider extends ChangeNotifier {
  PersonModel profile;

  void setProfile(PersonModel profile) {
    this.profile = profile;
    notifyListeners();
  }
}

class Pakagepage extends StatefulWidget {
  const Pakagepage({Key key}) : super(key: key);

  @override
  State<Pakagepage> createState() => _PakagepageState();
}

class _PakagepageState extends State<Pakagepage> {
  List<Pakage> pakage = [];
  List<Pakage> _premiumpakage = [];
  List<Pakage> _premiumbanner = [];
  List<Pakage> _busniss = [];
  String _selectedPlanType;
  bool _isFetching;
  bool _isLoading = true;

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
/*        _busniss =
            pakage.where((plan) => plan.type == _selectedPlanType).toList();*/
        print(_busniss);
        _isLoading = false;
      });
    });
  }

  void initState() {
    _filterplans();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.00),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Pakage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationsScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.language_outlined),
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
        centerTitle: true,
        //title: Text(widget.product.first.title),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PakageList(pakageList: _premiumpakage),
                    PakageList(pakageList: _premiumbanner),
                    PakageList(pakageList: _busniss),
                  ],
                ),
              ),
            ),
    );
  }
}

class PakageList extends StatelessWidget {
  final List<Pakage> pakageList;

  const PakageList({Key key, this.pakageList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              pakageList[0].type,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
              color: Color(0xFF750606),
            ),
            )],
        ),
        SizedBox(height: 16),
        ColumnBuilder(
          itemCount: pakageList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(pakageList[index].name,style: TextStyle(
                fontWeight: FontWeight.bold
              ),),
              subtitle: Text('QAR '+pakageList[index].price.toString()),
              trailing: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF750606)),
                ),

                child: Text("Pay"),
                onPressed: () {
                  // TODO: Add payment logic here
                },
              ),
            );
          },
        ),
      ],
    );
  }
}


