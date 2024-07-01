import 'package:flutter/material.dart';

enum MsgType { auth, text }

abstract class Message {
  MsgType type;

  Message({
    this.type = MsgType.auth
  });

  Message fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class TextMessage extends Message {

  String text;
  bool isFromMe;
  DateTime dtSent;

  TextMessage({
    required this.dtSent,
    required this.text,
    required this.isFromMe
  }):super(type: MsgType.text);

  static List<TextMessage> list() {
    return [
      TextMessage(text: "Wazzup bro.", dtSent: DateTime.now(), isFromMe: false),
      TextMessage(text: "Homie, what's going on; I was wondering where you been at?", dtSent: DateTime.now(), isFromMe: true),
      TextMessage(text: "Busy days it's been. But finally have some time off now.", dtSent: DateTime.now(), isFromMe: false),
      TextMessage(text: "That's good to here.", dtSent: DateTime.now(), isFromMe: true),
      TextMessage(text: "So... game night?", dtSent: DateTime.now(), isFromMe: true),
      TextMessage(text: "You bet!!", dtSent: DateTime.now(), isFromMe: false)
    ];
  }
}

class AuthMessage extends Message {
  static bool isSuccess = false;
  
  AuthMessage() : super(type: MsgType.auth);
}