import 'dart:ui';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/ui/about/about_screen.dart';
import 'package:bunyan/ui/add/add_screen.dart';
import 'package:bunyan/ui/enterprises/enterprises_screen.dart';
import 'package:bunyan/ui/news/news_screen.dart';
import 'package:bunyan/ui/real_estates/real_estates_screen.dart';
import 'package:bunyan/ui/services/services_screen.dart';
import 'package:bunyan/ui/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../tools/webservices/users.dart';
import '../auth/login_screen.dart';
import '../enterprises/business_category.dart';
import '../onBoardingScreen.dart';

class MainDrawer extends StatefulWidget {
  final BuildContext ctx;

  const MainDrawer({Key key, this.ctx}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();

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
            /* CupertinoActionSheetAction(
              child: const Text('Action Two'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),*/
          ],
        );
      },
    );
  }
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .65.sw,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: Drawer(
          child: Container(
            color: Color(0xff303030).withOpacity(.3),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  height: 1.sh,
                  width: .65.sw,
                  color: Colors.white30,
                  child: SingleChildScrollView(
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              Languages.of(context).home,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            tileColor: Colors.blue,
                          ),




                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.w, vertical: 20.h),
                            child: Text(
                              Languages.of(context).categorie,
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.sp),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RealEstatesScreen()));

                              },
                              title: Text(
                                Languages.of(context).realEstate,
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                              tileColor: Colors.grey.withOpacity(.5),
                              leading: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffb5af00),
                                  ),
                                  padding: EdgeInsets.all(15.sp),
                                  child: Icon(
                                    Icons.home,
                                    color: Colors.white,
                                    size: 25.sp,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ServicesScreen()));

                              },
                              title: Text(
                                Languages.of(context).services,
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                              tileColor: Colors.grey.withOpacity(.5),
                              leading: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.purple,
                                  ),
                                  padding: EdgeInsets.all(15.sp),
                                  child: Icon(
                                    Icons.work,
                                    color: Colors.white,
                                    size: 25.sp,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Business_Category()));

                              },
                              title: Text(
                                Languages.of(context).agencies,
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                              tileColor: Colors.grey.withOpacity(.5),
                              leading: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.pink,
                                  ),
                                  padding: EdgeInsets.all(15.sp),
                                  child: Icon(
                                    Icons.location_city,
                                    color: Colors.white,
                                    size: 25.sp,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewsScreen()));

                              },
                              title: Text(
                                Languages.of(context).news,
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                              tileColor: Colors.grey.withOpacity(.5),
                              leading: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.deepOrange,
                                  ),
                                  padding: EdgeInsets.all(15.sp),
                                  child: Icon(
                                    Icons.map,
                                    color: Colors.white,
                                    size: 25.sp,
                                  )),
                            ),
                          ),

                          /* ListTile(
                            onTap: () {
                              if (Res.USER == null) {
                                Navigator.of(context)
                                    .restorablePush(_modalBuilder);
                              } else {
                                Navigator.push(
                                    ctx,
                                    MaterialPageRoute(
                                        builder: (context) => AddScreen()));
                                Navigator.pop(context);
                              }
                            },
                            title: Text(
                              Languages.of(context).adAction,
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            leading: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),*/
                          /*ListTile(
                            title: Text(
                              'تغيير اللغة',
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            leading: Icon(
                              Icons.translate,
                              color: Colors.white,
                            ),
                          ),*/
                          /*  ListTile(
                            title: Text(
                              Languages.of(context).share,
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            leading: Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ),*/
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AboutScreen(
                                        aboutsus: 'about',
                                      )));
                            },
                            child: ListTile(
                              title: Text(
                                Languages.of(context).about,
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                              /*    leading: Icon(
                                Icons.info_outline,
                                color: Colors.white,
                              ),*/
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AboutScreen(
                                        aboutsus: 'terms',
                                      )));
                            },
                            title: Text(
                              'Terms and Condition',
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            /*    leading: Icon(
                              Icons.privacy_tip,
                              color: Colors.white,
                            ),*/
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AboutScreen(
                                        aboutsus: 'privacy',
                                      )));
                            },
                            title: Text(
                              'Privacy and Policy',
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            /*    leading: Icon(
                              Icons.privacy_tip_outlined,
                              color: Colors.white,
                            ),*/
                          ),

                          ListTile(
                            onTap: () async {
                              if (Res.USER != null) {
                                //final prefs =
                                //await SharedPreferences.getInstance();
                                //await prefs.remove('user');
                                //Res.USER = null;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Are you sure you want to log out?'),
                                      actions: <Widget>[
                                        // Cancel button
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                        ),
                                        // Confirm button
                                        TextButton(
                                          child: Text('Confirm'),
                                          onPressed: () {
                                            logOut();
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }else {
                                redirect();
                              }

                            },
                            title: Text(
                              Res.USER != null
                                  ? Languages.of(context).logout
                                  : Languages.of(context).loginSignIn,
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                            leading: Icon(
                              Icons.power_settings_new,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
  redirect() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            destination: 'home',
          ),
        ));
  }
}
