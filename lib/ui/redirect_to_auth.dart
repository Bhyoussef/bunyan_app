import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/ui/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RedirectToAuth extends StatefulWidget {
  final String destination;
  RedirectToAuth({Key key, this.destination}) : super(key: key);

  @override
  _RedirectToAuthState createState() => _RedirectToAuthState();
}

class _RedirectToAuthState extends State<RedirectToAuth> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.initState();
  }

  redirect() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            destination: widget.destination,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.min.png',
              width: MediaQuery.of(context).size.width * 0.4,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                Languages.of(context).redirectToAuthMessage,
                style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15),
            MaterialButton(
              height: 45,
              onPressed: redirect,
              child: Text(
                Languages.of(context).loginSignIn,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              color: Colors.black,
              mouseCursor: MouseCursor.defer,
              textColor: Colors.white,
              minWidth: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
