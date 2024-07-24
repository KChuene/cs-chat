import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:cs_chat_app/auxiliary/messenger.dart';
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
  Messenger messenger = Messenger.getInstance();

  @override
  void initState() {
    messenger.subscribe(this);
    super.initState();
  }
    
  @override
  Widget build(context) {
    return PopScope(
      onPopInvoked: (_) => exit(0),
      child: Scaffold(
        body: Container(
          constraints: const BoxConstraints(minWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 128,
                  width: 128,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset("assets/images/network-smashicons.png"),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  constraints: const BoxConstraints(maxWidth: 500),
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
                    decoration: const InputDecoration(
                      hintText: "Username",
                      hintStyle: TextStyle(color: Colors.grey),
                      icon: Icon(Icons.person_2_rounded),
                      border: InputBorder.none
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  constraints: const BoxConstraints(maxWidth: 500),
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
                    decoration: const InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.grey),
                      icon: Icon(Icons.lock),
                      border: InputBorder.none
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),
                Container(child: status),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () => _login(), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MainColor.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15)
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
      ),
    );
  }

  @override
  void handleMessage(Message message) {
    if(message.type == MsgType.auth) {
      if(AuthStatus.isSuccess) {
        Navigator
        .of(context)
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
        status = const Text(
          "All input fields are required.",
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w100,
          ),
          maxLines: 2,
        );
      });

      return;
    }

    var pwordBytes = utf8.encode(txtPassword.text);
    messenger.auth(txtUsername.text, sha256.convert(pwordBytes).toString());
  }

  void _clearWarnings() {
    setState(() {
      status = const Text("", style: TextStyle(fontSize: 13),);
    });
  }
  
}