import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:bunyan/ui/onBoardingScreen.dart';
import 'package:bunyan/ui/profile/user_profile.dart';
import 'package:bunyan/ui/real_estates/real_estates_screen.dart';
import 'package:bunyan/ui/services/services_screen.dart';
import 'package:bunyan/ui/splash_screen.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'localization/locale_constant.dart';
import 'localization/localizations_delegate.dart';
import 'package:timeago/timeago.dart' as timeago;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await AppTrackingTransparency.requestTrackingAuthorization();

  if (kDebugMode)
    Wakelock.enable();
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());

  runApp(RouteObserverProvider(child: MyApp()));
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  bool isLoading = true;
  String isBoadrdingScreen;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    isBoadrdingScreen = prefs.getString('isBoadrdingScreen');
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
        isLoading = false;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //GestureBinding.instance.resamplingEnabled = true;
    const MaterialColor kToDark = MaterialColor(
      0xff000000,
      <int, Color>{
        50: Color(0xff1a1a1a), //10%
        100: Color(0xff333333), //20%
        200: Color(0xff4d4d4d), //30%
        300: Color(0xff666666), //40%
        400: Color(0xff808080), //50%
        500: Color(0xff808080), //60%
        600: Color(0xffb3b3b3), //70%
        700: Color(0xffcccccc), //80%
        800: Color(0xffe6e6e6), //90%
        900: Color(0xff000000), //100%
      },
    );

    return ScreenUtilInit(
      designSize: Size(640, 1136),
      //allowFontScaling: true,
      builder: () => !isLoading
          ? StyledToast(
        locale: _locale,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (BuildContext context) {
                return CityBasket();
              },
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) {
                return ServiceProvider();
              },
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) {
                return SelectedProfileProvider();
              },
            ),

          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bunyan',
            theme: ThemeData(
              fontFamily: GoogleFonts.cairo().fontFamily,
              primarySwatch: kToDark,
              primaryColor: Colors.black,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
            ),
            home: DoubleBack(
                message: "",
                child: isBoadrdingScreen != null
                    ? SplashScreen()
                    : OnBoardingScreen()),
            builder: (context, widget) {
              return Builder(builder: (context) {
                return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaleFactor: 1.0),
                    child: widget);
              });
            },
            locale: _locale,
            supportedLocales: [
              Locale('en', ''),
              Locale('ar', ''),
            ],
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale?.languageCode == locale?.languageCode &&
                    supportedLocale?.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales?.first;
            },
          ),
        ),
      )
          : Container(),
    );
  }


}
