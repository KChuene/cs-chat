import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs_chat_app/auxiliary/messagebox.dart';
import 'package:cs_chat_app/auxiliary/messenger.dart';
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
      (Uint8List data) async { 
        Map<String, dynamic> jsonObj = json.decode(String.fromCharCodes(data));
        
        Messenger messenger = await Messenger.getInstance();
        messenger.handleMessage(jsonObj);
      },
      onError: (error) async {
        // Pass errors to AuthStatus if not authenticated else add to MessageBox
        print("Error occured: $error");
        
        Messenger messenger = await Messenger.getInstance();
        messenger.handleNotice(MsgType.error, error ); // Change to 'Internal server error. Try again later'
      },
      onDone: () async {
        // Pass errors to AuthStatus if not authenticated else add to MessageBox
        Messenger messenger = await Messenger.getInstance();
        messenger.handleNotice(MsgType.end, "Server disconnected");

        socket?.destroy();
        socket = null;
      }
    );
  }

  bool disconnected() {
    return socket == null;
  }

  void auth(AuthRequest request) {
    print("Attempting to authenticate");
    AuthStatus.isReceived = false;
    socket?.write(json.encode(request.toJson()));
  }

  void send(TextMessage msg) async {
    socket?.write(json.encode(msg));
  }
}