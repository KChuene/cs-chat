import 'dart:io';
import 'dart:typed_data';

import 'package:cs_chat_app/auxiliary/messagebox.dart';
import 'package:cs_chat_app/model/message.dart';

class Client {

  String host;
  int port;
  Socket? socket;
  MessageBox msgBox = MessageBox();


  Client({required this.host, required this.port});

  Future<void> connect() async {
    socket = await Socket.connect("127.0.0.1", 178);
    print("Connected to ${socket!.remoteAddress.address}:${socket!.port}.");

    print("Listening for messages");
    socket?.listen(
      (Uint8List data) { 
        TextMessage message = data as TextMessage;
        msgBox.add(message);
      },
      onError: (error) {
        if(error.toString().length <= 25) {
          print(error);
        }
        else msgBox.add("");
      },
      onDone: () {
        print("[!] Server disconnected.");
        socket?.destroy();
      }
    );
  }

  Future<bool> auth(String uname, String pword) async {
    print("Attempting to authenticate");
    if(socket != null) {
    socket!.write("<AUTH>.$uname.$pword");
    Uint8List l = await socket!.first;
    String success = String.fromCharCodes(l);
    print("Auth attempt result $success");
    if(success.startsWith("<OK>.")) {
      print("Authenticated.");
      return true;
    }
    }
    print("Didn't authenticate.");
    return false;


  }

  Future<void> listen() async {

  }

  void send(String msg) async {
    socket!.write(msg);
  }
}

void main() async {
  final cli = Client(host: "127.0.0.1", port: 178);
  await cli.connect();
  print("Next authentication");

  bool isauth = await cli.auth("wiener", "026ad9b14a7453b7488daa0c6acbc258b1506f52c441c7c465474c1a564394ff");
  if(isauth) {
    cli.listen();

    String? message = "";
    do {
      print("<message> ~\$ ");
      message = stdin.readLineSync();
      cli.send(message.toString());
    }while(message==null || message.isEmpty && message!="x");
  }
}