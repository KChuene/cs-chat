import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cs_chat_app/auxiliary/messenger.dart';
import 'package:cs_chat_app/auxiliary/navigatorservice.dart';
import 'package:cs_chat_app/model/message.dart';
import 'package:cs_chat_app/model/subscriber.dart';
import 'package:cs_chat_app/screens/chat.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget implements MessengerSubscriber {
  static const String route = "/";

  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  BuildContext? context;

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(minWidth: 500),
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                height: 128,
                width: 128,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset("assets/images/network-smashicons.png"),
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                constraints: BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(.9),
                    spreadRadius: .8,
                    blurRadius: 1
                  )]
                ),
                child: TextField(
                  controller: txtUsername,
                  decoration: InputDecoration(
                    hintText: "Username",
                    hintStyle: TextStyle(color: Colors.grey),
                    icon: Icon(Icons.person_2_rounded),
                    border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                constraints: BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(.9),
                    spreadRadius: .8,
                    blurRadius: 1
                  )]
                ),
                child: TextField(
                  controller: txtPassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey),
                    icon: Icon(Icons.lock),
                    border: InputBorder.none
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15)
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25
                  )
                )
              )
            ]
          ),
        ),
      ),
    );
  }

  void _login() async {
    Messenger messenger = await Messenger.getInstance();
    var pwordBytes = utf8.encode(txtPassword.text);
    messenger.auth(txtUsername.text, sha256.convert(pwordBytes).toString());
    messenger.subscribe(this);
  }
  
  @override
  void handleMessage(Message message) {
    print("I have been called.");
    if(message.type == MsgType.auth) {
      if(AuthStatus.isSuccess) {
        Navigator
        .of(NavigatorService.navigatorKey.currentContext!)
        .pushNamed(ChatScreen.route);
      }
    }
  }
}