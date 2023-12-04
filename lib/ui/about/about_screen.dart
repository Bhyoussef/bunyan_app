import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/about.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/auth/login_screen.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/content_model.dart';
import '../../tools/webservices/addresses.dart';

class AboutScreen extends StatefulWidget {
  final AboutModel about;
  final String aboutsus;

  AboutScreen({Key key, this.about, this.aboutsus}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with RouteAware, RouteObserverMixin {
  Locale currentLang;
  List<Content> content = [];
  bool _isFetching = true;

  @override
  void initState() {
    getCurrentLang();
    print('${widget.about}');
    getcontent();
    super.initState();
    print('_about');
    Res.titleStream.add('عن بنيان');
  }

  @override
  void didPopNext() {
    print('pop');
    Res.titleStream.add('عن بنيان');
    super.didPopNext();
  }

  @override
  void didPush() {
    super.didPush();
    Res.titleStream.add('عن بنيان');
  }

  getCurrentLang() async {
    getLocale().then((locale) {
      setState(() {
        currentLang = locale;
      });
    });

    //getData();
  }

  getData() async {
    final futures = await Future.wait(
        [ProductsWebService().getabout(currentLang.toString())]);
  }

    getcontent() async {
      final data = await AddressesWebService().getcontent();
      setState(() {
        content.addAll(data);
        print(content);
        _isFetching = false;
      });

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
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20.00,
              ),
            ),
          ),
          title: _isFetching?Center(child: Center(

          ),):Text(
            widget.aboutsus == 'about'?content[0].title:
            widget.aboutsus == 'terms' ?content[2].title:
            content[1].title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 22.0.sp,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: _isFetching?Center(child: CircularProgressIndicator(

        ),):SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 40.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.aboutsus == 'terms'?Html(
                      data: content[2].description.substring(0),
                    ):
                    widget.aboutsus == 'about'?Html(
                      data: content[0].description.substring(0),
                    ):Html(
                      data: content[1].description.substring(0),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Center(
                        child: Text(
                      Languages.of(context).followus,
                      style: GoogleFonts.cairo(fontSize: 40.sp),
                    )),
                    SizedBox(
                      height: 50.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                            onTap: () =>
                                launch('https://www.instagram.com/bunyan.qa'),
                            child: const Icon(
                              FontAwesome.instagram,
                              size: 50,
                            )),
                        InkWell(
                            onTap: () =>
                                launch('https://www.facebook.com/Bunyan.qa'),
                            child: const Icon(
                              FontAwesome.facebook_official,
                              size: 50,
                            )),
                      ],
                    ),
                    SizedBox(
                      height: .13.sh,
                    ),
                  ],
                ))));
  }
  String _removeAllHtmlTags(String htmlText) {
    if (htmlText == null) return 'N/A';
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }
}
