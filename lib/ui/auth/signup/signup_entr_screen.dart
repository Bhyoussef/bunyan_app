import 'dart:convert';
import 'dart:io';

import 'package:bunyan/exceptions/signup_failed.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/auth.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/addresses.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/main/custom_app_bar.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupEntrScreen extends StatefulWidget {
  SignupEntrScreen({Key key}) : super(key: key);

  @override
  _SignupEntrScreenState createState() => _SignupEntrScreenState();
}

class _SignupEntrScreenState extends State<SignupEntrScreen>
    with TickerProviderStateMixin {
  int _step = 1;
  PageController _pageController;
  int _moreInfoTextLength = 0;
  bool isLoading;
  RegionModel _selectedCity;
  File _entrPhoto;
  File _profilePicture;
  bool _isRequesting = false;
  final _crNumberController = TextEditingController();
  final _empNameController = TextEditingController();
  final _empPhoneController = TextEditingController();
  final _empPostController = TextEditingController();
  final _passwdController = TextEditingController();
  final _rPasswdController = TextEditingController();
  final _entrNameController = TextEditingController();
  final _entrMailController = TextEditingController();
  final _entrBuildNumberController = TextEditingController();
  final _entrStreetNumberController = TextEditingController();
  final _entrPhoneController = TextEditingController();
  final _entrDescController = TextEditingController();
  final _empMailController = TextEditingController();

  EnterpriseModel _enterprise;

  @override
  void initState() {
    isLoading = true;
    _pageController =
        PageController(initialPage: 0, keepPage: true, viewportFraction: 1.0);
    getRegion();
    super.initState();
  }

  getRegion() {
    AddressesWebService().getRegions().then((value) => {
          Res.regions = value,
          setState(() {
            isLoading = false;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    print(_enterprise == null);
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
          Languages.of(context).signUp,
          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          if (_step > 1) {
            _pageController.previousPage(
                duration: Duration(milliseconds: 200), curve: Curves.easeOut);
            setState(() {
              _step--;
            });
            return false;
          }
          return true;
        },
        child: Container(
            child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: .06.sh,
                  ),

                  //stepper
                  _stepper(),

                  SizedBox(
                    height: 50.h,
                  ),
                  AnimatedContainer(
                    height: _step == 1
                        ? .11.sh
                        : _step == 2
                            ? 1.30.sh
                            : .52.sh,
                    width: 1.sw,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: PageView(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      children: [
                        _crNumberInput(),
                        _personalInfo(),
                        _profilePictures(),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 40),
                    child: MaterialButton(
                      height: 45,
                      onPressed: () {
                        if (_step == 1) {
                          _checkCrNumber();
                        } else if (_step < 3) {
                          _pageController.nextPage(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOut);
                          setState(() {
                            _step++;
                          });
                        } else
                          _signup();
                      },
                      child: !_isRequesting
                          ? Text(
                              _step < 3
                                  ? Languages.of(context).next
                                  : Languages.of(context).register,
                              style: TextStyle(
                                  fontSize: 26.sp, fontWeight: FontWeight.w900),
                            )
                          : const SizedBox(
                              height: 24,
                              width: 24,
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

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        Languages.of(context).loginSignIn,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _crNumberInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        validator:
            RequiredValidator(errorText: Languages.of(context).emptyValidator),
        controller: _crNumberController,
        keyboardType:
            TextInputType.numberWithOptions(signed: false, decimal: false),
        decoration: InputDecoration(
          labelText: Languages.of(context).registerCRnumber,
          labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          errorBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          disabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          focusedErrorBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
  }

  Widget _personalInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: _personalForm()),
          SizedBox(
            height: 50.h,
          ),
          _enterpriseForm()
        ],
      ),
    );
  }

  Widget _personalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Languages.of(context).registerEmployeDetails,
          style: GoogleFonts.cairo(
            fontSize: 25.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        //emp infos
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //emp name
              TextFormField(
                validator: RequiredValidator(
                    errorText: Languages.of(context).emptyValidator),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                controller: _empNameController,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                  labelText: Languages.of(context).registerEmployeName,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
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

              TextFormField(
                validator: MultiValidator([
                  RequiredValidator(
                      errorText: Languages.of(context).emptyValidator),
                  EmailValidator(
                      errorText: Languages.of(context).emptyValidator)
                ]),
                keyboardType: TextInputType.emailAddress,
                controller: _empMailController,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                  labelText: Languages.of(context).email,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //emp phone
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      validator: RequiredValidator(
                          errorText: Languages.of(context).emptyValidator),
                      controller: _empPhoneController,
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
                    width: 50.w,
                  ),

                  //emp post
                  Flexible(
                    child: TextFormField(
                      validator: RequiredValidator(
                          errorText: Languages.of(context).emptyValidator),
                      keyboardType: TextInputType.text,
                      controller: _empPostController,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                        labelText:
                            Languages.of(context).registerEmployePosition,
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
                ],
              ),

              SizedBox(
                height: 20.h,
              ),

              //passwd
              Row(
                children: [
                  //passwd
                  Flexible(
                    child: TextFormField(
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: Languages.of(context).emptyValidator),
                        MinLengthValidator(6,
                            errorText: Languages.of(context)
                                .registerPasswordValidator),
                        MaxLengthValidator(16,
                            errorText:
                                Languages.of(context).registerPasswordValidator)
                      ]),
                      obscureText: true,
                      controller: _passwdController,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                        labelText: Languages.of(context).loginPassword,
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
                    width: 50.w,
                  ),

                  //rPasswd
                  Flexible(
                    child: TextFormField(
                      validator: (txt) => txt == _passwdController.text
                          ? null
                          : Languages.of(context).emptyValidator,
                      obscureText: true,
                      controller: _rPasswdController,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                        labelText: Languages.of(context).confirmPassword,
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
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _enterpriseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Languages.of(context).registerCompanyDetails,
          style:
              GoogleFonts.cairo(fontSize: 25.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20.h,
        ),
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //ste name
              TextFormField(
                enabled: _enterprise == null,
                validator: RequiredValidator(
                    errorText: Languages.of(context).emptyValidator),
                controller: _entrNameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.cairo(fontSize: 26.sp,
                    color: _enterprise != null ? Colors.black54 : Colors.black),
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                  labelText: Languages.of(context).registerCompanyName,
                  enabled: _enterprise == null,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
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

              //ste mail
              Flexible(
                child: TextFormField(
                  enabled: _enterprise == null,
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                      color:
                          _enterprise != null ? Colors.black54 : Colors.black),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: Languages.of(context).emptyValidator),
                    EmailValidator(
                        errorText: Languages.of(context).emptyValidator)
                  ]),
                  keyboardType: TextInputType.emailAddress,
                  controller: _entrMailController,
                  decoration: InputDecoration(
                    labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                    labelText: Languages.of(context).email,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //builbing number
                  Flexible(
                    child: TextFormField(
                      enabled: _enterprise == null,
                      style: GoogleFonts.cairo(fontSize: 26.sp,
                          color: _enterprise != null
                              ? Colors.black54
                              : Colors.black),
                      validator: RequiredValidator(
                          errorText: Languages.of(context).emptyValidator),
                      controller: _entrBuildNumberController,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                        labelText: Languages.of(context).buildingNumber,
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
                    width: 50.w,
                  ),

                  //street name
                  !isLoading
                      ? Flexible(
                          child: TextFormField(
                            enabled: _enterprise == null,
                            style: GoogleFonts.cairo(
                              fontSize: 26.sp,
                                color: _enterprise != null
                                    ? Colors.black54
                                    : Colors.black),
                            validator: RequiredValidator(
                                errorText:
                                    Languages.of(context).emptyValidator),
                            keyboardType: TextInputType.text,
                            controller: _entrStreetNumberController,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                              labelText: Languages.of(context).streetNumber,
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
                        )
                      : Container(),
                ],
              ),

              SizedBox(
                height: 20.h,
              ),

              !isLoading
                  ? DropdownButtonFormField(
                      items: Res.regions
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(Languages.of(context).labelSelectLanguage ==
                                  "English"
                                  ? e.name
                                  : e.nameAr),
                              value: e,
                            ),
                          )
                          .toList(),
                      onChanged: _enterprise != null
                          ? null
                          : (e) {
                              setState(() {
                                _selectedCity = e;
                              });
                            },
                      isDense: true,
                      value: _selectedCity,
                      validator: (e) => e != null
                          ? null
                          : Languages.of(context).enterLabel +
                              ' ' +
                              Languages.of(context).zone,
                      hint: Text(
                        Languages.of(context).zone,
                        style: GoogleFonts.cairo(fontSize: 26.sp),
                      ),
                      style: GoogleFonts.cairo(
                        fontSize: 26.sp,
                          color: _enterprise != null
                              ? Colors.black54
                              : Colors.black),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 20.h, horizontal: 15.w),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(),
                      ),
                    )
                  : Container(),

              SizedBox(
                height: 20.h,
              ),

              //ste phone
              Flexible(
                child: TextFormField(
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                      color:
                          _enterprise != null ? Colors.black54 : Colors.black),
                  enabled: _enterprise == null,
                  validator: RequiredValidator(
                      errorText: Languages.of(context).emptyValidator),
                  keyboardType: TextInputType.phone,
                  controller: _entrPhoneController,
                  decoration: InputDecoration(
                    labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                    labelText: Languages.of(context).mobileNumber,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
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
                height: 15.h,
              ),

              TextFormField(
                enabled: _enterprise == null,
                style: GoogleFonts.cairo(
                  fontSize: 26.sp,
                    color: _enterprise != null ? Colors.black54 : Colors.black),
                validator: RequiredValidator(
                    errorText: Languages.of(context).emptyValidator),
                minLines: 5,
                maxLines: 5,
                maxLength: 50,
                controller: _entrDescController,
                onChanged: (txt) =>
                    setState(() => _moreInfoTextLength = txt.length),
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                  labelText: Languages.of(context).adDescription,
                  isDense: true,
                  counterText: Languages.of(context).max +
                      ' ${50 - _moreInfoTextLength} ' +
                      Languages.of(context).word,
                  counterStyle: GoogleFonts.cairo(fontSize: 26.sp),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
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

              Flexible(
                  child: SizedBox(
                height: 15.h,
              ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _profilePictures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 1.sw,
          padding: EdgeInsets.symmetric(horizontal: 1.sw),
        ),
        if (_entrPhoto != null)
          InkWell(
              onTap: () async {
                final file =
                    await ImagePicker().getImage(source: ImageSource.gallery);
                if (file != null)
                  setState(() {
                    _entrPhoto = File(file.path);
                  });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5000.0),
                  child: Image.file(
                    _entrPhoto,
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  )))
        else
          InkWell(
            onTap: () async {
              final file =
                  await ImagePicker().getImage(source: ImageSource.gallery);
              if (file != null)
                setState(() {
                  _entrPhoto = File(file.path);
                });
            },
            child: Container(
              decoration: BoxDecoration(
                //border: Border.all(color: Colors.grey, width: 2.sp),
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(40.sp),
              child: Icon(
                Icons.location_city,
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ),
        Text(
          Languages.of(context).registerCompanyLogo,
          style: GoogleFonts.cairo(fontSize: 26.sp),
        ),
        SizedBox(
          height: 100.h,
        ),
        if (_profilePicture != null)
          InkWell(
              onTap: () async {
                final file =
                    await ImagePicker().getImage(source: ImageSource.gallery);
                if (file != null)
                  setState(() {
                    _profilePicture = File(file.path);
                  });
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5000.0),
                  child: Image.file(
                    _profilePicture,
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  )))
        else
          InkWell(
            onTap: () async {
              final file =
                  await ImagePicker().getImage(source: ImageSource.gallery);
              if (file != null)
                setState(() {
                  _profilePicture = File(file.path);
                });
            },
            child: Container(
              decoration: BoxDecoration(
                //border: Border.all(color: Colors.grey, width: 2.sp),
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(40.sp),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ),
        Text(
          Languages.of(context).registerEmployePhoto,
          style: GoogleFonts.cairo(),
        )
      ],
    );
  }

  Widget _stepper() {
    return SizedBox(
      width: 1.sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(25.sp),
                child: Text(
                  '1',
                  style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: .1.sw,
                height: 7.h,
                decoration: BoxDecoration(
                  color: _step > 1 ? Colors.black : Colors.grey.withOpacity(.4),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _step > 1 ? Colors.black : Colors.grey.withOpacity(.4),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(25.sp),
                child: Text(
                  '2',
                  style: GoogleFonts.cairo(
                      color: _step > 1 ? Colors.white : Colors.black,
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: .1.sw,
                height: 7.h,
                decoration: BoxDecoration(
                  color:
                      _step == 3 ? Colors.black : Colors.grey.withOpacity(.4),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color:
                      _step == 3 ? Colors.black : Colors.grey.withOpacity(.4),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(25.sp),
                child: Text(
                  '3',
                  style: GoogleFonts.cairo(
                      color: _step == 3 ? Colors.white : Colors.black,
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            _step == 1
                ? Languages.of(context).registerCRnumber
                : _step == 2
                    ? Languages.of(context).registerDetails
                    : Languages.of(context).registerPhotos,
            style: GoogleFonts.cairo(
                fontSize: 30.sp,
                color: Colors.black,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }

  Future<void> _checkCrNumber() async {
    _enterprise =
        await UsersWebService().checkEnterprise(_crNumberController.text);
    if (_enterprise != null) {
      _entrDescController.text = _enterprise.description;
      _entrPhoneController.text = _enterprise.phone.toString();
      _entrMailController.text = _enterprise.email;
      _entrNameController.text = _enterprise.name;
    }
    setState(() {
      _pageController.nextPage(
          duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      _step++;
    });
  }

  Future<void> _signup() async {
    /*try {
      final user = await UsersWebService().signup(AuthModel(
          phone: _empPhoneController.text,
          mail: _empMailController.text,
          passwd: _passwdController.text,
          name: _empNameController.text,
          crNumber: _crNumberController.text,
          entrAdr: _selectedCity.name,
          entrDesc: _entrDescController.text,
          entrLat: '',
          entrLng: '',
          entrMail: _entrMailController.text,
          entrName: _entrNameController.text,
          entrPhone: _entrPhoneController.text,
          entrPhoto: _entrPhoto,
          profilePicture: _profilePicture));

      print(user);
      Res.USER = user;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user', jsonEncode(Res.USER.toJson()));

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen() *//*MailVerificationScreen()*//*));
    } catch (e) {
      print('error iss  $e');
      if (e is SignupFailedException)
        _showDialog(error: e.cause);
      else
        _showDialog(error: Languages.of(context).tryAgain);
    }finally{
      setState(() {
        _isRequesting=false;
      });
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
