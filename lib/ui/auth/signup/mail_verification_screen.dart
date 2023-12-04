import 'dart:async';

import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MailVerificationScreen extends StatefulWidget {
  MailVerificationScreen({Key key, bool showVerifMail}) : super(key: key);

  @override
  _MailVerificationScreenState createState() => _MailVerificationScreenState();
}

class _MailVerificationScreenState extends State<MailVerificationScreen> {
  StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  bool _isLoading = false;

  @override
  void initState() {
    UsersWebService().chekcodepin().then((code) {
      setState(() {});
    });
  }

  getMail() async {
    final futures = await Future.wait([UsersWebService().chekcodepin()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.00),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Languages.of(context).verification,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () {
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Container(
          width: 1.sw,
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
          child: IndexedStack(
            index: _isLoading ? 1 : 0,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Languages.of(context).activateacount,
                    style: GoogleFonts.cairo(
                        fontSize: 40.sp, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    Languages.of(context).pleasegoemail,
                    style: GoogleFonts.cairo(
                        fontSize: 25.sp, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: PinCodeTextField(
                      appContext: context,
                      length: 4,
                      textInputAction: TextInputAction.go,
                      //onChanged: _checkCode,
                      keyboardType: TextInputType.number,

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      obscureText: false,
                      cursorColor: Colors.black,
                      autoFocus: true,

                      onSubmitted: _checkCode,
                      onCompleted: _checkCode,
                      autoDisposeControllers: true,
                      errorAnimationController: _errorController,
                      cursorWidth: .0,
                      textStyle: GoogleFonts.cairo(fontSize: 20.sp),
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          activeColor: Colors.grey,
                          selectedColor: Colors.grey,
                          activeFillColor: Colors.black87,
                          inactiveFillColor: Colors.grey,
                          inactiveColor: Colors.grey),
                      onChanged: (String value) {},
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      Languages.of(context).nopin,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          Languages.of(context).resent,
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )),
                  ]),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [MaterialButton()],
                  )
                ],
              ),
              Positioned.fill(
                  child: Center(
                child: Wrap(
                  children: [
                    SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: CircularProgressIndicator())
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkCode(String code) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 10));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  showVerifMail: false,
                )),
        (route) => false);
  }
}
