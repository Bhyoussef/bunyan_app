import 'dart:convert';
import 'dart:io';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/common/card_item.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/onBoardingScreen.dart';
import 'package:bunyan/ui/product/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import '../profileInfo.dart';


class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key, this.profile, this.enterprise}) : super(key: key);

  final PersonModel profile;
  final EnterpriseModel enterprise;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with RouteAware, RouteObserverMixin {
  List<ProductListModel> _products;
  bool isLoading;
  PersonModel _profile;
  bool _requestingFollowing = false;
  String _phone;
  String photoProfile;
  Locale currentLang;
  int _currentIndex = 0;
  bool _isFetching = true;
  int forRent = 0;
  int forSale = 0;
  int forCommercial = 0;

  @override
  void initState() {
    getCurrentUser();
    isLoading = true;
    getCurrentLang();
    super.initState();
    if (widget.profile != null) {
      _profile = PersonModel.fromJson(widget.profile.toJson());
    } else {
      _profile = Res.USER;
    }
    /*if (_profile != null) {
      _phone = _profile.phone?.replaceAll(' ', '') ?? '';
      _phone.replaceAll('+', '');
      if (_phone.startsWith('00')) _phone = _phone.replaceFirst('00', '');

      UsersWebService().getUserProfile(_profile.id).then((response) {
        setState(() {
          final oldProfile = PersonModel.fromJson(_profile.toJson());
          _profile = response['user'];
          photoProfile = _profile.photo;
          _products = [];
          _products.addAll(response['products']);
          _products.addAll(response['services']);
          _isFetching = false;

          setState(() {
            forRent = _products
                .where((p) => p.type != null && p.type.id == 1)
                .toList()
                .length;
            forSale = _products
                .where((p) => p.type != null && p.type.id == 2)
                .toList()
                .length;
            forCommercial = _products
                .where((p) => p.type != null && p.type.id == 3)
                .toList()
                .length;
          });
          if (oldProfile == Res.USER) {
            Res.USER = _profile;
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('user', jsonEncode(Res.USER.toJson()));
            });
          }
          isLoading = false;
        });
      });
    }*/
  }

  getCurrentLang() async {
    getLocale().then((locale) {
      setState(() {
        currentLang = locale;
      });
    });
  }

  getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user');
    setState(() {
      _profile = PersonModel.fromJson(jsonDecode(user));
    });
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

  _getFromGallery() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      personalPhoto = File(pickedFile.path);
      uploadPhotoProfile(personalPhoto);
      pickedFile = null;
    });
  }

  _getFromCamera() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      personalPhoto = File(pickedFile.path);
      uploadPhotoProfile(personalPhoto);
      pickedFile = null;
    });
  }

  uploadPhotoProfile(File photo) async {
    setState(() {
      isLoading = true;
    });
    UsersWebService()
        .updatePhotoProfile(idsession: _profile.id, profilePhoto: photo)
        .then((data) {
      setState(() {
        photoProfile = data['photo_url'];
        print('photoProfile $photoProfile');
        isLoading = false;
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  )),
            ),
          );
          setState(() {
            initState();
            isLoading = false;
          });
        }
      });
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
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
                child: Text('اَلْعَرَبِيَّةُ‎',
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
          icon: Icon(Icons.arrow_back_sharp, color: Colors.black, size: 25.00),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
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
                                child: Hero(
                              tag: 'profile_picture',
                              child: widget.enterprise?.image != null
                                  ? CachedNetworkImage(
                                      imageUrl: 'assets/Image 280.jpg',
                                      progressIndicatorBuilder: (_, __, ___) => _shimmer(width: 1.sw, height: 1.sw),
                                      errorWidget: (_, __, ___) => Container(
                                        width: 1.sw,
                                        height: 1.sw,
                                        child:
                                            Icon(Icons.broken_image_outlined),
                                        color: Colors.white,
                                      ),
                                      width: 1.sw,
                                      fit: BoxFit.cover,
                                    )
                                  : Image(
                                      image: AssetImage('assets/Image 280.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                            )),
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
                                        height: .30.sh,
                                        width: .86.sw,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 25.h, horizontal: 30.w),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 60),
                                              Text(
                                                widget.enterprise?.name ?? '',
                                                style: GoogleFonts.cairo(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 35.sp),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                widget.enterprise.name,
                                                style: GoogleFonts.cairo(
                                                    fontSize: 25.sp),
                                              ),
                                              widget.enterprise.name != null
                                                  ? Divider(
                                                      color: Colors.black,
                                                      height: 1,
                                                    )
                                                  : Container(),
                                              IntrinsicHeight(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                              forRent
                                                                  .toString(),
                                                              style: GoogleFonts.cairo(
                                                                  fontSize: 27
                                                                      .sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text("for rent",
                                                              style: GoogleFonts
                                                                  .cairo(
                                                                      fontSize:
                                                                          25.sp)),
                                                        ],
                                                      ),
                                                    ),
                                                    VerticalDivider(
                                                      color: Colors.black,
                                                      width: 2,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                              forSale
                                                                  .toString(),
                                                              style: GoogleFonts.cairo(
                                                                  fontSize: 27
                                                                      .sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text("for sale",
                                                              style: GoogleFonts
                                                                  .cairo(
                                                                      fontSize:
                                                                          25.sp)),
                                                        ],
                                                      ),
                                                    ),
                                                    VerticalDivider(
                                                      color: Colors.black,
                                                      width: 2,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                              forCommercial
                                                                  .toString(),
                                                              style: GoogleFonts.cairo(
                                                                  fontSize:
                                                                      27.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text("Commercial",
                                                              style: GoogleFonts
                                                                  .cairo(
                                                                      fontSize:
                                                                          25.sp)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
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
                                            _showPicker(context);
                                          },
                                          child: ProfileInfo(
                                              widget.enterprise.image != null
                                                  ? widget.enterprise.image
                                                  : 'http://sanjaymotels.com/wp-content/uploads/2019/01/testimony.png',
                                              false),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                )
              ];
            },
            body: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    CustomScrollView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), //
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.only(
                              top: 0,
                              right: .02.sw,
                              left: .02.sw,
                              bottom: 0.1.sh),
                          sliver: SliverStaggeredGrid.countBuilder(
                            crossAxisCount: 2,
                            itemCount: _isFetching ? 4 : _products.length,
                            staggeredTileBuilder: (index) =>
                                StaggeredTile.fit(1),
                            crossAxisSpacing: .0,
                            itemBuilder: (context, index) {
                              // print(' _products[index] ${_products[index].toJson()}');
                              return _isFetching
                                  ? _shimmerItem(index)
                                  : _products.length > 0
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductScreen(
                                                          product:
                                                              _products[index],
                                                        )));
                                            Res.titleStream.add(Languages.of(context).realEstate);
                                          },
                                          child: CardItem(
                                              product: _products[index]),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                            Languages.of(context)
                                                .redirectToAuthMessage,
                                            style: GoogleFonts.cairo(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )),
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
    );
  }

  Widget _contactBtn({String text, IconData icon, Color color, dynamic onTap}) {
    return InkWell(
      onTap: () {
        if (onTap != null) onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 15.w),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 20.sp),
            ),
            SizedBox(
              width: 12.w,
            ),
            Icon(
              icon,
              size: 27.sp,
              color: Colors.white,
            )
          ],
        ),
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

  _follow() {
    setState(() {
      _requestingFollowing = true;
    });
    bool isFollowing = _profile.isFollowing;
    try {
      final saved =
          UsersWebService().followUser(id: _profile.id, follow: !isFollowing);
      setState(() {
        isFollowing = !isFollowing;
        if (isFollowing)
          _profile.followers++;
        else
          _profile.followers--;
        _profile.isFollowing = isFollowing;
      });
    } catch (e) {
    } finally {
      setState(() {
        _requestingFollowing = false;
      });
    }
  }
}
