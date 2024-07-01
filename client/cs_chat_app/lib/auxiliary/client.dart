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
          AuthResponse.setFromJson(jsonObj);
        }
        else {
          msgBox.add(TextMessage.fromJson(jsonObj));
        }
      },
      onError: (error) {
        msgBox.add(TextMessage(
          type: MsgType.error,
          text: error,
          dtSent: DateTime.now(), // Not used in later evaluation
          isFromMe: false // Not used in later evaluation
        ));
      },
      onDone: () {
        msgBox.add(TextMessage(
          type: MsgType.info,
          text: "Server disconnected.",
          dtSent: DateTime.now(), // Not used in later evaluation
          isFromMe: false // Not used in later evaluation
        )); 
        socket?.destroy();
      }
    );
  }

  Future<void> auth(AuthRequest request) async {
    print("Attempting to authenticate");
    socket?.write(json.encode(request));
  }

  void send(TextMessage msg) async {
    socket?.write(json.encode(msg));
  }
}