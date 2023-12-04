import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/notification.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/notifications.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shimmer/shimmer.dart';

import '../product/product_screen.dart';
import '../services/service_screen.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({Key key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with RouteAware, RouteObserverMixin {
  bool _isLoading = true;
  int _currentIndex = 0;
  List<NotificationModel> _notifs;

  @override
  void initState() {
    super.initState();
    Res.titleStream.add('التنبيهات');

    NotificationsWebService().getNotifications().then((notifs) {
      setState(() {
        _isLoading = false;
        _notifs = notifs;
      });
    });
  }

  @override
  void didPopNext() {
    Res.titleStream.add('التنبيهات');
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon:  Icon(Icons.notifications_outlined,size: 40.sp,),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationsScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.language_outlined,size: 40.sp,),
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
        title: Text(Languages.of(context).notification),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
      body: !_isLoading
          ? IndexedStack(
              index: _isLoading
                  ? 0
                  : _notifs != null && _notifs.isEmpty
                      ? 1
                      : 2,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        color: Color(0xffd6d6d6),
                        size: 90.sp,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClayText(
                          Languages.of(context).emptyNotifications,
                          style: GoogleFonts.cairo(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          depth: -10,
                          textColor: Color(0xffd6d6d6),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.h, vertical: 30.h),
                  itemCount: _notifs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: InkWell(
                          onTap: () => _readNotif(_notifs[index]),
                          child: Container(
                            //height: .15.sh,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: .6.sw,
                                      child: Text(
                                        _notifs[index].title,
                                        style: GoogleFonts.cairo(
                                            fontSize: 25.sp,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 22.w,
                                      ),
                                      child: Text(
                                        formatDate(_notifs[index].createdAt,
                                            [yyyy, '-', mm, '-', dd, '  ', hh, ':', nn]),
                                        style: GoogleFonts.cairo(
                                            color: Colors.grey,
                                            fontSize: 20.sp),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : Center(child: _loadingWidget()),
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


  void _readNotif(NotificationModel notif) {
    NotificationsWebService().readNotification(notif.id).then((value) {
      setState(() {
        _notifs.removeWhere((element) => element.id == notif.id);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (notif != null) {
        if (notif.slug.contains('/property/')) {
          final slug = notif.slug.substring(notif.slug.indexOf('/property/') + 10);
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ProductScreen(slug: slug,)));
        } else if (notif.slug.contains('/service/')) {
          final slug = notif.slug.substring(notif.slug.indexOf('/service/') + 9);
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ServiceScreen(slug: slug,)));
        }
      }
    });
  }
}
