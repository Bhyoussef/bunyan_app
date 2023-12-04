import 'package:auto_size_text/auto_size_text.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/ui/real_estates/real_estates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class RealEstateCategoriesScreen extends StatefulWidget {
  RealEstateCategoriesScreen({Key key}) : super(key: key);

  @override
  _RealEstateCategoriesState createState() => _RealEstateCategoriesState();
}

class _RealEstateCategoriesState extends State<RealEstateCategoriesScreen>
    with RouteAware, RouteObserverMixin {
  List<Map<String, dynamic>> _cats = [];

  @override
  void initState() {
    super.initState();
    Res.titleStream.add(Languages.of(context).realEstate);

    _cats.add({'title': 'شاهد جميع الإعلانات', 'icon': null});
    _cats.add({'title': Languages.of(context).apartments, 'icon': ''});
    _cats.add({'title': Languages.of(context).villa, 'icon': ''});
    _cats.add({'title': Languages.of(context).depot, 'icon': ''});
    _cats.add({'title': 'مكاتب تجارية', 'icon': ''});
    _cats.add({'title': 'عقارات اخرى', 'icon': ''});
    _cats.add({'title': 'محلات تجارية', 'icon': ''});
    _cats.add({'title': 'اراضي', 'icon': ''});
    _cats.add({'title': 'فلل ادارية و تجارية', 'icon': ''});
    _cats.add({'title': 'عمارات و ابراج', 'icon': ''});
    _cats.add({'title': 'بيوت شعبية', 'icon': ''});
    _cats
        .add({'title': Languages.of(context).employeeAccomodation, 'icon': ''});
  }

  @override
  void didPopNext() {
    Res.titleStream.add(Languages.of(context).realEstate);
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                'نوع العقار',
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
                                builder: (context) => RealEstatesScreen())),
                        child: Container(
                          decoration: BoxDecoration(
                              image: _cats[index]['icon'] != null
                                  ? DecorationImage(
                                      image: AssetImage('assets/re.png'))
                                  : null),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
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
    );
  }
}
