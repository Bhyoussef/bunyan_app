import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/addresses.dart';
import 'package:bunyan/tools/webservices/advertises.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/add/real_estate_page.dart';
import 'package:bunyan/ui/add/service_page.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../redirect_to_auth.dart';



class AddScreen extends StatefulWidget {
  AddScreen({Key key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen>
    with RouteAware, RouteObserverMixin {
  int _page = 0;
  int _action;
  ScrollController _scrollController = ScrollController();
  bool isLoading;
  bool imageshow = true;
  Locale currentLang;
  List<CityModel> _cities;
  var user;

  @override
  void initState() {
    isLoading = true;
    super.initState();
    getCurrentLang();

    Res.titleStream.add('إضافة إعلان');
    _scrollController.addListener(_scrollListener);
  }

  getCurrentLang() async {
    getLocale().then((locale) {
      setState(() {
        currentLang = locale;
        getData();
      });
    });
  }

  getData() async {
    final futures = await Future.wait([
      ProductsWebService().getCategories(currentLang.toString()),
      AddressesWebService().getRegions(),
      // ProductsWebService().getRealEstateTypes(currentLang.toString()),
      ProductsWebService().getServicesCategories(currentLang.toString()),
      AdvertisesWebService().getCities(),
    ]);
    setState(() {
      isLoading = false;
    });
    Res.catgories = futures[0];
    Res.regions = futures[1];
    // Res.realEstateTypes = futures[2];
    Res.servicesCategories = futures[2];

    _cities = futures[3] ;

    /*for (RegionModel region in Res.regions) {
      region.cities = await AddressesWebService().getCities(region.id);
    }*/
    final prefs = await SharedPreferences.getInstance();
    user = prefs.getString(('user'));
    print('user $user');
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
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  @override
  void didPopNext() {
    Res.titleStream.add('إضافة إعلان');
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
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
          title: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainScreen(

                      )
                  ));
            },
            child: Image.asset(
              'assets/logo.min.png',
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),

      body:WillPopScope(
      onWillPop: () {
        if (_page > 0) {
          setState(() {
            _page = 0;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: !isLoading
          ? Res.USER != null
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                  _action = 0;
                                  imageshow = false;

                                }),
                                child: Container(
                                  height: 140.h ,
                                 width: 220.w,
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      color: _action == 0
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/new_ad_property.svg',
                                        width: 48.w,
                                        color: _action == 0
                                            ? Colors.white
                                            : const Color(0XFF4d4d4d),
                                      ),
                                      Text(
                                        Languages.of(context).realEstate,
                                        style: GoogleFonts.cairo(
                                          color: _action == 0
                                              ? Colors.white
                                              : const Color(0XFF4d4d4d),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _action = 1;
                                  imageshow = false;
                                }),
                                child: Container(
                                  height: 140.h ,
                                  width: 220.w,
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      color: _action == 1
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/new_ad_services.svg',
                                        width: 48.w,
                                        color: _action == 1
                                            ? Colors.white
                                            : const Color(0XFF4d4d4d),
                                      ),
                                      Text(
                                        Languages.of(context).services,
                                        style: GoogleFonts.cairo(
                                          color: _action == 1
                                              ? Colors.white
                                              : const Color(0XFF4d4d4d),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50.h,
                        ),
                        imageshow == true ?Image.asset('assets/logo_add.jpeg'):Center(),
                        if (_action == 0) RealEstatePage(),
                        if (_action == 1) ServicePage(),
                      ],
                    ),
                  ),
                )
              : RedirectToAuth(
                  destination: 'ads',
                )
          : Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Color(0xffd6d6d6),size: 100.sp,
              ),
            ),
      )
    );
  }
}
