import 'dart:js_util';

import 'package:cs_chat_app/model/message.dart';
import 'package:flutter/material.dart';

class MessageBox {
  List<Message> messages = [];
  static final MessageBox _instance = MessageBox._construct();

  factory MessageBox() {
    return _instance;
  }

  MessageBox._construct() {
    messages.add(AuthMessage());
  }

  void add(String message) {
    if(message.startsWith("<AUTH_OK>")) {
      AuthMessage.isSuccess = true;
    }
    else if(message.startsWith("<AUTH_BAD>")) {
      AuthMessage.isSuccess = false;
    }
    else {
      
    }
  }

  bool auth_status() {
    return AuthMessage.isSuccess;
  } 
}