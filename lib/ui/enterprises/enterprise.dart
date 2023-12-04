import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/onBoardingScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../tools/webservices/products.dart';
import '../common/card_service.dart';
import '../product/product_screen.dart';
import '../profileInfo.dart';

class EnterpriseScreen extends StatefulWidget {
  EnterpriseScreen({Key key, this.enterprise}) : super(key: key);

  //final PersonModel profile;
  final EnterpriseModel enterprise;

  @override
  _EnterpriseScreenState createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen>
    with RouteAware, RouteObserverMixin {
  List<ProductModel> _products = [];
  List<ServiceModel> _services = [];
  List<EnterpriseModel> singleentreprise=[];
  EnterpriseModel _entreprise;
  bool isLoading;
  bool _seeAllDesc = false;
  PersonModel _profile;
  EnterpriseModel company;


  //bool _requestingFollowing = false;
  String _phone;
  String photoProfile;
  Locale currentLang;
  int _currentIndex = 0;
  bool details = false;
  String share_link = "";
  double long = 49.5;
  double lat = -0.09;
  var location = [];
  bool _isFetching = false;
  int forRent = 0;
  int forSale = 0;
  int forCommercial = 0;
  int forServices = 0;
  int listing_length = 0;

  bool followed = false;
  String address1;
  String address2;
  String address3;
  int _selectedImageIndex = 0;

  List<String> _images = [    'https://picsum.photos/250?image=9',
    'https://picsum.photos/250?image=15',    'https://picsum.photos/250?image=25',
    'https://picsum.photos/250?image=30',  ];

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 30.4746,
  );

  @override
  void initState() {
    super.initState();
    ProductsWebService().getentreprisesingle(0,id:widget.enterprise.id).then((entrs) {
      setState(() {

        singleentreprise = entrs;
        _isFetching = false;
        print(singleentreprise);
      });
    });
 /*   if (widget.enterprise.isFollowing == true) {
      setState(() {
        followed = true;
      });
    }
    if (widget.enterprise != null) {
      company = EnterpriseModel.fromJson(widget.enterprise.toJson());
    } else {
      company = Res.USER.enterprise;
    }*/




    isLoading = true;
    getCurrentLang();

    super.initState();
    if (_profile != null) {
      _phone = _profile.phone?.replaceAll(' ', '') ?? '';
      _phone.replaceAll('+', '');
      if (_phone.startsWith('00')) _phone = _phone.replaceFirst('00', '');
    }


  }



  getCurrentLang() async {
    getLocale().then((locale) {
      setState(() {
        currentLang = locale;
      });
    });
  }

