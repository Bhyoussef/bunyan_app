import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPasswdDialog extends StatefulWidget {
  ForgetPasswdDialog({Key key}) : super(key: key);

  @override
  _ForgetPasswdDialogState createState() => _ForgetPasswdDialogState();
}

class _ForgetPasswdDialogState extends State<ForgetPasswdDialog> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  bool _isRequesting = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Languages.of(context).emailaddress, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.0),),
          SizedBox(height: 15.0,),
          TextFormField(
            controller: textController1,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: Languages.of(context).email,
            ),
          ),
          SizedBox(height: 15.0,),
          
          TextButton(onPressed: _isRequesting ? null : _next, child: Text(Languages.of(context).next, style: GoogleFonts.cairo(fontWeight: FontWeight.w600),))
        ],
      ),
    );
  }

  Future<void> _next() async {
    if (textController1.text.isNotEmpty) {
      setState(() {
        _isRequesting = true;
      });
      try {
        final response = await UsersWebService().forgetPasswd(
            textController1.text);
      }on DioError catch (e)  {
        print(e.response.statusCode);
      }
      AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        title: Languages.of(context).resetPassword,
        desc: Languages.of(context).otpSubTitle,
        btnOkText: Languages.of(context).agreeon,
        btnOkOnPress: () => Navigator.of(context).pop(),
      )..show();

      setState(() {
        _isRequesting = false;
      });
    }
  }

  void _showDialog(String text) {
    showDialog(context: context, builder: (context) => AlertDialog(
      content: Text(text),
      title: Text(Languages.of(context).wrong),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Languages.of(context).agreeon,
              style: GoogleFonts.cairo(color: Colors.teal),
            ))
      ],
    ));
  }
}