import 'package:auto_size_text/auto_size_text.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/ui/services/services_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class ServicesCategoriesScreen extends StatefulWidget {
  ServicesCategoriesScreen({Key key}) : super(key: key);

  @override
  _ServicesCategoriesState createState() => _ServicesCategoriesState();
}

class _ServicesCategoriesState extends State<ServicesCategoriesScreen>
    with RouteAware, RouteObserverMixin {
  List<Map<String, dynamic>> _cats = List();

  @override
  void initState() {
    super.initState();
    Res.titleStream.add('خدمات');

    _cats.add({'title': 'شاهد جميع الإعلانات', 'icon': null});
    _cats.add({'title': 'ابواب', 'icon': ''});
    _cats.add({'title': 'نوافذ', 'icon': ''});
    _cats.add({'title': 'تكييف', 'icon': ''});
    _cats.add({'title': 'بناء', 'icon': ''});
    _cats.add({'title': 'خرائط واستشارات', 'icon': ''});
    _cats.add({'title': 'مقاولات', 'icon': ''});
    _cats.add({'title': 'مطابخ', 'icon': ''});
    _cats.add({'title': 'اثاث مستعمل', 'icon': ''});
    _cats.add({'title': 'تزويق و ديكور', 'icon': ''});
    _cats.add({'title': 'اضاءة', 'icon': ''});
    _cats.add({'title': 'حدائق', 'icon': ''});
    _cats.add({'title': 'تأثيث', 'icon': ''});
  }

  @override
  void didPopNext() {
    Res.titleStream.add('خدمات');
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: 25.h, right: 25.w, left: 25.w, bottom: 15.w),
                child: Text(
                  Languages.of(context).typeservice,
                  style: GoogleFonts.cairo(fontSize: 35.sp),
                ),
              ),
              Expanded(
                child: GridView.builder(
                    itemCount: _cats.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 5.0,
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) => InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ServicesScreen())),
                          child: Container(
                            decoration: BoxDecoration(
                                image: _cats[index]['icon'] != null
                                    ? DecorationImage(
                                        image: AssetImage('assets/re.png'))
                                    : null),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black38.withOpacity(.3),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 8.0),
                              child: Center(
                                child: AutoSizeText(
                                  _cats[index]['title'],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
