import 'dart:convert';
import 'dart:io';
import 'package:bunyan/exceptions/unauthorized.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/passthrough_home.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/about/about_screen.dart';
import 'package:bunyan/ui/auth/forget_passwd_dialog.dart';
import 'package:bunyan/ui/auth/signup/signup_entr_screen.dart';
import 'package:bunyan/ui/auth/signup/signup_entreprise.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
//import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'signup/signup_screen.dart';
import 'package:bunyan/models/position.dart';

enum SocialMethod { Apple, Facebook, Google }

class LoginScreen extends StatefulWidget {
  final String destination;

  final PassthroughHome passthrough;

  LoginScreen({Key key, this.destination, this.passthrough}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mailController = TextEditingController();
  final _passwdController = TextEditingController();
  final _passwdNode = FocusNode();
  bool _isRequesting = false;
  bool _accepted = true;
  bool _showAcceptError = false;
  PositionModel _position;
  bool _requestingSoacial = false;

  //getCurrentLocation();
  LocationData mycurrentLocation;
  bool _isLoadingLocation = false;

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  getCurrentLocation() async {
    final location = Location();
    mycurrentLocation = await location.getLocation();
    setState(() {
      _position = PositionModel(
          lat: mycurrentLocation.latitude, lng: mycurrentLocation.longitude);
      print('_position ${_position.toJson()}');
      _isLoadingLocation = false;
    });
  }

  void initState() {
    _isLoadingLocation = true;
    getCurrentLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //_isRequesting = false;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            if (_requestingSoacial)
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black26,
                ),
              ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/logo.min.png',
                                width: .3.sw,
                                fit: BoxFit.cover,
                              )),
                          SizedBox(
                            height: 30.h,
                          ),
                          TextFormField(
                            enabled: !_isRequesting,
                            keyboardType: TextInputType.emailAddress,
                            controller: _mailController,
                            textInputAction: TextInputAction.next,
                            validator: (txt) =>
                                txt.isEmpty || !txt.contains('@')
                                    ? Languages.of(context).emptyValidator
                                    : null,
                            onFieldSubmitted: (txt) =>
                                _passwdNode.requestFocus(),
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.cairo(
                                fontSize: 26.sp,
                              ),
                              labelText: Languages.of(context).email,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17.h, horizontal: 15.w),
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
                            height: 30.h,
                          ),
                          TextFormField(
                            enabled: !_isRequesting,
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            validator: (txt) => txt.isEmpty
                                ? Languages.of(context).emptyValidatorPass
                                : null,
                            textDirection: TextDirection.ltr,
                            obscureText: true,
                            controller: _passwdController,
                            textInputAction: TextInputAction.go,
                            onFieldSubmitted: (txt) => _login(),
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.cairo(fontSize: 26.sp),
                              labelText: Languages.of(context).loginPassword,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17.h, horizontal: 15.w),
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
                            children: [
                              InkWell(
                                onTap: _signUp,
                                child: Text(
                                  Languages.of(context).signUp,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _openForgetPasswdDialog,
                                child: Text(
                                  Languages.of(context).loginForgetPwd,
                                  style: GoogleFonts.cairo(
                                      color: Colors.grey,
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                          if (_showAcceptError)
                            Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 18.w),
                                  child: Text(
                                    Languages.of(context).pleaseagree,
                                    style: GoogleFonts.cairo(
                                        color: Colors.red, fontSize: 15.sp),
                                  ),
                                )),
                          SizedBox(height: 50.h),
                          MaterialButton(
                            height: 45,
                            onPressed: _login,
                            child: !_isRequesting
                                ? Text(
                                    Languages.of(context).loginSignIn,
                                    style: TextStyle(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w900),
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
                          SizedBox(height: 10),
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
                            onPressed: () {
                              //addon
                              Res.USER = null;
                              setState(() {
                                _isRequesting = false;
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainScreen(
                                            passthrough: widget.passthrough,
                                          )));
                            },
                          ),
                          /*Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Divider(
                                  thickness: 3.0,
                                  color: Colors.black,
                                )),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Text(
                                    Languages.of(context).or.toUpperCase(),
                                    style:
                                        GoogleFonts.cairo(color: Colors.black),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                  thickness: 3.0,
                                  color: Colors.black,
                                )),
                              ],
                            ),
                          ),
                          if (Platform.isIOS)
                            _socialButton(
                                method: SocialMethod.Apple, onTap: () {})
                          else if (Platform.isAndroid)
                            _socialButton(
                                method: SocialMethod.Google, onTap: () {}),
                          _socialButton(
                              method: SocialMethod.Facebook,
                              onTap: _loginFacebook),*/
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _showAcceptError = false;
    });
    if (_formKey.currentState.validate() && _accepted) {
      setState(() {
        _isRequesting = true;
      });
      try {
        final user = await UsersWebService()
            .login(mail: _mailController.text, passwd: _passwdController.text);

        Res.USER = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      passthrough: widget.passthrough,
                    )));
      } on UnauthorizedException catch (err) {
        setState(() {
          _isRequesting = false;
        });
        print(err);
        _showDialog(text: Languages.of(context).confirminformation);
      } on DioError catch (e) {
        _showDialog();
      } finally {
        setState(() {
          _isRequesting = false;
        });
      }
    } else if (!_accepted)
      setState(() {
        _showAcceptError = true;
      });
  }

  void _showDialog({String text}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(
                text ?? Languages.of(context).chekconnection,
                style: GoogleFonts.cairo(color: Colors.black),
              ),
              actions: [
                MaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      Languages.of(context).back,
                      style: GoogleFonts.cairo(color: Colors.blue),
                    ))
              ],
            ));
  }

  _signUp() {
    if (!_isRequesting) {
      showDialog(
          context: context,
          builder: (context) => GestureDetector(
                onTap: () => print(''),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: SizedBox(
                    //width: .8.sw,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 40.h, left: 60.w, right: 60.w, bottom: 25.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Languages.of(context).register,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 35.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 35.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _dialogBtn(
                                    text:
                                        Languages.of(context).registerAsCompany,
                                    icon: 'register_company',
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignupScreenEntreprise(
                                                    isCompany: true,
                                                  )));
                                    }),
                                Expanded(
                                  child: Container(),
                                ),
                                _dialogBtn(
                                    icon: 'register_personal',
                                    text:
                                        Languages.of(context).registerAsPerson,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignupScreenEntreprise()));
                                    })
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
    }
  }

  Widget _dialogBtn(
      {@required String icon,
      @required String text,
      @required Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/$icon.svg',
              width: 48,
            ),
            Text(
              text,
              style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _openForgetPasswdDialog() {
    showDialog(
        builder: (BuildContext context) => Dialog(
              child: ForgetPasswdDialog(),
            ),
        context: context);
  }

  /*Widget _socialButton({SocialMethod method, VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: OutlinedButton(
        onPressed: _isRequesting
            ? null
            : method == SocialMethod.Apple
                ? _loginApple
                : method == SocialMethod.Google
                    ? _loginGoogle
                    : _loginFacebook,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                method == SocialMethod.Apple
                    ? FontAwesome.apple
                    : method == SocialMethod.Google
                        ? FontAwesome.google
                        : FontAwesome.facebook,
                color: Colors.black,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${Languages.of(context).continueWith} ${method.name}',
                    style:
                        TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
          side: MaterialStateProperty.all(BorderSide(
            color: Colors.black,
          )),
        ),
      ),
    );
  }*/

  /*Future<void> _loginApple() async {
    setState(() {
      _isRequesting = true;
    });

    AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: AppleIDAuthorizationScopes.values,
        //nonce: nonce,
      );
    } catch (e) {
      setState(() {
        _isRequesting = false;
      });

      return;
    }

    UsersWebService()
        .socialLogin(SocialMethod.Apple, appleCredential.identityToken);

    setState(() {
      _isRequesting = false;
    });
  }*/

  /*Future<void> _loginFacebook() async {
    setState(() {
      _isRequesting = true;
    });
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    String token;
    try {
      token = loginResult.accessToken.token;
    } catch (e) {
      setState(() {
        _isRequesting = true;
      });
      return;
    }

    UsersWebService().socialLogin(SocialMethod.Facebook, token);
  }*/

/*  Future<void> _loginGoogle() async {
    setState(() {
      _isRequesting = true;
    });

    String token;
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      token = (await googleUser?.authentication).accessToken;
    } catch (e) {
      print(e.toString());
      setState(() {
        _isRequesting = false;
      });

      return;
    }

    UsersWebService().socialLogin(SocialMethod.Google, token);
  }*/
}
