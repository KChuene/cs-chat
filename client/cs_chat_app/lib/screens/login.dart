import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cs_chat_app/auxiliary/messenger.dart';
import 'package:cs_chat_app/auxiliary/navigatorservice.dart';
import 'package:cs_chat_app/constants/colors.dart';
import 'package:cs_chat_app/model/message.dart';
import 'package:cs_chat_app/model/subscriber.dart';
import 'package:cs_chat_app/screens/chat.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "/";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements MessengerSubscriber {

  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  Text status = const Text("", style: TextStyle(fontSize: 13));
    
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
                  onTap: () => _clearWarnings(),
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
                  onTap: () => _clearWarnings(),
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
              SizedBox(height: 10),
              Container(child: status),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () => _login(), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainColor.green,
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

  @override
  void handleMessage(Message message) {
    print("I have been called.");
    if(message.type == MsgType.auth) {
      if(AuthStatus.isSuccess) {
        Navigator
        .of(NavigatorService.navigatorKey.currentContext!)
        .pushNamed(ChatScreen.route);
      }
      else {
        setState(() { 
          status = Text(
            AuthStatus.text,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w100
            ),
          );
        });
      }
    }
  }

  void _login() async {
    if(txtUsername.text.trim().isEmpty || txtPassword.text.trim().isEmpty) {
      setState(() {
        status = Text(
          "All input fields are required.",
          style: const TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w100
          ),
        );
      });

      return;
    }
    
    Messenger messenger = await Messenger.getInstance();
    var pwordBytes = utf8.encode(txtPassword.text);
    messenger.subscribe(this);
    messenger.auth(txtUsername.text, sha256.convert(pwordBytes).toString());
  }

  void _clearWarnings() {
    setState(() {
      status = const Text("", style: TextStyle(fontSize: 13),);
    });
  }
  
}