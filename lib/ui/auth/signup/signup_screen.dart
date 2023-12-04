import 'dart:convert';
import 'dart:io';

import 'package:bunyan/exceptions/signup_failed.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/auth.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/home/home_screen.dart';
import 'package:bunyan/ui/main/custom_app_bar.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mail_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _mailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwdController = TextEditingController();
  final _rPasswdController = TextEditingController();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwdFocus = FocusNode();
  final _rPasswdFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  File _photo;

  bool _isRequesting = false;
  bool _showPasswd = false;
  bool _termsAccepted = false;
  bool _showTermsAcceptedError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          Res.USER != null
              ? Languages.of(context).editprofile
              : Languages.of(context).signUp,
          style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      // appBar: CustomAppBar(
      //     height: 50.0,
      //     ctx: context,
      //     showNotif: false,
      //     title: Languages.of(context).signUp),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isRequesting
            ? Center(
                child: CupertinoActivityIndicator(
                radius: 40.sp,
              ))
            : SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 50.h, horizontal: 20.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // InkWell(
                          //   onTap: () async {
                          //     final file = await ImagePicker()
                          //         .getImage(source: ImageSource.gallery);
                          //     if (file != null)
                          //       setState(() {
                          //         _photo = File(file.path);
                          //       });
                          //   },
                          //   // child: Column(
                          //   //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   //   children: [
                          //   //     if (_photo != null)
                          //   //       ClipRRect(
                          //   //         borderRadius: BorderRadius.circular(5000.0),
                          //   //         child: Image.file(
                          //   //           _photo,
                          //   //           width: 100.0,
                          //   //           height: 100.0,
                          //   //           fit: BoxFit.cover,
                          //   //         ),
                          //   //       )
                          //   //     else
                          //   //       Container(
                          //   //         width: 100.0,
                          //   //         height: 100.0,
                          //   //         decoration: BoxDecoration(
                          //   //           //border: Border.all(color: Colors.grey, width: 2.sp),
                          //   //           color: Colors.grey,
                          //   //           shape: BoxShape.circle,
                          //   //         ),
                          //   //         padding: EdgeInsets.all(40.sp),
                          //   //         // child: Icon(
                          //   //         //   Icons.person,
                          //   //         //   color: Colors.white,
                          //   //         //   size: 50.0,
                          //   //         // ),
                          //   //       ),
                          //   //     // Text(
                          //   //     //   Languages.of(context).registerPhoto,
                          //   //     //   style: GoogleFonts.cairo(
                          //   //     //       fontSize: 26.sp,
                          //   //     //       fontWeight: FontWeight.w600),
                          //   //     // ),
                          //   //   ],
                          //   // ),
                          // ),

                          SizedBox(
                            height: 60.h,
                          ),

                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _mailController,
                            textDirection: TextDirection.ltr,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _nameFocus.requestFocus(),
                            validator: (txt) => txt.isValidEmail()
                                ? null
                                : Languages.of(context).correctemail,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                              labelText: Languages.of(context).email,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 20.h, horizontal: 15.w),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),

                          SizedBox(
                            height: 20.h,
                          ),

                          //emp phone
                          Flexible(
                            child: TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              validator: (txt) => txt.length >= 3
                                  ? null
                                  : Languages.of(context).enterfullname,
                              onFieldSubmitted: (_) =>
                                  _phoneFocus.requestFocus(),
                              textCapitalization: TextCapitalization.words,
                              focusNode: _nameFocus,
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                                labelText: Languages.of(context).userName,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 15.w),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 20.h,
                          ),

                          //emp phone
                          Flexible(
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _phoneController,
                              textInputAction: TextInputAction.next,
                              focusNode: _phoneFocus,
                              validator: (txt) => txt.length < 6
                                  ? Languages.of(context).enterphone
                                  : null,
                              onFieldSubmitted: (_) =>
                                  _passwdFocus.requestFocus(),
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                                labelText: Languages.of(context).mobileNumber,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 15.w),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 20.h,
                          ),

                          //passwd
                          Flexible(
                            child: TextFormField(
                              obscureText: !_showPasswd,
                              controller: _passwdController,
                              textInputAction: TextInputAction.next,
                              validator: (txt) =>
                                  txt.length < 6 || txt.length > 16
                                      ? Languages.of(context)
                                          .registerPasswordValidator
                                      : null,
                              onFieldSubmitted: (_) =>
                                  _rPasswdFocus.requestFocus(),
                              focusNode: _passwdFocus,
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                                labelText: Languages.of(context).loginPassword,
                                isDense: true,
                                suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _showPasswd = !_showPasswd;
                                      });
                                    },
                                    child: Icon(!_showPasswd
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 15.w),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 20.h,
                          ),

                          //rPasswd
                          Flexible(
                            child: TextFormField(
                              controller: _rPasswdController,
                              textInputAction: TextInputAction.go,
                              obscureText: !_showPasswd,
                              focusNode: _rPasswdFocus,
                              validator: (txt) => txt == _passwdController.text
                                  ? null
                                  : Languages.of(context)
                                      .registerPasswordValidator,
                              onFieldSubmitted: (_) => _signup(),
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                                labelText:
                                    Languages.of(context).confirmPassword,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 15.w),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 20.h,
                          ),

                          if (Res.USER == null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        activeColor: Colors.black,
                                        onChanged: (bool value) {
                                          setState(() {
                                            _termsAccepted = value;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: _termsAccepted,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Text(
                                        Languages.of(context).registerTerms,
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_showTermsAcceptedError)
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        Languages.of(context).pleaseagree,
                                        style: GoogleFonts.cairo(
                                            color: Colors.red, fontSize: 20.sp),
                                      ),
                                    )
                                ],
                              ),
                            ),

                          SizedBox(
                            height: 50.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: MaterialButton(
                              height: 45,
                              onPressed: _signup,
                              child: !_isRequesting
                                  ? Text(
                                      Languages.of(context).register,
                                      style: TextStyle(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w900),
                                    )
                                  : const SizedBox(
                                      height: 32,
                                      width: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                              color: Colors.black,
                              mouseCursor: MouseCursor.defer,
                              textColor: Colors.white,
                              minWidth: double.infinity,
                            ),
                          ),
                          if (Res.USER == null)
                            TextButton(
                              child: Text(
                                Languages.of(context).loginAsGuest,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                primary: Colors.blue,
                                onSurface: Colors.grey,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                        ],
                      ),
                    )),
              ),
      ),
    );
  }

  Future<void> _signup() async {
   /* setState(() {
      _showTermsAcceptedError = false;
      _showPasswd = false;
    });
    print('_termsAccepted $_termsAccepted');
    if (!_termsAccepted && Res.USER == null)
      setState(() {
        _showTermsAcceptedError = true;
      });
    if (_formKey.currentState.validate() && (_termsAccepted || Res.USER != null)) {
      setState(() {
        _isRequesting = true;
      });
      try {
        final user = await UsersWebService().signup(AuthModel(
            name: _nameController.text,
            mail: _mailController.text,
            phone: _phoneController.text,
            passwd: _passwdController.text,
            confirm_passwd: _rPasswdController.text,
            type: 'Individual'));
        print(user);
        Res.USER = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                showVerifMail: false,
              ),
            ),
            (route) => false);
      } catch (e) {
        print('error isssss $e');
        if (e is SignupFailedException)
          _showDialog(error: e.cause);
        else
          _showDialog(error: Languages.of(context).tryAgain);
      } finally {
        setState(() {
          _isRequesting = false;
        });
      }
    }*/
  }

  void _showDialog({String error}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(Languages.of(context).wrong),
              content: Text(error),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(Languages.of(context).agreeon))
              ],
            ));
  }
}
