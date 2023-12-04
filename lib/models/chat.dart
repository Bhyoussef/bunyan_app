import 'package:bunyan/models/person.dart';
import 'package:equatable/equatable.dart';

class ChatModel {
  int id;
  DateTime date;
  PersonModel sender;
  PersonModel receiver;
  String message;


  ChatModel({this.id, this.date, this.sender, this.message, this.receiver});


  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: int.parse(json["id"].toString()),
      date: DateTime.parse(json["date"]),
      sender: PersonModel.fromJson(json["owner"]),
      message: json["message"],
      receiver: PersonModel.fromJson(json['receiver']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "date": this.date.toIso8601String(),
      "owner": this.sender,
      "message": this.message,
      'receiver': this.receiver,
    };
  }

 /* @override
  List<Object> get props => [id];*/

}