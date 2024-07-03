import 'dart:convert';
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
    socket = await Socket.connect(host, port);
    print("Connected to ${socket!.remoteAddress.address}:${socket!.port}.");

    print("Listening for messages");
    socket?.listen(
      (Uint8List data) { 
        Map<String, dynamic> jsonObj = json.decode(String.fromCharCodes(data));
        Message msg = Message.fromJson(jsonObj);

        if(msg.type == MsgType.auth) {
          AuthStatus.isReceived = true;
          AuthStatus.setFromJson(jsonObj);
          print("Auth status: ${AuthStatus.isSuccess}, message: ${AuthStatus.text}");
        }
        else {
          msgBox.add(TextMessage.fromJson(jsonObj));
        }
      },
      onError: (error) {
        // Pass errors to AuthStatus if not authenticated else add to MessageBox
        if(AuthStatus.isSuccess) {
          msgBox.add(Notice(
            type: MsgType.error,
            text: error
          ));
        }
        else {
          AuthStatus.text = error;
        }
      },
      onDone: () {
        // Pass errors to AuthStatus if not authenticated else add to MessageBox
        if(AuthStatus.isSuccess) {
          msgBox.add(Notice(
            type: MsgType.end,
            text: "Server disconnected.",
          )); 
        }
        else {
          AuthStatus.text = "Server disconnected.";
        }
        socket?.destroy();
        socket = null;
      }
    );
  }

  bool disconnected() {
    return socket == null;
  }

  Future<void> auth(AuthRequest request) async {
    print("Attempting to authenticate");
    
    return Future.delayed(Duration(seconds: 10), () {
      AuthStatus.isReceived = false;
      socket?.write(json.encode(request.toJson()));
    });
  }

  void send(TextMessage msg) async {
    socket?.write(json.encode(msg));
  }
}