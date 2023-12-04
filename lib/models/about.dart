


import 'package:bunyan/tools/extensions.dart';

class AboutModel {

  String arabic_text;
  String english_text;


  AboutModel({this.arabic_text, this.english_text});

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(

      arabic_text: json.get("arabic_text"),
      english_text: json.get("english_text"),


    );
  }
  Map<String, dynamic> toJson() {
    return {

      "arabic_text": this.arabic_text,
      "english_text": this.english_text,

    };
  }



}