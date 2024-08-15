import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:cs_chat_app/auxiliary/messenger.dart';
import 'package:cs_chat_app/constants/colors.dart';
import 'package:cs_chat_app/model/message.dart';
import 'package:cs_chat_app/model/subscriber.dart';
import 'package:cs_chat_app/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "/";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements MessengerSubscriber {

  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtServer = TextEditingController();
  
  Color connectStatusColor = MainColor.red;
  String connectStatusMsg = "Not connected";

  Text authStatus = const Text("", style: TextStyle(fontSize: 13));

  @override
  void initState() {
    super.initState();
  }
    
  @override
  Widget build(context) {
    return PopScope(
      onPopInvoked: (_) => exit(0),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 40),
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(
                            color: Colors.grey.withOpacity(.9),
                            spreadRadius: 1
                          )],
                          borderRadius: BorderRadius.circular(40)
                        ),
                        child: TextField(
                          controller: txtServer,
                          decoration: const InputDecoration(
                            constraints: BoxConstraints(maxWidth: 185),
                            hintText: "192.168.156.144:178",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                            border: InputBorder.none
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _connectToServer(), 
                        style: TextButton.styleFrom(
                          backgroundColor: connectStatusColor,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(19)
                        ),
                        child: const Icon(Icons.computer, color: Colors.white, size: 20,),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: connectStatusColor,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Text(
                      connectStatusMsg,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 80,),
              Center(
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
                  Container(child: authStatus),
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
            )],
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
        _showAuthError(AuthStatus.text);

        Messenger messenger = Messenger.getInstance();
        if(!messenger.connected()) {
          _showConnectStatus(1, "Not connected");
        }
      }
    }
  }


  void _connectToServer() async {
    if(txtServer.text.trim().isEmpty) {
      _showConnectStatus(1, "Please provide the address");
      return;
    }

    List<String>? address = _parseAddress(txtServer.text);
    if(address != null) {
      _showConnectStatus(2, "Connecting");
    }
    else {
      _showConnectStatus(1, "Invalid IPv4 Address Format");
      return;
    }

    Messenger messenger = Messenger.getInstance(host: address[0], port: int.tryParse(address[1]));
    await messenger.reConnectEx();
    if(!messenger.connected()) {
      int attempts = 2;
      while(!messenger.connected() && attempts > 0) {
        await messenger.reConnectEx();

        sleep(const Duration(seconds: 1));
        attempts--;
      }
    }

    setState(() {
      if(messenger.connected()) {
        _showConnectStatus(3, "Connected");
      } else { 
        _showConnectStatus(1, "Could not connect. Check address");
      }
    }); 
  }

  void _login() async {
    if(txtUsername.text.trim().isEmpty || txtPassword.text.trim().isEmpty) {
      _showAuthError("All input fields are required.");
      return;
    }

    var pwordBytes = utf8.encode(txtPassword.text);

    Messenger messenger = Messenger.getInstance();
    messenger.subscribe(this);
    if(messenger.connected()) {
      messenger.auth(txtUsername.text, sha256.convert(pwordBytes).toString());
    }
    else {
      _showAuthError("Not connected.");
    }
  }

  void _clearWarnings() {
    setState(() {
      authStatus = const Text("", style: TextStyle(fontSize: 13),);
    });
  }

  void _showConnectStatus(int stage, String msg) {
    setState(() {
      switch(stage) {
        case 1: connectStatusColor = MainColor.red;
        case 2: connectStatusColor = MainColor.yellow;
        case 3: connectStatusColor = MainColor.green;
      }
      connectStatusMsg = msg;
    });
  }

  void _showAuthError(String err) {
    setState(() {
      authStatus = Text(
        err,
        style: const TextStyle(
          color: MainColor.red,
          fontSize: 13,
        ),
        maxLines: 2,
      );
    });
  }
  
  List<String>? _parseAddress(String address) {
    List<String> addressSegments = address.split(':'); 
    if(addressSegments.length == 2) {
      // Test Port portion
      int? port = int.tryParse(addressSegments[1]);
      if(port == null || port <= 0) {
        return null;
      }

      validIPv4Segment(int? seg) {
        return seg != null && (seg >= 0 && seg <= 255);
      }

      List<String> segments = addressSegments[0].split('.');
      if(int.tryParse(addressSegments[1]) != null && segments.length == 4) {
        // Test IPv4 portion
        for(String seg in segments) {
          int? current = int.tryParse(seg);

          if(!validIPv4Segment(current)) {
            return null;
          }
        }

        // Both Port and IPv4 valid
        return addressSegments;
      }
    }

    return null;
  }
}