import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bunyan/exceptions/signup_failed.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/auth.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/home/home_screen.dart';
import 'package:bunyan/ui/main/custom_app_bar.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/onBoardingScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/product.dart';
import '../../../tools/webservices/products.dart';
import 'mail_verification_screen.dart';

class SignupScreenEntreprise extends StatefulWidget {
  SignupScreenEntreprise({Key key, this.isCompany = false}) : super(key: key);

  final bool isCompany;

  @override
  _SignupScreenEntrepriseState createState() => _SignupScreenEntrepriseState();
}

class _SignupScreenEntrepriseState extends State<SignupScreenEntreprise> {
  final _mailController = TextEditingController();
  final _nameController = TextEditingController();
  final _nameCompanyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwdController = TextEditingController();
  final _rPasswdController = TextEditingController();
  final _oldPasswdController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwdFocus = FocusNode();
  final _rPasswdFocus = FocusNode();
  final _nameCompanyFocus = FocusNode();

  final _signFormKey = GlobalKey<FormState>();
  final _passwdFormKey = GlobalKey<FormState>();

  File _photo;

  bool _isRequesting = false;
  bool _showPasswd = false;
  bool _termsAccepted = false;
  bool _showTermsAcceptedError = false;


  @override
  void initState() {
    super.initState();
    if (Res.USER != null) {
      _mailController.text = Res.USER.email;
      _nameCompanyController.text = Res.USER.companyName;
      _nameController.text = Res.USER.name;
      _phoneController.text = Res.USER.phone;
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 25.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Res.USER == null
              ? Languages.of(context).signUp
              : Languages.of(context).editprofile,
          style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isRequesting
            ? Center(
                child: CupertinoActivityIndicator(
                radius: 40.sp,
              ))
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 50.h, horizontal: 20.w),
                  child: Column(
                    children: [
                      Form(
                        key: _signFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 60.h,
                            ),

                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _mailController,
                              enabled: Res.USER == null,
                              onSaved: (val) {
                                if (Res.USER != null) {
                                  Res.USER.email = val;
                                }
                              },
                              textDirection: TextDirection.ltr,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _nameFocus.requestFocus(),
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
                            Flexible(
                              child: TextFormField(
                                controller: _nameController,
                                onSaved: (val) {
                                  if (Res.USER != null) {
                                    Res.USER.name = val;
                                  }
                                },
                                textInputAction: TextInputAction.next,
                                validator: (txt) => txt.length >= 3
                                    ? null
                                    : Languages.of(context).enterfullname,
                                onFieldSubmitted: (_) =>
                                    _nameCompanyFocus.requestFocus(),
                                textCapitalization: TextCapitalization.words,
                                focusNode: _nameFocus,
                                decoration: InputDecoration(
                                  labelStyle:
                                      GoogleFonts.cairo(fontSize: 26.sp),
                                  labelText: Languages.of(context).userName,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20.h, horizontal: 15.w),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),

                            //cmp name
                            if (widget.isCompany) ...[
                              Flexible(
                                child: TextFormField(
                                  controller: _nameCompanyController,
                                  onSaved: (val) {
                                    if (Res.USER != null) {
                                      Res.USER.companyName = val;
                                    }
                                  },
                                  textInputAction: TextInputAction.next,
                                  validator: (txt) => txt.length >= 3
                                      ? null
                                      : Languages.of(context).enterfullname,
                                  onFieldSubmitted: (_) =>
                                      _phoneFocus.requestFocus(),
                                  textCapitalization: TextCapitalization.words,
                                  focusNode: _nameCompanyFocus,
                                  decoration: InputDecoration(
                                    labelStyle:
                                        GoogleFonts.cairo(fontSize: 26.sp),
                                    labelText: 'Company Name',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20.h, horizontal: 15.w),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.w,
                              ),
                            ],

                            //phone
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _phoneController,
                                textInputAction: Res.USER == null
                                    ? TextInputAction.next
                                    : TextInputAction.go,
                                focusNode: _phoneFocus,
                                onSaved: (val) {
                                  if (Res.USER != null) {
                                    Res.USER.phone = val;
                                  }
                                },
                                validator: (txt) => txt.length < 6
                                    ? Languages.of(context).enterphone
                                    : null,
                                onFieldSubmitted: (_) => Res.USER == null
                                    ? _passwdFocus.requestFocus()
                                    : null,
                                decoration: InputDecoration(
                                  labelStyle:
                                      GoogleFonts.cairo(fontSize: 26.sp),
                                  labelText: Languages.of(context).mobileNumber,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20.h, horizontal: 15.w),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 20.h,
                            ),

                            //passwd
                            if (Res.USER == null) ...[
                              Flexible(
                                child: TextFormField(
                                  obscureText: !_showPasswd,
                                  controller: _passwdController,
                                  onSaved: (val) {
                                    if (Res.USER != null) {
                                      Res.USER.password = val;
                                    }
                                  },
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
                                    labelStyle:
                                        GoogleFonts.cairo(fontSize: 26.sp),
                                    labelText:
                                        Languages.of(context).loginPassword,
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
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
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
                                  validator: (txt) =>
                                      txt == _passwdController.text
                                          ? null
                                          : Languages.of(context)
                                              .registerPasswordValidator,
                                  decoration: InputDecoration(
                                    labelStyle:
                                        GoogleFonts.cairo(fontSize: 26.sp),
                                    labelText:
                                        Languages.of(context).confirmPassword,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20.h, horizontal: 15.w),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                            ],

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
                                        GestureDetector(
                                          onTap: () => launch(
                                              'https://bunyan.qa/privacy-policy'),
                                          child: Text(
                                            Languages.of(context).registerTerms,
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 26.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_showTermsAcceptedError)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          Languages.of(context).pleaseagree,
                                          style: GoogleFonts.cairo(
                                              color: Colors.red,
                                              fontSize: 20.sp),
                                        ),
                                      )
                                  ],
                                ),
                              ),

                            SizedBox(
                              height: 50.h,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: MaterialButton(
                                height: 45,
                                onPressed: _signup,
                                child: !_isRequesting
                                    ? Text(
                                        Res.USER == null
                                            ? Languages.of(context).register
                                            : Languages.of(context).editprofile,
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
                      ),
                      if (Res.USER != null)
                        Form(
                          key: _passwdFormKey,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 80.h,
                                ),

                                //old passwd
                                Flexible(
                                  child: TextFormField(
                                    obscureText: !_showPasswd,
                                    controller: _oldPasswdController,
                                    onSaved: (val) {
                                      Res.USER.oldPAsswd = val;
                                    },
                                    textInputAction: TextInputAction.next,
                                    validator: (txt) =>
                                        txt.length < 6 || txt.length > 16
                                            ? Languages.of(context)
                                                .registerPasswordValidator
                                            : null,
                                    onFieldSubmitted: (_) =>
                                        _passwdFocus.requestFocus(),
                                    decoration: InputDecoration(
                                      labelStyle:
                                          GoogleFonts.cairo(fontSize: 26.sp),
                                      labelText:
                                          Languages.of(context).oldPassword,
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
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                ),

                                //new passwd
                                Flexible(
                                  child: TextFormField(
                                    obscureText: !_showPasswd,
                                    controller: _passwdController,
                                    onSaved: (val) {
                                      Res.USER.password = val;
                                    },
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
                                      labelStyle:
                                          GoogleFonts.cairo(fontSize: 26.sp),
                                      labelText:
                                          Languages.of(context).newpassword,
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
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
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
                                    validator: (txt) =>
                                        txt == _passwdController.text
                                            ? null
                                            : Languages.of(context)
                                                .registerPasswordValidator,
                                    decoration: InputDecoration(
                                      labelStyle:
                                          GoogleFonts.cairo(fontSize: 26.sp),
                                      labelText:
                                          Languages.of(context).confirmPassword,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 20.h, horizontal: 15.w),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50.h,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: MaterialButton(
                                    height: 45,
                                    onPressed: _resetPasswd,
                                    child: !_isRequesting
                                        ? Text(
                                            Languages.of(context).resetPassword,
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



                                SizedBox(
                                  height: 90.h,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: MaterialButton(
                                    height: 45,
                                    onPressed: _promptRemoveAccount,
                                    child: !_isRequesting
                                        ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete, color: Colors.white,),
                                            Text(
                                      Languages.of(context).deleteAccount,
                                      style: TextStyle(
                                              fontSize: 26.sp,
                                              fontWeight: FontWeight.w900),
                                    ),
                                          ],
                                        )
                                        : const SizedBox(
                                      height: 32,
                                      width: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    color: Colors.red,
                                    mouseCursor: MouseCursor.defer,
                                    textColor: Colors.white,
                                    minWidth: double.infinity,
                                  ),
                                ),
                              ]),
                        )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _signup() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _showTermsAcceptedError = false;
      _showPasswd = false;
    });
    debugPrint('_termsAccepted $_termsAccepted');
    if ((!_termsAccepted && Res.USER == null)) {
      setState(() {
        _showTermsAcceptedError = true;
      });
    }

    if (_signFormKey.currentState.validate() &&
        (_termsAccepted || Res.USER != null)) {
      _signFormKey.currentState.save();
      setState(() {
        _isRequesting = true;
      });
      try {
        if (Res.USER == null) {
          await UsersWebService().signup(PersonModel(
              name: _nameController.text,
              companyName: _nameCompanyController.text,
              email: _mailController.text,
              phone: _phoneController.text,
              password: _passwdController.text));
          _showDialog(
              error: Languages.of(context).registered,
              onTap: () => Navigator.pop(context));
        } else {
          await UsersWebService().updateUser(Res.USER);
          _showDialog(error: Languages.of(context).editPhotoProfileSuccess);
        }
      } catch (e) {
        if (e is SignupFailedException)
          _showDialog(error: e.cause);
        else if (e is DioError && e.response.statusCode == 422) {
          _showDialog(
              error: Map.of(Map.of(e.response.data)['errors'])
                  .values
                  .toList()
                  .map((e) => e.toString())
                  .toList()
                  .toString()
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .replaceAll(',', '\n'));
        } else
          _showDialog(error: Languages.of(context).tryAgain);
      } finally {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  void _showDialog({String error, VoidCallback onTap}) {
    showDialog(
        barrierDismissible: onTap == null,
        context: context,
        builder: (context) => AlertDialog(
              title: Text(Languages.of(context).wrong),
              content: Text(error),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onTap != null) onTap();
                    },
                    child: Text(Languages.of(context).agreeon))
              ],
            ));
  }

  Future<void> _resetPasswd() async {
    if (_passwdFormKey.currentState.validate()) {
      setState(() {
        _isRequesting = true;
      });
      _passwdFormKey.currentState.save();
      final response = await UsersWebService().updatePassword();
      _showDialog(
          error: response
              ? Languages.of(context).editPhotoProfileSuccess
              : Languages.of(context).wrongPassword);
      setState(() {
        _isRequesting = false;
      });
    }
  }

  void _promptRemoveAccount() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(Languages.of(context).deleteAccount),
        content: Text(Languages.of(context).deleteAccountBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(Languages.of(context).no)),
          TextButton(onPressed: () => _removeAccount(context), child: Text(Languages.of(context).yes)),
        ],
      );
    });
  }

  Future<void> _removeAccount(BuildContext ctx) async {
    try {
      await UsersWebService().deleteAccount();
    } catch (e) {}
    Navigator.pop(ctx);
    _logOut();
  }

  _logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    setState(() {
      Res.USER = null;
      Res.token = null;
    });
    await UsersWebService().logout();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => OnBoardingScreen()), (_) => false);
  }
}