  void openMaps(LatLng ltn) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${ltn.latitude},${ltn.longitude}';
    if (await canLaunch(googleUrl) == null) {
      throw 'Could not open the map.';
    } else {
      await launch(googleUrl);
    }
  }

  logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    setState(() {
      Res.USER = null;
    });
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





  Widget buttonIcon() {
    return Icon(
      Icons.chevron_right,
      color: Colors.grey,
      size: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.00),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Languages.of(context).agencydetails,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22.0.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: !_isFetching?Container(
        color: Color(0XFFeeeeee),
        child: NestedScrollView(
            headerSliverBuilder: (context, scrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Color(0XFFeeeeee),
                  expandedHeight: .55.sh,
                  //collapsedHeight: kToolbarHeight,
                  automaticallyImplyLeading: false,
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    double scale = 1.0;
                    if (constraints.biggest.height <= 290)
                      scale = (constraints.biggest.height - 56) / (290 - 56.0);
                    return Stack(
                      children: [
                        FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Padding(
                            padding: EdgeInsets.only(
                                right: 4, left: 4, bottom: .26.sh),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                child: CachedNetworkImage(
                                  imageUrl: 'https://bunyan.qa/images/agencies/' +
                                          widget.enterprise?.image ??
                                      '',
                                  progressIndicatorBuilder: (_, __, ___) {
                                    return _shimmer(
                                        width: 600.w, height: 400.w);
                                  },
                                  errorWidget: (_, __, ___) => Container(
                                    width: 600.w,
                                    height: 400.w,
                                    child: Icon(Icons.broken_image_outlined),
                                    color: Colors.white,
                                  ),
                                  width: 600.w,
                                  height: 400.w,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedOpacity(
                            opacity: scale,
                            duration: Duration(seconds: 0),
                            child: Transform.scale(
                              scale: scale,
                              origin: Offset(.0, .2.sh),
                              child: Card(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                        height: .35.sh,
                                        width: .85.sw,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 25.h, horizontal: 30.w),
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            SizedBox(height: 40),
                                            Text(
                                              widget.enterprise.name,
                                              style: GoogleFonts.cairo(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 28.sp),
                                              textAlign: TextAlign.center,
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.email,size: 30.sp,),
                                                SizedBox(width: 10.w,),
                                                Text(
                                                  widget.enterprise.email,
                                                  style: GoogleFonts.cairo(
                                                      fontSize: 20.sp),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.phone,size: 30.sp,),
                                                SizedBox(width: 10.w,),

                                                Text(
                                                  widget.enterprise.phone.toString(),
                                                  style: GoogleFonts.cairo(
                                                      fontSize: 20.sp),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            widget.enterprise.address == null?Row():Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.place,size: 30.sp,),
                                                SizedBox(width: 10.w,),
                                                Flexible(
                                                  child: Text(
                                                    widget.enterprise.address ?? '',
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 20.sp),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ],
                                        )),

                                    Positioned(
                                        top: -70,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                    0.5 -
                                                .075.sw -
                                                60,
                                        child: GestureDetector(
                                          onTap: () {

                                          },
                                          child: ProfileInfo(
                                              'https://bunyan.qa/images/agencies/'+ widget.enterprise.image,false),
                                        )),
                                    Positioned(
                                      top: -20,
                                      right: currentLang.toString() == 'en'
                                          ? 0
                                          : .85.sw - 40,
                                      child: (widget.enterprise == null &&
                                              _profile == Res.USER)
                                          ? GestureDetector(
                                              child: Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                40))),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  }),
                )
              ];
            },
            body: Scaffold(
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
                          //print(index);
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
              floatingActionButton:
                  MediaQuery.of(context).viewInsets.bottom == 0
                      ? FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.black,
                          child: Icon(FontAwesome.plus),
                          onPressed: () => setState(() {}),
                        )
                      : Container(),
              body: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        details == false
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      details = true;
                                    });
                                  },
                                  child: Text(
                                    Languages.of(context).agencydetails + " >>",
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp),
                                  ),
                                ),
                              )
                            : Container(),
                        details == true
                            ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _moreDescCard(),
                            )
                            : Container(),
                        details == true && widget.enterprise.lng != 0
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(25, 10, 25, 0),
                                child: Card(
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [

                                        Expanded(
                                          child: Container(
                                            height: 150,
                                            width: 150,
                                            child: GoogleMap(
                                              mapType: MapType.hybrid,
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: LatLng(
                                                    widget.enterprise.lat??0,
                                                    widget.enterprise.lng??0),
                                                zoom: 14.4746,
                                              ),
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                _controller
                                                    .complete(controller);
                                              },
                                              onTap: openMaps,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        details == true
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(25, 10, 25, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          launch(
                                              'mailto:${widget.enterprise.email}');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              2, 7, 2, 7),
                                          child: Text(
                                            Languages.of(context).email,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        color: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          launch(
                                              'tel:${widget.enterprise.phone}');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              2, 7, 2, 7),
                                          child: Text(
                                            Languages.of(context)
                                                .productDetailsCallPhone,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        color: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          launch(
                                              'https://wa.me/${widget.enterprise.phone}');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              2, 7, 2, 7),
                                          child: Text(
                                            Languages.of(context)
                                                .productDetailsCallWhats,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        color: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),




                        Padding(
                padding: EdgeInsets.only(bottom: 50.h, left: 20.h, right: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Service And Products',
                      style: GoogleFonts.cairo(
                          color: Color(0xFF750606), fontSize: 30.sp,
                          fontWeight: FontWeight.bold),
                    ),



                    _isFetching?Center(child: CircularProgressIndicator(),):
                    widget.enterprise.products.isEmpty?Center(
                      child: Text('Sorry, We Couldnt Find Any Result.'),
                    )
                    :StaggeredGridView.countBuilder(
                        itemCount: singleentreprise.length,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 1,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _isFetching
                              ? _shimmerItem(index)
                              : Card(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),

                          ),
                                elevation: 5,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {

                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topRight:Radius.circular(10)),
                                        ),
                                        child: Image.network(
                                          "https://bunyan.qa/images/agencies/"+singleentreprise[index].products[index].images[_selectedImageIndex].image,
                                          width: double.infinity,
                                          height: 250.h,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          for (int i = 0; i < singleentreprise[index].products[index].images.length; i++)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedImageIndex = i;
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(horizontal: 8),
                                                width: 120.w,
                                                height: 90.h,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: _selectedImageIndex == i
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: NetworkImage("https://bunyan.qa/images/agencies/"+singleentreprise[index].products[index].images[i].image),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      singleentreprise[index].products[index].title??'',
                                      style: GoogleFonts.cairo(
                                          color: Color(0xFF750606), fontSize: 30.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'QAR ' + singleentreprise[index].products[index].priceStartFrom.toString(),
                                      style: GoogleFonts.cairo(
                                          color: Color(0xFF750606), fontSize: 30.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              );
                        }),
                  ],
                ),
              )






                      ],
                    ),
                  )),
            )),
      ):Center(
        child: _loadingWidget(),
      ),
    );
  }



  _shimmerItem(index) {
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



  Widget _moreDescCard() {
    final desc = Languages.of(context).labelSelectLanguage == "English"
        ? widget.enterprise.description
        : widget.enterprise.descriptionAr;

    return widget.enterprise.description == null
        ? Center()
        : Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                Languages.of(context).productDetailsDescrption,
                style: GoogleFonts.cairo(
                    fontSize: 35.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: Html(
                  data: desc.substring(0,
                      _seeAllDesc ? desc.length : min(desc.length, 200)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _seeAllDesc = !_seeAllDesc;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  _seeAllDesc
                      ? Languages.of(context).showLess
                      : Languages.of(context).showMore,
                  style: GoogleFonts.cairo(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }





}
class ProductItem extends StatelessWidget {
  final Products product;

  ProductItem({ this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            product.description ?? '',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 8.0),
          // Display images list
          SizedBox(
            height: 150.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              itemBuilder: (BuildContext context, int index) {
                final image = product.images[index];

                return Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: Image.network(
                    image.image,
                    fit: BoxFit.cover,
                    width: 150.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}