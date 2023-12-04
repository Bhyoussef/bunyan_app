import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  void selectLang(String lang) async {
    changeLanguage(context, lang);
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('isBoadrdingScreen', 'done');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              width: 150,
              image: AssetImage('assets/logo.min.png'),
              fit: BoxFit.cover,
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                selectLang('ar');
              },
              child: Container(
                width: size.width * 0.7,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.black,
                ),
                child: Text(
                  'العربية',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(height: 35),
            GestureDetector(
              onTap: () {
                selectLang('en');
              },
              child: Container(
                width: size.width * 0.7,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.black,
                ),
                child: Text(
                  'English',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
