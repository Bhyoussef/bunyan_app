import 'dart:async';
import 'dart:ui';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/passthrough_home.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/add/add_screen.dart';
import 'package:bunyan/ui/chat/chat_screen.dart';
import 'package:bunyan/ui/favorites/favorites_screen.dart';
import 'package:bunyan/ui/home/home_screen.dart';
import 'package:bunyan/ui/product/product_screen.dart';
import 'package:bunyan/ui/profile/user_profile.dart';
import 'package:bunyan/ui/services/service_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bunyan/models/position.dart';
import 'package:location/location.dart';
import 'package:share/share.dart';
import 'package:uni_links/uni_links.dart' as UniLink;

import 'main_drawer.dart';

class MainScreen extends StatefulWidget {
  final bool showVerifMail;
  final int menu_index;

  final PassthroughHome passthrough;

  MainScreen({Key key, this.showVerifMail, this.menu_index, this.passthrough})
      : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  PassthroughHome _passthroughHome;
  int _currentIndex = 0;
  List<Widget> _pages;
  PositionModel _position;
  LocationData mycurrentLocation;
  StreamSubscription _unilinkStreamSubscription;

  getCurrentLocation() async {
    final location = Location();
    mycurrentLocation = await location.getLocation();
    setState(() {
      _position = PositionModel(
          lat: mycurrentLocation.latitude, lng: mycurrentLocation.longitude);
      print('_position ${_position.toJson()}');
    });
  }

  @override
  void initState() {
    if (widget.menu_index != null) {
      _currentIndex = widget.menu_index;
    }
    getCurrentLocation();
    _passthroughHome = widget.passthrough;

    Res.PAGE_SELECTOR_STREAM.stream.listen((event) {
      setState(() {
        _currentIndex = event;
      });
    });

    _initUniLinks();

    if (!Res.shownDialog) {
      Res.shownDialog = true;
      Future.delayed(Duration(seconds: 3)).then((value) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Languages.of(context).share,
                        style: GoogleFonts.cairo(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,fontSize: 28.sp),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1000),
                                color: Color(0xFF750606)),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 50.sp,
                            )),
                      )
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Languages.of(context).shaareapp,
                        style: GoogleFonts.cairo(
                            color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/fb.svg',
                            width: 40.0,
                            fit: BoxFit.cover,
                          ),
                          SvgPicture.asset(
                            'assets/icons/tw.svg',
                            width: 40.0,
                            fit: BoxFit.cover,
                          ),
                          SvgPicture.asset(
                            'assets/icons/ig.svg',
                            width: 40.0,
                            fit: BoxFit.cover,
                          ),
                          SvgPicture.asset(
                            'assets/icons/wa.svg',
                            width: 40.0,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black26,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        height: 40.0,
                        minWidth:double.infinity,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Color(0xFF750606)
                          ),

                          borderRadius: BorderRadius.circular(6.0),
                        ),


                        onPressed: () {
                          Share.share(
                            'Thanks for using Bunyan app.\nAndroid Play store link: https://play.google.com/store/apps/details?id=com.bunyan.bunyan\nApple App sotre link: https://apps.apple.com/tt/app/bunyan/id1589752170',
                          );
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          Languages.of(context).share,
                          style: GoogleFonts.cairo(
                              color: Color(0xFF750606), fontWeight: FontWeight.bold),
                        ),
                        //style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: Colors.red)),),
                      ),
                    )
                  ],
                ));
      });
    }

    super.initState();
  }

  Future<void> _initUniLinks() async {
    // ... check initialLink
    final link = await UniLink.getInitialLink();
    _parseLink(link);
    // Attach a listener to the stream
    _unilinkStreamSubscription = UniLink.linkStream.listen((String link) {
      _parseLink(link);
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _unilinkStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      HomeScreen(passthrough: _passthroughHome),
      FavoritesScreen(),
      AddScreen(),
      ChatScreen(),
      UserProfileScreen(
        profile: Res.USER,
      ),
    ];
    return Scaffold(
      drawer: MainDrawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: StreamBuilder<bool>(
          stream: null,
          builder: (context, snapshot) {
            return BottomAppBar(
              shape: CircularNotchedRectangle(),
              notchMargin: 3.0,
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 82.h,
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
                        if (index == 0) _passthroughHome = null;
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.home_outlined,size: 30.sp
                          ),
                          activeIcon: Icon(Icons.home,size: 30.sp),
                          label: Languages.of(context).menuHome,
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.favorite_outline,size: 30.sp,
                          ),
                          activeIcon: Icon(Icons.favorite,size: 30.sp,),
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
                            Icons.chat_outlined,size: 30.sp
                          ),
                          activeIcon: Icon(Icons.chat,size: 30.sp),
                          label: Languages.of(context).productDetailsCallChat,
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.person_outline,size: 30.sp
                          ),
                          activeIcon: Icon(Icons.person,size: 30.sp),
                          label: Languages.of(context).menuProfile,
                        ),
                      ]),
                ),
              ),
            );
          }),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black,
              child: Icon(FontAwesome.plus),
              onPressed: () => setState(() {
                _currentIndex = 2;
              }),
            )
          : Container(),
    );
  }

  static Route<void> _modalBuilder(BuildContext context, Object arguments) {
    return CupertinoModalPopupRoute<void>(
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text(''),
          message: Text('عليك فتح حساب للاستخدام'),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _parseLink(String link) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (link != null) {
        if (link.contains('/property/')) {
          final slug = link.substring(link.indexOf('/property/') + 10);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductScreen(
                        slug: slug,
                      )));
        } else if (link.contains('/service/')) {
          final slug = link.substring(link.indexOf('/service/') + 9);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ServiceScreen(
                        slug: slug,
                      )));
        }
      }
    });
  }
}
