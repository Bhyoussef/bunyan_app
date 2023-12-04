import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/chat.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/report_ad.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/models/service_filter.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/advertises.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/chat/conversation_screen.dart';
import 'package:bunyan/ui/common/card_item_ser.dart';
import 'package:bunyan/ui/profile/user_profile.dart';
import 'package:bunyan/ui/redirect_to_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/profile/profile_agent.dart';
import 'package:bunyan/ui/profile/profile_enterprise.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' show parse;
import 'package:timeago/timeago.dart' as timeago;

class ServiceScreen extends StatefulWidget {
  ServiceScreen({Key key, this.service, this.slug}) : super(key: key);

  final ServiceModel service;
  final String slug;

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen>
    with RouteAware, RouteObserverMixin {
  ScrollController _scrollController = ScrollController();
  bool _isFavoriting = false;
  bool _isLiking = false;
  bool _isFollowingEnterprise = false;
  bool _isLoadingService = false;
  int _currentIndex = 0;
  String _phone;
  bool _seeAllDesc = false;
  ServiceModel _service;
  bool favorite = false;
  bool isLiked = false;
  bool isreported = false;
  bool _isFetching = true;
  List<ServiceModel> _services = [];

  String address1;
  String address2;
  String address3;
  Completer<GoogleMapController> _controller = Completer();


  @override
  void initState() {
    _service = widget.service;
    if (_service == null)
      _isLoadingService = true;
    Res.titleStream.add('خدمات');



    super.initState();

    _initData();
  }

  _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse)
      Res.bottomNavBarAnimStream.add(false);
    else
      Res.bottomNavBarAnimStream.add(true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void didPopNext() {
    Res.titleStream.add(Languages.of(context).services);
    super.didPopNext();
  }

  @override
  void add_view(int id) async {
    await ProductsWebService().Add_view(id: id, type: 2).then((value) {
      setState(() {
        if (value['success'] == true) {
          _service.views = value['views'];
        }
      });
    });
  }

  void openMaps(LatLng ltn) async {
    final lat = _service.lat != null && _service.lat != .0
        ? _service.lat
        : 25.287215;
    final lng = _service.lng != null && _service.lng != .0
        ? _service.lng
        : 51.535910;
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${lat},${lng}';
    if (await canLaunch(googleUrl) == null) {
      throw 'Could not open the map.';
    } else {
      await launch(googleUrl);
    }
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 25.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Languages.of(context).services,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22.0.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: _isLoadingService
          ? Center(child: CircularProgressIndicator(),)
          : Container(
              width: 1.sw,
              child: SingleChildScrollView(
                primary: false,
                controller: _scrollController,
                //padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(children: [
                  _slider(),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
                    child: _headerTitle(),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
                    child: _contentCard(),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
                    child: Card(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 150,
                                child: Text(
                                  Languages.of(context).adLocation,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.sp),
                                ),
                              ),
                            ),

                            Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: GoogleMap(
                                    mapType: MapType.terrain,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                          _service.position?.lat ?? 25.287215,
                                          _service.position?.lng ?? 51.535910),
                                      zoom: 14.4746,
                                    ),
                                      markers: _service.lat != null &&
                                          _service.lat != .0
                                          ? {
                                        Marker(
                                          position: LatLng(_service.lat,
                                              _service.lng),
                                          markerId: const MarkerId('pos'),
                                        )
                                      }
                                          : (<Marker>{}),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      _controller.complete(controller);
                                    },
                                    onTap: openMaps,
                                  ),
                                ),

                            SizedBox(height: 13.h,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Card(
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Container(
                              child: CachedNetworkImage(
                                imageUrl:
                                'https://bunyan.qa/images/users/${_service.ownerImage}',
                                errorWidget: (_, __, ___) =>
                                    Image.asset('assets/icons/avatar.png'),
                                progressIndicatorBuilder: (_, __, ___) =>
                                    _shimmer(width: 100.0, height: 100.0),
                                height: 200.0,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15.0,
                          right: Languages.of(context).labelSelectLanguage ==
                              "English"
                              ? 20.0
                              : .59.sw,
                          child: InkWell(
                            onTap: () {
                              final profile = PersonModel(
                                  id: _service.ownerId,
                                  phone: _service.ownerPhone,
                                  email: _service.ownerEmail,
                                  name: _service.ownerName,
                                  photo: _service.ownerImage);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(isMine: false, profile: profile,)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 8.0),
                              child: Text(
                                Languages.of(context).gotoprofile,
                                style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: .0,
                          left: .0,
                          right: .0,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(3.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9999999),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    'https://bunyan.qa/images/users/${_service.ownerImage}',
                                    progressIndicatorBuilder: (_, __, ___) =>
                                        _shimmer(width: 100.0, height: 100.0),
                                    errorWidget: (_, __, ___) =>
                                        Image.asset('assets/icons/avatar.png'),
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 30.w, right: 30.w, bottom: 50.h, top: 30.h),
                    // child:
                    // _userCard(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _contactBtn(
                              text:
                                  Languages.of(context).productDetailsCallWhats,
                              icon: FontAwesome.whatsapp,
                              onTap: () {
                                launch('https://wa.me/${_service.phone}}');
                              },
                              color: Colors.green),
                        ),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Expanded(
                          child: _contactBtn(
                              text:
                                  Languages.of(context).productDetailsCallPhone,
                              icon: FontAwesome.phone,
                              onTap: () {
                                launch('tel:${_service.phone}');
                              },
                              color: Colors.blue),
                        ),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Expanded(
                          child: _contactBtn(
                              text:
                                  Languages.of(context).productDetailsCallChat,
                              icon: FontAwesome.comments,
                              onTap: true ? null : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ConversationScreen(
                                              chat: ChatModel(
                                                receiver: _service.owner,
                                                sender: Res.USER,
                                              ),
                                              senderName:
                                                  _service.owner.name,
                                            )));
                              },
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  _moreAds()
                ]),
              ))),
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
    );
  }

  Widget _headerTitle() {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: 10.h, left: 25.w, right: 25.w),
      width: 1.sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _textIcon(
                icon: Icons.date_range,
                text: timeago.format(_service.createdAt,
                    locale: Languages.of(context).labelSelectLanguage ==
                        'English' ? 'en' : 'ar'),
              ),

              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(child: Icon(Icons.remove_red_eye_sharp)),
                    TextSpan(text: '  ${_service.views}'),
                  ],
                ),
                style: TextStyle(fontSize: 15.sp),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: Languages.of(context).reference,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '${_service.reference_id}'),
                  ],
                ),
                style: TextStyle(fontSize: 15.sp),
              ),
            ],
          ),

          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width - 200,
                ),
                child: Text(
                  Languages.of(context).labelSelectLanguage == "English"
                      ? _service.title
                      : _service.titleAr,

                  // (_service.title ?? 'N/A'),
                  //_service.id.toString(),
                  style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 26.sp,
                      height: 1.4,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Container(),),
              LimitedBox(
                maxWidth: 130.0,
                child: _textIcon(
                    text: (_service.region?.name ?? '').replaceAll('-', ''),
                    wrap: true,
                    icon: Icons.location_pin),
              ),
            ],
          ),*/
          SizedBox(
            height: 35.w,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _productActionBtn(
                  color: Colors.red,
                  icon: Icons.favorite_border,
                  text: favorite
                      ? Languages.of(context).favoriteno
                      : Languages.of(context).favorite,
                  onTap: () {
                    Res.USER != null
                        ? _updateFavorite()
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RedirectToAuth()));
                  },
                  done: favorite ? true : false),
              SizedBox(
                width: 20.w,
              ),
              // _productActionBtn(
              //     color: Colors.blue,
              //     icon: FontAwesome.thumbs_up,
              //     text: isLiked
              //         ? Languages.of(context).dislike
              //         : Languages.of(context).like,
              //     onTap: () {
              //       Res.USER != null
              //           ? _likeProd()
              //           : Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => RedirectToAuth()));
              //     },
              //     done: isLiked ? true : false),
              // SizedBox(
              //   width: 20.w,
              // ),
              _productActionBtn(
                  color: Colors.green,
                  icon: Icons.share,
                  text: Languages.of(context).productDetailsShare,
                  onTap: () {
                    return Share.share('https://bunyan.qa/service/${_service.slug}');
                  }),
              SizedBox(
                width: 20.w,
              ),
              _productActionBtn(
                icon: Icons.assistant_photo,
                color: Colors.red,
                text: isreported
                    ? Languages.of(context).productDetailsReport
                    : Languages.of(context).productDetailsReport,
                onTap: () {
                  _reportAd();
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _productActionBtn(
      {Color color,
      String text,
      IconData icon,
      bool done = false,
      Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: .25.sw,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          color: done ? color : null,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 8.w),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17.sp,
                color: done ? Colors.white : color,
              ),
              SizedBox(
                width: 8.w,
              ),
              Center(
                child: LimitedBox(
                  maxWidth: .18.sw,
                  child: AutoSizeText(
                    text,
                    style:
                    GoogleFonts.cairo(color: done ? Colors.white : color),
                    presetFontSizes: [
                      16.sp,
                      15.sp,
                      14.sp,
                      13.sp,
                      12.sp,
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _userCard() {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: _service.ownerImage != null
                  ? 'https://bunyan.qa/images/users/' +
                      _service.ownerImage
                  : '',
              progressIndicatorBuilder: (_, __, ___) =>
                  _shimmer(width: 600.w, height: 400.w),
              errorWidget: (_, __, ___) => Container(
                width: 600.w,
                height: 400.w,
                child: Icon(Icons.broken_image_outlined),
                color: Colors.white,
              ),
              width: 600.w,
              height: 400.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 350.w),
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 60.w,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _contactBtn(
                            text: Languages.of(context).productDetailsCallWhats,
                            icon: FontAwesome.whatsapp,
                            onTap: () {
                              launch('https://wa.me/$_phone}');
                            },
                            color: Colors.green),
                      ),
                      SizedBox(
                        width: 5.sp,
                      ),
                      Expanded(
                        child: _contactBtn(
                            text: Languages.of(context).productDetailsCallPhone,
                            icon: FontAwesome.phone,
                            onTap: () {
                              launch('tel:${_phone}');
                            },
                            color: Colors.blue),
                      ),
                      SizedBox(
                        width: 5.sp,
                      ),
                      Expanded(
                        child: _contactBtn(
                            text: Languages.of(context).productDetailsCallChat,
                            icon: FontAwesome.comments,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ConversationScreen(
                                            chat: ChatModel(
                                              receiver: _service.owner,
                                              sender: Res.USER,
                                            ),
                                            senderName:
                                                _service.owner.name,
                                          )));
                            },
                            color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: MaterialButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileAgent(
                                    profile: _service.owner,
                                    enterprise: _service.enterprise,
                                  ))),
                      child: Text(
                        Languages.of(context).productDetailsMoreAds,
                        style: GoogleFonts.cairo(
                            fontSize: 18.sp, fontWeight: FontWeight.w700),
                      ),
                      textColor: Colors.black,
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.black)),
                      visualDensity: VisualDensity.comfortable,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300.w,
          right: .0,
          left: .0,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileAgent(
                            profile: _service.owner,
                            enterprise: _service.enterprise,
                          )));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5000.0)),
                  child: Container(
                    padding: EdgeInsets.all(1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5000.0),
                      child: Hero(
                        tag: 'profile_picture',
                        child: CachedNetworkImage(
                          imageUrl: 'https://bunyan.qa/images/users/' +
                              _service.ownerImage,
                          progressIndicatorBuilder: (_, __, ___) =>
                              _shimmer(width: 100.w, height: 100.w),
                          errorWidget: (_, __, ___) => Container(
                            width: 100.w,
                            height: 100.w,
                            child: Icon(Icons.broken_image_outlined),
                            color: Colors.white,
                          ),
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  _service.owner?.name ?? '',
                  style: GoogleFonts.cairo(fontSize: 15.sp),
                )
              ],
            ),
          ),
        ),
        Container(
          width: size.width * 0.25,
        ),
        Positioned(
          right: 3,
          top: 3,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileEnterprise(
                          profile: _service.owner,
                          enterprise: _service.enterprise,
                        )),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                alignment: Alignment.topRight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Languages.of(context).gotoprofile,
                      style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _textIcon({String text, IconData icon, bool wrap = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 25.sp,
        ),
        SizedBox(
          width: 10.w,
        ),
        Text(
          text,
          style: GoogleFonts.cairo(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20.sp),
          softWrap: true,
        ),
      ],
    );
  }

  Widget _shimmer({double width, double height}) {
    return Shimmer.fromColors(
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFf3f3f3),
      ),
      baseColor: const Color(0xFFf3f3f3),
      highlightColor: const Color(0xFFE8E8E8),
    );
  }

  // Widget _headerImage() {
  //   return TransitionToImage(
  //     image:
  //         AdvancedNetworkImage(_service.photos ?? '', useDiskCache: true),
  //     width: 1.sw,
  //     fit: BoxFit.cover,
  //     loadingWidget: _shimmer(),
  //     placeholder: Icon(Icons.broken_image_outlined),
  //     repeat: ImageRepeat.noRepeat,
  //   );
  // }

  Widget _slider() {
    return Stack(
      children: [
        CarouselSlider.builder(
            options: CarouselOptions(
              height: .40.sh,
              viewportFraction: 1,
              autoPlay: _service.photos.length > 1,
              autoPlayInterval: Duration(seconds: 5),
              enableInfiniteScroll: _service.photos.length > 1,
            ),
            itemCount: _service.photos.length,
            itemBuilder: (context, index, realIndex) => CachedNetworkImage(
                  imageUrl: 'https://bunyan.qa/images/posts/' +
                      _service.photos[index],
                  width: 1.sw,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (_, __, ___) => _shimmer(),
                  errorWidget: (_, __, ___) =>
                      Icon(Icons.broken_image_outlined),
                  repeat: ImageRepeat.noRepeat,
                )),
        Positioned(
          bottom: 80.h,
          left: 40.w,
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(.4),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(10))),
            child: Padding(
              padding: const EdgeInsets.only(right: 6,top: 6,left: 6),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                      topLeft: Radius.circular(10)),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(3.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999999),
                  child: CachedNetworkImage(
                    imageUrl:
                    'https://bunyan.qa/images/users/${_service.ownerImage}',
                    progressIndicatorBuilder: (_, __, ___) =>
                        _shimmer(width: 100.0, height: 100.0),
                    errorWidget: (_, __, ___) =>
                        Image.asset('assets/icons/avatar.png'),
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20.h,
          left: .0,
          child: Container(
            padding: EdgeInsets.only(top: 5.h, left: 25.w, right: 25.w),
            width: 1.sw,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                    topLeft: Radius.circular(10))),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(0.0),
                          bottomRight: Radius.circular(0.0),
                          topLeft: Radius.circular(10)),
                      color: Colors.white.withOpacity(.6)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                              Languages.of(context).labelSelectLanguage ==
                                  "English"
                                  ? _service.title
                                  : _service.titleAr,
                              style: GoogleFonts.cairo(
                                color: Colors.black,
                                fontSize: 21.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip),
                        ),


                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(0.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                          topLeft: Radius.circular(0)),
                      color: Colors.white.withOpacity(.9)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Row(
                         children: [
                           Icon(Icons.phone_android,size: 25.sp,
                             color: Colors.black,),
                           Text(
                             _service.phone??'',
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                             style: GoogleFonts.cairo(
                                 fontWeight: FontWeight.w700,
                                 color: Colors.black,
                                 fontSize: 18.0.sp,
                                 height: 1.2),
                           ),

                         ],
                       ),
                       Row(
                         children: [
                           Icon(Icons.place),
                           Text(
                             Languages.of(context).labelSelectLanguage ==
                                 "English"
                                 ? _service.region?.name.replaceAll('-', '')??''
                                 : _service.region?.nameAr.replaceAll('-', '')??'',
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                             style: GoogleFonts.cairo(
                                 fontWeight: FontWeight.w700,
                                 color: Colors.black,
                                 fontSize: 18.0.sp,
                                 height: 1.2),
                           ),

                         ],
                       ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],

    );
  }

  String formatDecimal(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  Widget _contactBtn(
      {String text, IconData icon, Color color, Function() onTap}) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        width: size.width * 0.25,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27.sp,
              color: Colors.white,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              text,
              style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enterpriseActionBtn(
      {Color color,
      IconData icon,
      String text,
      VoidCallback onTap,
      bool done = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(5.0),
            color: done ? color : null),
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17.sp,
              color: !done ? color : Colors.white,
            ),
            SizedBox(
              width: 8.w,
            ),
            Text(
              text,
              style: GoogleFonts.cairo(
                  color: !done ? color : Colors.white, fontSize: 16.sp),
            )
          ],
        ),
      ),
    );
  }

  void _showErrorDialog({String text}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(
                text ?? Languages.of(context).reportad,
                style: GoogleFonts.cairo(),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      Languages.of(context).agreeon,
                      style: GoogleFonts.cairo(color: Colors.teal),
                    ))
              ],
            ));
  }

  _updateFavorite() {
      ProductsWebService()
          .updateFav(id: _service.id, type: ProductsWebService.SERVICE)
          .then((value) {
          setState(() {
            favorite = value;
          });
      });
  }

  void _likeProd() {
    if (isLiked == true) {
      ProductsWebService()
          .dislikeProd(
        id: _service.id,
        isRealEstate: false,
      )
          .then((value) {
        if (value != null) {
          setState(() {
            isLiked = false;
          });
        }
      });
    } else {
      ProductsWebService()
          .likeProd(
              id: _service.id,
              isRealEstate: false,
              dislike: _service.isLiked ? true : false)
          .then((value) {
        if (value != null) {
          setState(() {
            isLiked = true;
          });
        }
      });
    }
  }

  Widget _contentCard() {
    final desc = Languages.of(context).labelSelectLanguage == "English"
        ? _service.description
        : _service.descriptionAr;
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                //vsync: this,
                child: Html(
                  data: desc.substring(0, _seeAllDesc ? desc.length : min(desc.length, 200)),
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

  getUserLocation(double lt, lg) async {
    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
      }
      myLocation = null;
    }
    final coordinates = new Coordinates(lt, lg);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      address1 = first.locality;
      address2 = first.subLocality;
      address3 = first.addressLine;
    });
    return first;
  }


  void _viewService() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _service.views = (int.parse(_service.views) + 1).toString();
      });
    });
    AdvertisesWebService().addView(_service.slug);
  }

  void _addView() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _service.views = (int.parse(_service.views) + 1).toString();
      });
    });
    AdvertisesWebService().addView(_service.slug, isProperty: false);
  }

  Widget _moreAds() {
    return _isFetching || (!_isFetching && _services.isNotEmpty) ? Padding(
        padding: EdgeInsets.only(bottom: 50.h, right: 20.h, left: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Languages.of(context).related,
              style:
              GoogleFonts.cairo(color: Colors.black, fontSize: 30.sp),
            ),
            StaggeredGridView.countBuilder(
                // childAspectRatio: MediaQuery.of(context).size.width /
                //   (MediaQuery.of(context).size.height / 1.7),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _isFetching
                    ? 4
                    : _services.length,
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _isFetching
                      ? _shimmerItem(index)
                      : _services[index].id != _service.id
                  ? InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ServiceScreen(
                                          service: _services[index],
                                        )));
                            //Res.titleStream.add(Languages.of(context).realEstate);
                          },
                          child: CardItemService(service: _services[index]),
                        ) : Container();
                }),
          ],
        )) : Container();
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
                    height: index.isOdd ? 300.h : 280.h,
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

  Future<void> _reportAd() async {
    final report = ReportAdModel(
        type: _service is ServiceModel
            ? ProductsWebService.SERVICE
            : ProductsWebService.REAL_ESTATE,
        slug: _service.slug,
        name: Res.USER.name,
        email: Res.USER.email,
        phone: Res.USER.phone);
    final formKey = GlobalKey<FormState>();
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController(text: report.name);
        final phoneController = TextEditingController(text: report.phone);
        final emailController = TextEditingController(text: report.email);

        return AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 35,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Languages.of(context).report,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Container(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              hintText: Languages.of(context).enterfullname,
                              labelStyle: TextStyle(fontSize: 20.sp),
                              border: InputBorder.none),
                          onSaved: (String value) {
                            report.name = value;
                          },
                          validator: (String value) {
                            return value.isEmpty
                                ? Languages.of(context).required
                                : null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 20.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8)),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          decoration: InputDecoration(
                              hintText: Languages.of(context).email,
                              labelStyle: TextStyle(fontSize: 20.sp),
                              border: InputBorder.none),
                          onSaved: (String value) {
                            report.email = value;
                          },
                          validator: (String value) {
                            return value.isEmpty
                                ? Languages.of(context).required
                                : null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 20.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8)),
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              hintText: Languages.of(context).enterphone,
                              labelStyle: TextStyle(fontSize: 20.sp),
                              border: InputBorder.none),
                          onSaved: (String value) {
                            report.phone = value;
                          },
                          validator: (String value) {
                            return value.isEmpty
                                ? Languages.of(context).required
                                : null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 60,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: TextFormField(
                            maxLines: 2,
                            decoration: InputDecoration(
                                hintText: Languages.of(context).adDescription,
                                labelStyle: TextStyle(fontSize: 20.sp),
                                border: InputBorder.none),
                            onSaved: (String value) {
                              report.message = value;
                            },
                            validator: (String value) {
                              return value.isEmpty
                                  ? Languages.of(context).required
                                  : null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Message which will be pop up on the screen
          // Action widget which will provide the user to acknowledge the choice
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            InkWell(
              onTap: () {
                if (formKey.currentState.validate()) {
                  formKey.currentState.save();
                  Navigator.pop(context, report);
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 6.0),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  Languages.of(context).report,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          insetPadding: EdgeInsets.zero,
        );
      },
    ).then((value) {
      if (value != null) {
        final dialog = AwesomeDialog(
          context: context,
          dismissOnBackKeyPress: false,
          dismissOnTouchOutside: false,
          dialogType: DialogType.NO_HEADER,
          body: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        )..show();

        ProductsWebService().reportProduct(value).then((_) {
          dialog.dismiss();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.SUCCES,
            desc: Languages.of(context).reportad,
          )..show();
          setState(() {
            isreported = true;
          });
        });
      }
    });
  }

  Future<void> _getMoreData() async {
    final response = await ProductsWebService().getServices(filter:
    ServicesFilterModel(category: _service.categorySlug));
    _services.addAll(response);
    _services.removeWhere((element) => element.id == _service.id);
    setState(() {
      _isFetching = false;
    });
  }

  void _initData() {
    if (_service == null) {
      _getService();
      return;
    }
    if (_service.favorite == true) {
      setState(() {
        favorite = true;
      });
    }
    if (_service.isLiked == true) {
      setState(() {
        isLiked = true;
      });
    }
    if (_service.isLiked == true) {
      setState(() {
        isreported = true;
      });
    }

    // add_view(_service.id);
    _scrollController.addListener(_scrollListener);

    // _phone = _service.owner.phone.replaceAll(' ', '');
    // _phone = _phone.replaceAll('+', '');
    // if (_phone.startsWith('00')) _phone = _phone.replaceFirst('00', '');

    _viewService();

    _getMoreData();
  }

  Future<void> _getService() async {
    try {
      _service = await ProductsWebService().getServiceBySlug(widget.slug);
    } catch (e) {
      Navigator.pop(context);
    }
    setState(() {
      _isLoadingService = false;
    });
    _initData();
  }
}
