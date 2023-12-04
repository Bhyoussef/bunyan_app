import 'dart:io';

import 'package:bunyan/localization/language/languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatefulWidget {
  UpdateScreen({Key key}) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: .2.sw),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text(Languages.of(context).updateRequired, style: GoogleFonts.cairo(color: Colors.black, fontSize: 40.sp), softWrap: true, textAlign: TextAlign.center,),
              SizedBox(height: 60.h,),
              MaterialButton(onPressed: () =>
                launch(Platform.isIOS ? 'https://apps.apple.com/tt/app/bunyan/id1589752170' :
                'https://play.google.com/store/apps/details?id=com.bunyan.bunyan'),
                child: Text(
                  Languages.of(context).updateNow,
                  style: TextStyle(
                      fontSize: 28.sp, fontWeight: FontWeight.w900),
                ),
                color: Colors.black,
                mouseCursor: MouseCursor.defer,
                textColor: Colors.white,
                minWidth: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}